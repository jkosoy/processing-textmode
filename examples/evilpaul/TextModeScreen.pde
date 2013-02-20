/**
 * TextMode for Processing.
 * @author Jamie Kosoy <jkosoy@gmail.com> @jkosoy
 * A port of the TextMode JS library by evilpaul. http://www.evilpaul.org/wp/?p=504
 */
 import java.lang.reflect.Method;

 class TextModeScreen {
  private color colorTable[] = { #000000, #0000AA, #00AA00, #00AAAA, #AA0000, #AA00AA, #AA5500, #AAAAAA, #555555, #5555FF, #55FF55, #55FFFF, #FF5555, #FF55FF, #FFFF55, #FFFFFF };

  private int charsWide;
  private int charsHigh;

  private PImage glyphs[];

  public int charBuffer[];
  public int colorBuffer[];

  /**
   * Sets up a Text Mode instance.
   *
   * @param  cw The width of the box in characters.
   * @param  ch The height of the box in characters.
   * @param  fontPath The path to a font.
   */
   public void setup(int cw,int ch,String fontPath) {
    charsWide = cw;
    charsHigh = ch;
    
    charBuffer = new int[charsWide * charsHigh];
    colorBuffer = new int[charsWide * charsHigh];
    
    PImage font = loadImage(fontPath);
    int counter = 0;
    glyphs = new PImage[(font.width/16)*(font.height/24)];

    for(int y=0;y<font.height;y+=24) {
      for(int x=0;x<font.width;x+=16) {
        glyphs[counter] = font.get(x,y,16,24);
        counter++;
      }
    }
  }

  public int getCharsHigh() { return charsHigh; }
  public int getCharsWide() { return charsWide; }

  /**
   * Renders the TextMode box.
   *
   */
   public void draw() {
    int readPos = 0;
    int sy = 0;

    for (int y = 0; y < charsHigh; y++) {
      int sx = 0;

      for (int x = 0; x < charsWide; x++) {
        int charId = charBuffer[readPos];
        int colorId = colorBuffer[readPos];
        readPos++;

        // background
        fill(colorTable[colorId >> 4]);
        rect(sx,sy,16,24);

        // text
        tint(colorTable[colorId & 15]);
        image(glyphs[charId],sx,sy);

        sx += 16;
      }

      sy += 24;
    }
  }

  /**
   * Renders the TextMode box. Same as draw() but matches the JS port.
   *
   */
   public void presentToScreen() {
    draw();
  }


  /**
   * Prints a string on the screen.
   *
   * @param  x The X position of the string.
   * @param  y The Y position of the string.
   * @param  txt The string to print.
   * @param  c The color (remember, 255 bytes!) the string should print in.
   */
   public void print(int x, int y, String txt,int c) {
    if (y >= 0 && y < charsHigh) {
      int writePos = x + y * charsWide;

      for (int i = 0; i < txt.length(); i++) {
        if (x + i >= 0 && x + i < charsWide) {
          charBuffer[writePos] = txt.codePointAt(i);
          colorBuffer[writePos] = c;
        }

        writePos++;
      }
    }
  }

  /**
   * Prints an outlined box.
   *
   * @param  x The X position of the string.
   * @param  y The Y position of the string.
   * @param  w The width of the box.
   * @param  h The height of the box.
   * @param  c The color (remember, 255 bytes!) the string should print in.
   */
   public void printBox(int x,int y,int w,int h,int c) {
    int innerWidth = w - 2;
    String spacer[] = new String[innerWidth + 1];
    for(int i=0;i<spacer.length;i++) {
      spacer[i] = "";
    }

    print(x, y, fromCharCode(201) + join(spacer,fromCharCode(205)) + fromCharCode(187), c);
    for (int j = y + 1; j < y + h - 1; j++) {
      print(x, j, fromCharCode(186) + join(spacer," ") + fromCharCode(186), c);
    }
    print(x, y + h - 1, fromCharCode(200) + join(spacer,fromCharCode(205)) + fromCharCode(188), c);

  }

  /**
   * Processes a box via a listener object.
   *
   * @param  x The X position of the box.
   * @param  y The Y position of the box.
   * @param  w The width of the box.
   * @param  h The height of the box.
   * @param  id An abritrary identifier so you can discern what you're doing in your callback.
   * @param  listener A class that impements the textModeProcessBoxHandler.
   * @see     TextModeCallback
   */
   public void processBox(int x, int y, int w, int h, String id, TextModeCallback listener) {
    for (int sy = y; sy < y + h; sy++) {
      if (sy >= 0 && sy <= charsHigh) {
        int readWritePos = x + sy * charsWide;
        for (int sx = x; sx < x + w; sx++) {
          if (sx >= 0 && sx <= charsWide) {
            int charId = charBuffer[readWritePos];
            int colorId = colorBuffer[readWritePos];

            int[] results = listener.textModeProcessBoxHandler(id,charId, colorId);

            charBuffer[readWritePos] = results[0];
            colorBuffer[readWritePos] = results[1];
          }
          readWritePos++;
        }
      }
    }
  }

  /**
   * Processes a box via a callback method. Great for the PApplet.
   *
   * @param  x The X position of the box.
   * @param  y The Y position of the box.
   * @param  w The width of the box.
   * @param  h The height of the box.
   * @param  obj an object that will process the box. Can just be "this" from your application.
   * @param  callbackFunction The string name of a function that will handle the processing. This function must return int[2] and accept int charId and int colorId to work.
   */
   public void processBox(int x, int y, int w, int h, Object obj, String callbackFunctionName) {
    for (int sy = y; sy < y + h; sy++) {

      if (sy >= 0 && sy <= charsHigh) {
        int readWritePos = x + sy * charsWide;
        for (int sx = x; sx < x + w; sx++) {
          if (sx >= 0 && sx <= charsWide) {
            int charId = charBuffer[readWritePos];
            int colorId = colorBuffer[readWritePos];

            try {
             Method callback = obj.getClass().getMethod(callbackFunctionName,int.class,int.class);
             Object invoked = callback.invoke(obj,charId,colorId);

             int[] results = (int[]) invoked;

             charBuffer[readWritePos] = results[0];
             colorBuffer[readWritePos] = results[1];
           }
           catch(Exception e) {
            println("Unable to call Objects textModeProcessBoxHandler method.");
          }

        }
        readWritePos++;
      }
    }
  }
}



  // emulates String.fromCharCode.
  // http://stackoverflow.com/questions/2946067/what-is-the-java-equivalent-to-javascripts-string-fromcharcode
  private String fromCharCode(int... codePoints) {
    return new String(codePoints, 0, 1);
  }
};

public interface TextModeCallback {
  public int[] textModeProcessBoxHandler(String id,int charId,int colorId); 
};