/*************************************************************************
  Dividing Head Controller — Arduino Nano version
  For use with: VEVOR K11-100 dividing head (NEMA23, 6:1 belt reduction)
  Driven through an external STEP/DIR stepper driver (DRV8825 is the
  default assumption for this build's wiring guide — TB6600/DM542 also
  work unchanged if you want more current headroom) -- the K11 head has
  NO built-in driver, so the Arduino talks to the external driver, and
  the driver talks to the K11's motor.

  Uses the Nano's ATmega328P, identical pin functions to an Uno (same
  interrupt pins D2/D3, same I2C on A4/A5) — this is the same sketch
  that runs on an Uno, just built/uploaded with Board = "Arduino Nano"
  and the correct Processor (old bootloader vs new, see notes below).

  Features
  ---------
  - SSD1306 128x64 I2C OLED, home status screen + separate full-screen
    MENU (fixes the earlier layout where a long item list ran off the
    bottom of the display)
  - Rotary encoder (with push button) for menu navigation / value entry
  - Dedicated INDEX button: rotates the set number of degrees every time
    it's pressed (turn a workpiece into equal divisions by pressing it
    repeatedly), with a running division counter on screen. While
    editing the degrees/index value, the same INDEX button instead
    cycles the increment size (100 / 10 / 1 / 0.1 / 0.01 degrees per
    encoder click) so large changes don't take hundreds of clicks.
  - Editable settings, saved to EEPROM:
      * Degrees per index (0.01 - 999.99)
      * Speed (as % of max speed)
      * Direction (CW / CCW)
      * Calibration: motor steps/rev, driver microstepping, gear ratio
  - Non-blocking motion via AccelStepper (move can be cancelled by
    pressing the encoder button)

  Required libraries (Library Manager):
    - Adafruit GFX Library
    - Adafruit SSD1306
    - AccelStepper

  Wiring summary (see wiring_guide.md for full schematic):
    OLED SDA -> A4      OLED SCL -> A5      OLED VCC -> 5V   OLED GND -> GND
    Encoder CLK -> D2   Encoder DT -> D3    Encoder SW -> D4
    Index button -> D5  (button to GND, uses internal pull-up)
    Driver STEP -> D9   Driver DIR -> D8    Driver ENABLE -> D7

  Upload note: in Arduino IDE, Tools > Board > "Arduino Nano". Most
  clone Nanos with a CH340 USB chip need Tools > Processor >
  "ATmega328P (Old Bootloader)" to upload successfully — if you get a
  "programmer not responding" error, that's almost always the fix.
*************************************************************************/

#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <AccelStepper.h>
#include <EEPROM.h>

// ---------------- OLED ----------------
#define SCREEN_WIDTH   128
#define SCREEN_HEIGHT  64
#define OLED_RESET     -1
#define OLED_ADDR      0x3C   // change to 0x3D if your module needs it
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

// ---------------- Pins ----------------
const uint8_t PIN_ENC_CLK   = 2;   // interrupt pin
const uint8_t PIN_ENC_DT    = 3;
const uint8_t PIN_ENC_SW    = 4;
const uint8_t PIN_INDEX_BTN = 5;
const uint8_t PIN_STEP      = 9;
const uint8_t PIN_DIR       = 8;
const uint8_t PIN_ENABLE    = 7;   // LOW = driver enabled (most drivers)

// ---------------- Stepper ----------------
AccelStepper stepper(AccelStepper::DRIVER, PIN_STEP, PIN_DIR);

// ---------------- Persistent settings ----------------
struct Settings {
  uint32_t magic;          // validity check
  float    degreesPerIdx;  // degrees moved per INDEX press
  uint8_t  speedPercent;   // 1-100 % of max speed
  uint8_t  direction;      // 0 = CW, 1 = CCW
  uint16_t motorStepsRev;  // full steps per motor revolution (e.g. 200)
  uint16_t microstep;      // driver microstep setting (1,2,4,8,16,32...)
  float    gearRatio;      // dividing head reduction ratio (K11 = 6.0)
};

const uint32_t SETTINGS_MAGIC = 0xD1B7A5;
Settings cfg;

void loadSettings() {
  EEPROM.get(0, cfg);
  if (cfg.magic != SETTINGS_MAGIC) {
    cfg.magic          = SETTINGS_MAGIC;
    cfg.degreesPerIdx  = 10.00;
    cfg.speedPercent   = 50;
    cfg.direction      = 0;
    cfg.motorStepsRev  = 200;
    cfg.microstep      = 8;
    cfg.gearRatio      = 6.0;   // VEVOR K11 belt reduction
    EEPROM.put(0, cfg);
  }
}
void saveSettings() { EEPROM.put(0, cfg); }

float stepsPerDegree() {
  return (cfg.motorStepsRev * (float)cfg.microstep * cfg.gearRatio) / 360.0;
}

const float MAX_SPEED_SPS  = 4000.0; // steps/sec ceiling at 100% speed
const float MAX_ACCEL_SPS2 = 4000.0;

// ---------------- Encoder handling ----------------
volatile int8_t encDelta = 0;
void encoderISR() {
  static uint8_t lastState = 0;
  uint8_t clk = digitalRead(PIN_ENC_CLK);
  uint8_t dt  = digitalRead(PIN_ENC_DT);
  uint8_t state = (clk << 1) | dt;
  if (state != lastState) {
    if (clk != lastState) {          // rising/falling edge on CLK
      encDelta += (clk == dt) ? -1 : 1;
    }
    lastState = state;
  }
}

// Simple debounced button reader
struct Button {
  uint8_t pin;
  bool lastReading;
  bool stableState;
  unsigned long lastChange;

  Button(uint8_t p) : pin(p), lastReading(HIGH), stableState(HIGH), lastChange(0) {}

  bool pressedEvent() {
    //Serial.print("Button pressed "); Serial.println(pin);
    bool reading = digitalRead(pin);
    if (reading != lastReading) lastChange = millis();
    if (millis() - lastChange > 25) {
      if (reading != stableState) {
        stableState = reading;
        lastReading = reading;
        //Serial.print("Button pressed "); Serial.println(pin);
        if (stableState == LOW){ 
          //Serial.print("returning True");
          return true; // active-low press
                                              //
        }
      }
    }
    lastReading = reading;
    //Serial.print("Button pressed "); Serial.println(pin);
    //Serial.print("returning false");
    
    return false;
  }
};
Button encBtn { PIN_ENC_SW };
Button idxBtn { PIN_INDEX_BTN };

// ---------------- Menu state machine ----------------
enum UIState {
  HOME,
  MENU,
  EDIT_DEGREES,
  EDIT_SPEED,
  EDIT_DIRECTION,
  CAL_STEPSREV,
  CAL_MICROSTEP,
  CAL_GEARRATIO,
  RUNNING
};
UIState state = HOME;

const char* menuItems[] = {
  "Set Degrees",
  "Set Speed",
  "Set Direction",
  "Calibrate",
  "Back"
};
const uint8_t MENU_COUNT = 5;
int8_t menuIndex = 0;

// Degrees/index editor: encoder changes the value by whichever
// increment is currently selected; the INDEX button cycles through
// increments so large moves don't require hundreds of clicks.
const float DEG_STEPS[] = {100.0, 10.0, 1.0, 0.1, 0.01};
const uint8_t DEG_STEP_COUNT = 5;
uint8_t degStepIdx = 2;   // default increment = 1.0 degree

long divisionCount = 0;  // how many indexes since last zero, for tracking

// ---------------- Setup ----------------
void setup() {
  Serial.begin(9600);

  pinMode(PIN_ENC_CLK, INPUT_PULLUP);
  pinMode(PIN_ENC_DT, INPUT_PULLUP);
  pinMode(PIN_ENC_SW, INPUT_PULLUP);
  pinMode(PIN_INDEX_BTN, INPUT_PULLUP);
  pinMode(PIN_ENABLE, OUTPUT);

  attachInterrupt(digitalPinToInterrupt(PIN_ENC_CLK), encoderISR, CHANGE);

  loadSettings();

  stepper.setMaxSpeed(MAX_SPEED_SPS);
  stepper.setAcceleration(MAX_ACCEL_SPS2);
  digitalWrite(PIN_ENABLE, LOW);   // enable driver

  if (!display.begin(SSD1306_SWITCHCAPVCC, OLED_ADDR)) {
    // If the OLED fails to init, halt with a blink so it's obvious.
    pinMode(LED_BUILTIN, OUTPUT);
    while (true) { digitalWrite(LED_BUILTIN, !digitalRead(LED_BUILTIN)); delay(200); }
  }
  display.setTextColor(SSD1306_WHITE);
  drawHome();
  Serial.println("Setup");
}

// ---------------- Main loop ----------------
void loop() {
  switch (state) {
    case HOME:          handleHome();        break;
    case MENU:          handleMenu();        break;
    case EDIT_DEGREES:  handleEditDegrees(); break;
    case EDIT_SPEED:    handleEditSpeed();   break;
    case EDIT_DIRECTION:handleEditDirection();break;
    case CAL_STEPSREV:  handleEditCalInt(cfg.motorStepsRev, 1, 1, 5000, "Motor steps/rev"); break;
    case CAL_MICROSTEP: handleEditCalInt(cfg.microstep, 1, 1, 256, "Driver microstep");            break;
    case CAL_GEARRATIO: handleEditFloat(cfg.gearRatio, 0.1, 0.1, 200.0, "Gear ratio (K11=6.0)");       break;
    case RUNNING:        handleRunning();    break;
  }

  // INDEX button triggers a move from the home screen at any time
  if (state == HOME && idxBtn.pressedEvent()) {
    startIndexMove();
  }
}

// ---------------- Home screen (status readout, default view) ----------------
void handleHome() {
  if (encBtn.pressedEvent()) {
    state = MENU;
    menuIndex = 0;
    drawMenu();
  }
}

void drawHome() {
  display.clearDisplay();
  display.setTextSize(1);
  display.setCursor(0, 0);
  display.print(F("DIVIDING HEAD"));
  display.drawFastHLine(0, 9, 128, SSD1306_WHITE);

  display.setCursor(0, 12);
  display.print(F("Deg/idx: "));
  display.print(cfg.degreesPerIdx, 2);

  display.setCursor(0, 22);
  display.print(F("Speed: "));
  display.print(cfg.speedPercent);
  display.print(F("%  Dir: "));
  display.print(cfg.direction == 0 ? "CW" : "CCW");

  display.setCursor(0, 32);
  display.print(F("Count: "));
  display.print(divisionCount);

  display.drawFastHLine(0, 41, 128, SSD1306_WHITE);
  display.setCursor(0, 46);
  display.print(F("INDEX = turn"));
  display.setCursor(0, 55);
  display.print(F("Press encoder = MENU"));
  display.display();
}

// ---------------- Menu screen (full-height item list) ----------------
void handleMenu() {
  if (encDelta != 0) {
    menuIndex = constrain(menuIndex + (encDelta > 0 ? 1 : -1), 0, MENU_COUNT - 1);
    encDelta = 0;
    drawMenu();
  }
  if (encBtn.pressedEvent()) {
    switch (menuIndex) {
      case 0: state = EDIT_DEGREES;   drawEditScreen(); return;
      case 1: state = EDIT_SPEED;     drawEditScreen(); return;
      case 2: state = EDIT_DIRECTION; drawEditScreen(); return;
      case 3: state = CAL_STEPSREV;   drawEditScreen(); return;
      case 4: state = HOME;           drawHome();       return;  // Back
    }
  }
}

void drawMenu() {
  display.clearDisplay();
  display.setTextSize(1);
  display.setCursor(0, 0);
  display.print(F("MENU"));
  display.drawFastHLine(0, 9, 128, SSD1306_WHITE);

  // Full display height available now that this is its own screen —
  // 5 items at 10px each fits comfortably within 64px with room to spare.
  for (uint8_t i = 0; i < MENU_COUNT; i++) {
    display.setCursor(0, 14 + i * 10);
    display.print(i == menuIndex ? F("> ") : F("  "));
    display.print(menuItems[i]);
  }
  display.display();
}

// ---------------- Degrees/index editor (selectable increment) ----------------
void handleEditDegrees() {
  if (encDelta != 0) {
    float step = DEG_STEPS[degStepIdx];
    cfg.degreesPerIdx = constrain(cfg.degreesPerIdx + encDelta * step, 0.01, 999.99);
    encDelta = 0;
    drawEditDegreesScreen();
  }
  if (idxBtn.pressedEvent()) {
    degStepIdx = (degStepIdx + 1) % DEG_STEP_COUNT;
    drawEditDegreesScreen();
  }
  if (encBtn.pressedEvent()) {
    saveSettings();
    state = MENU;
    drawMenu();
  }
}

void drawEditDegreesScreen() {
  display.clearDisplay();
  display.setTextSize(1);
  display.setCursor(0, 0);
  display.print(F("Set Degrees/Index"));
  display.setTextSize(2);
  display.setCursor(0, 18);
  display.print(cfg.degreesPerIdx, 2);
  display.setTextSize(1);
  display.setCursor(0, 38);
  display.print(F("Step: "));
  display.print(DEG_STEPS[degStepIdx], 2);
  display.setCursor(0, 48);
  display.print(F("INDEX=step size"));
  display.setCursor(0, 56);
  display.print(F("Rotate=chg Press=save"));
  display.display();
}

// ---------------- Generic float editor (gear ratio) ----------------
void handleEditFloat(float &value, float step, float minV, float maxV, const char* label) {
  if (encDelta != 0) {
    value = constrain(value + encDelta * step, minV, maxV);
    encDelta = 0;
    drawEditFloat(value, label);
  }
  if (encBtn.pressedEvent()) {
    saveSettings();
    state = MENU;
    drawMenu();
  }
}

void drawEditFloat(float value, const char* label) {
  display.clearDisplay();
  display.setTextSize(1);
  display.setCursor(0, 0);
  display.print(label);
  display.setTextSize(2);
  display.setCursor(0, 24);
  display.print(value, 2);
  display.setTextSize(1);
  display.setCursor(0, 54);
  display.print(F("Rotate=change  Press=save"));
  display.display();
}

// call once when entering an edit state to draw first frame
void drawEditScreen() {
  switch (state) {
    case EDIT_DEGREES:   drawEditDegreesScreen(); break;
    case EDIT_SPEED:     drawEditSpeedScreen(); break;
    case EDIT_DIRECTION: drawEditDirScreen();   break;
    case CAL_STEPSREV:   drawEditIntScreen(cfg.motorStepsRev, "Motor steps/rev"); break;
    case CAL_MICROSTEP:  drawEditIntScreen(cfg.microstep, "Driver microstep");    break;
    case CAL_GEARRATIO:  drawEditFloat(cfg.gearRatio, "Gear ratio (K11=6.0)");    break;
    default: break;
  }
}

// ---------------- Speed editor ----------------
void handleEditSpeed() {
  if (encDelta != 0) {
    int v = constrain((int)cfg.speedPercent + encDelta, 1, 100);
    cfg.speedPercent = v;
    encDelta = 0;
    drawEditSpeedScreen();
  }
  if (encBtn.pressedEvent()) {
    saveSettings();
    state = MENU;
    drawMenu();
  }
}
void drawEditSpeedScreen() {
  display.clearDisplay();
  display.setTextSize(1);
  display.setCursor(0, 0);
  display.print(F("Set Speed (%)"));
  display.setTextSize(2);
  display.setCursor(0, 24);
  display.print(cfg.speedPercent);
  display.print('%');
  display.setTextSize(1);
  display.setCursor(0, 54);
  display.print(F("Rotate=change  Press=save"));
  display.display();
}

// ---------------- Direction editor ----------------
void handleEditDirection() {
  if (encDelta != 0) {
    cfg.direction = cfg.direction == 0 ? 1 : 0;
    encDelta = 0;
    drawEditDirScreen();
  }
  if (encBtn.pressedEvent()) {
    saveSettings();
    state = MENU;
    drawMenu();
  }
}
void drawEditDirScreen() {
  display.clearDisplay();
  display.setTextSize(1);
  display.setCursor(0, 0);
  display.print(F("Set Direction"));
  display.setTextSize(2);
  display.setCursor(0, 24);
  display.print(cfg.direction == 0 ? F("CW") : F("CCW"));
  display.setTextSize(1);
  display.setCursor(0, 54);
  display.print(F("Rotate=toggle  Press=save"));
  display.display();
}

// ---------------- Calibration integer editor (steps/rev, microstep) ----------------
void handleEditCalInt(uint16_t &value, int step, int minV, int maxV, const char* label) {
  if (encDelta != 0) {
    int v = constrain((int)value + encDelta * step, minV, maxV);
    value = v;
    encDelta = 0;
    drawEditIntScreen(value, label);
  }
  if (encBtn.pressedEvent()) {
    saveSettings();
    // step through calibration screens: steps/rev -> microstep -> gear ratio -> menu
    if (state == CAL_STEPSREV)      { state = CAL_MICROSTEP;  drawEditScreen(); }
    else if (state == CAL_MICROSTEP){ state = CAL_GEARRATIO;  drawEditScreen(); }
    else                             { state = MENU;           drawMenu(); }
  }
}
void drawEditIntScreen(int value, const char* label) {
  display.clearDisplay();
  display.setTextSize(1);
  display.setCursor(0, 0);
  display.print(label);
  display.setTextSize(2);
  display.setCursor(0, 24);
  display.print(value);
  display.setTextSize(1);
  display.setCursor(0, 54);
  display.print(F("Rotate=change  Press=next"));
  display.display();
}

// ---------------- Indexing move ----------------
void startIndexMove() {
  float spd = stepsPerDegree();
  long steps = lround(cfg.degreesPerIdx * spd);
  if (cfg.direction == 1) steps = -steps;

  float speed = MAX_SPEED_SPS * (cfg.speedPercent / 100.0);
  stepper.setMaxSpeed(speed);
  stepper.setAcceleration(min(speed, MAX_ACCEL_SPS2));
  stepper.move(steps);

  state = RUNNING;
  drawRunningScreen();
}

void handleRunning() {
  stepper.run();

  // allow cancelling with the encoder button
  if (encBtn.pressedEvent()) {
    stepper.stop();
  }

  if (stepper.distanceToGo() == 0) {
    divisionCount++;
    state = HOME;
    drawHome();
    return;
  }

  static unsigned long lastDraw = 0;
  if (millis() - lastDraw > 150) {
    lastDraw = millis();
    drawRunningScreen();
  }
}

void drawRunningScreen() {
  display.clearDisplay();
  display.setTextSize(1);
  display.setCursor(0, 0);
  display.print(F("INDEXING..."));
  display.setCursor(0, 16);
  display.print(F("Target: "));
  display.print(cfg.degreesPerIdx, 2);
  display.print(F(" deg"));
  display.setCursor(0, 28);
  display.print(F("Remaining steps:"));
  display.setCursor(0, 38);
  display.print(stepper.distanceToGo());
  display.setCursor(0, 54);
  display.print(F("Press encoder to stop"));
  display.display();
}
