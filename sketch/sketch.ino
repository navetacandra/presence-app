// Import library
#include <ESP8266WebServer.h>
#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#include <LiquidCrystal_I2C.h>
#include <LittleFS.h>
#include <MFRC522.h>
#include <NTPClient.h>
#include <SPI.h>

// Declare variable
const int lcdColumns = 16;
const int lcdRows = 2;
const uint8_t RSTPIN = D3;
const uint8_t SDAPIN = D4;
const uint8_t buzzerPin = D8;
bool connected = false;
bool welcomeMessagePrinted = false;

String ssid;
String pass;
String firebaseHost;
String firebaseKey;
String firebaseAuthEmail;
String firebaseAuthPassword;
String ipaddress;

FirebaseData fbdo;
FirebaseAuth fauth;
FirebaseConfig fconfig;

IPAddress localIP(192, 168, 250, 250);
IPAddress localGateway(192, 168, 255, 0);
IPAddress subnet(255, 255, 0, 0);

LiquidCrystal_I2C lcd(0x27, lcdColumns, lcdRows);
MFRC522 mfrc522(SDAPIN, RSTPIN);
ESP8266WebServer server(80);

void setup() {
  // Serial setup
  Serial.begin(115200);
  // Set pin mode
  pinMode(buzzerPin, OUTPUT);

  // Initialize LCD
  lcd.init();
  lcd.backlight();
  lcd.clear();

  // Initialize LittleFS
  if (!LittleFS.begin()) {
    Serial.println("An error has occurred while mounting LittleFS");
  } else {
    Serial.println("LittleFS mounted successfully");
  }

  // Initialize MFRC522
  SPI.begin();
  mfrc522.PCD_Init();
  mfrc522.PCD_DumpVersionToSerial();

  // Get state
  ssid = readFile(LittleFS, "/ssid.txt");
  pass = readFile(LittleFS, "/pass.txt");
  firebaseHost = readFile(LittleFS, "/host.txt");
  firebaseKey = readFile(LittleFS, "/apikey.txt");
  firebaseAuthEmail = readFile(LittleFS, "/auth-email.txt");
  firebaseAuthPassword = readFile(LittleFS, "/auth-pass.txt");

  // Initialize WiFi
  if (initWiFi()) {
  } else {
    handleNetworkConnecting();
  }

  server.on("/is-esp", []() {
    server.send(200, "application/json", "{\"isEsp\": true}");
  });

  server.on("/is-connected", []() {
    server.send(200, "application/json", connected ? "{\"isConnected\": true}" : "{\"isConnected\": false}");
  });

  server.begin();
}

void loop() {
  server.handleClient();
  if (connected) {
    if (!welcomeMessagePrinted && (!mfrc522.PICC_IsNewCardPresent() || !mfrc522.PICC_ReadCardSerial())) {
      lcd.clear();
      lcd.setCursor(3, 0);
      lcd.print("Tap Kartu!");
      welcomeMessagePrinted = true;
    }

    if (!mfrc522.PICC_IsNewCardPresent() || !mfrc522.PICC_ReadCardSerial()) {
      return;
    }

    lcd.clear();
    BEEP(1, 200);
    lcd.setCursor(2, 0);
    lcd.print("Memproses...");
    String content = "";
    byte letter;

    for (byte i = 0; i < mfrc522.uid.size; i++) {
      content.concat(String(mfrc522.uid.uidByte[i] < 0x10 ? "-0" : "-"));
      content.concat(String(mfrc522.uid.uidByte[i], HEX));
    }
    content.toUpperCase();
    Serial.println(content);

    welcomeMessagePrinted = false;
    delay(1000);
  }
}

void BEEP(int count, int duration) {
  for (int i = 0; i < count; i++) {
    digitalWrite(buzzerPin, HIGH);
    delay(duration);
    digitalWrite(buzzerPin, LOW);
    delay(duration);
  }
}