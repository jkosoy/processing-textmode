TextModeScreen screenManager = new TextModeScreen();
int elapsedTime;

void setup() {
	noStroke();
	background(0);
	frameRate(25);
	colorMode(RGB,255);

	screenManager.setup(40,25,"font.png");
	size(screenManager.getCharsWide() * 16,screenManager.getCharsHigh() * 24);
}

// Shadow an area of the screen, draw an outlined box and write some text in it
int[] textModeDropShadow(int charId,int colorId) {
	int[] result = {charId,colorId};
	result[1] = colorId & 0x77;

	return result;
}

void draw() {
    float spinAngle = PI * 4 + sin(millis() / 120) * 2;
    float offsetAngle = 0.001 * sin(millis() / 120 - PI * 0.5);
    int writePos = 0;

    for (int y = 0; y < screenManager.getCharsHigh(); y++) {
        for (int x = 0; x < screenManager.getCharsWide(); x++) {
            int oy = y - (screenManager.getCharsHigh() / 2);
            int ox = x - (screenManager.getCharsWide() / 2);
            int distSquared = (ox * ox) + (oy * oy);
            float angle = spinAngle + atan2(ox, oy) + distSquared * offsetAngle;

            float amount = (spinAngle + angle / (float) Math.PI * 2 * 4);
            int switcher = (int) amount & 1;
            
            screenManager.charBuffer[writePos] = (int) random(255);
            screenManager.colorBuffer[writePos] = switcher == 0 ? 0x89 : 0xa9;

            writePos++;
        }
    }

	// calls the textModeDropShadow method to shadow an area of the screen.
    screenManager.processBox(2, 2, 22, 3, this, "textModeDropShadow");
    screenManager.printBox(1, 1, 22, 3, 0x4f);
    screenManager.print(2, 2, " >> Hello world! << ", 0x4f);

    // Render the textmode screen to our canvas
    screenManager.presentToScreen();
}
