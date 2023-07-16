// Import library
#include <ESP8266WebServer.h>
#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#include <LiquidCrystal_I2C.h>
#include <LittleFS.h>
#include <MFRC522.h>
#include <NTPClient.h>
#include <WiFiUdp.h>
#include <SPI.h>

// Declare variable
const int lcdColumns = 16;
const int lcdRows = 2;
const uint8_t RSTPIN = D3;
const uint8_t SDAPIN = D4;
const uint8_t buzzerPin = D8;
bool connected = false;
bool welcomeMessagePrinted = false;

String months[12] = { "januari", "februari", "maret", "april", "mei", "juni", "juli", "agustus", "september", "oktober", "november", "desember" };
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
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org");

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

  server.on("/file-state", []() {
    String content = "{";
    content += "\"ssid\": \"";
    content += ssid;
    content += "\",";
    content += "\"password\": \"";
    content += pass;
    content += "\",";
    content += "\"firebase-host\": \"";
    content += firebaseHost;
    content += "\",";
    content += "\"firebase-apikey\": \"";
    content += firebaseKey;
    content += "\",";
    content += "\"auth-email\": \"";
    content += firebaseAuthEmail;
    content += "\",";
    content += "\"auth-pass\": \"";
    content += firebaseAuthPassword;
    content += "\"}";
    server.send(200, "application/json", content);
  });

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
      if(ESP.getFreeHeap() < 9000) {
        fbdo.clear();
      }
      Serial.println("Free Heap: " + String(ESP.getFreeHeap()));
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

    processingDb(content);
    // BEEP(2, 100);

    welcomeMessagePrinted = false;
    delay(250);
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

void processingDb(String tag) {
  // WDT
  timeClient.update();
  time_t epochTime = timeClient.getEpochTime();
  struct tm *ptm = gmtime((time_t *)&epochTime);
  int currentMonth = ptm->tm_mon;
  int monthDay = ptm->tm_mday;
  int currentHour = timeClient.getHours();
  int currentMinute = timeClient.getMinutes();

  String ref = "/absensi/" + months[currentMonth] + "/" + String(monthDay) + "/details";
  if (Firebase.getJSON(fbdo, ref)) {
    FirebaseJson &json = fbdo.to<FirebaseJson>();
    FirebaseJsonData data;

    Serial.println("[Details] Free Heap: " + String(ESP.getFreeHeap()));

    bool mode;
    bool active;
    int startPresent[2];
    int endPresent[2];
    int startHome[2];
    int endHome[2];

    json.get(data, "mode");
    mode = data.to<bool>();
    json.get(data, "active");
    active = data.to<bool>();
    json.get(data, "active");

    // Getting startPresent state
    json.get(data, "jam_hadir_start");
    // Splitting startPresent hour and minutes
    startPresent[0] = data.to<String>().substring(0, 2).toInt();
    startPresent[1] = data.to<String>().substring(3).toInt();

    // Getting endPresent state
    json.get(data, "jam_hadir_end");
    // Splitting endPresent hour and minutes
    endPresent[0] = data.to<String>().substring(0, 2).toInt();
    endPresent[1] = data.to<String>().substring(3).toInt();

    // Getting startHome state
    json.get(data, "jam_pulang_start");
    // Splitting startHome hour and minutes
    startHome[0] = data.to<String>().substring(0, 2).toInt();
    startHome[1] = data.to<String>().substring(3).toInt();

    // Getting endHome state
    json.get(data, "jam_pulang_end");
    // Splitting endHome hour and minutes
    endHome[0] = data.to<String>().substring(0, 2).toInt();
    endHome[1] = data.to<String>().substring(3).toInt();

    if (!mode) {
      addCard(tag);
    } else {
      presentPegawai(tag, active, startPresent, endPresent, startHome, endHome, currentMonth, monthDay, currentHour, currentMinute);
      Serial.println("[Present] Free Heap: " + String(ESP.getFreeHeap()));
    }
  } else {
    Serial.println(fbdo.errorReason());
  }
}

void addCard(String content) {
  int status = addTag(content);
  if (status == 500) {
    lcd.clear();
    lcd.setCursor(1, 0);
    lcd.print("Kesalahan Saat");
    lcd.setCursor(1, 1);
    lcd.print("Menambah Kartu");
    delay(800);
  }
  if (status == 406) {
    lcd.clear();
    lcd.setCursor(2, 0);
    lcd.print("Kartu Sudah");
    lcd.setCursor(2, 1);
    lcd.print("Ditambahkan");
    delay(800);
  }
  if (status == 304) {
    lcd.clear();
    lcd.setCursor(2, 0);
    lcd.print("Kartu Sudah");
    lcd.setCursor(3, 1);
    lcd.print("Terdaftar");
    delay(800);
  }
  if (status == 200) {
    lcd.clear();
    lcd.setCursor(1, 0);
    lcd.print("Kartu Berhasil");
    lcd.setCursor(2, 1);
    lcd.print("Didaftarkan");
    delay(800);
  }
}

void presentPegawai(String content, bool active, int startPresent[2], int endPresent[2], int startHome[2], int endHome[2], int currentMonth, int monthDay, int currentHour, int currentMinute) {
  int status = presentTag(content, active, startPresent, endPresent, startHome, endHome, currentMonth, monthDay, currentHour, currentMinute);
  if (status == 500) {
    lcd.clear();
    lcd.setCursor(1, 0);
    lcd.print("Kesalahan Saat");
    lcd.setCursor(0, 1);
    lcd.print("Melakukan Absen");
    delay(800);
  }
  if (status == 404) {
    lcd.clear();
    lcd.setCursor(2, 0);
    lcd.print("Kartu Belum");
    lcd.setCursor(3, 1);
    lcd.print("Terdaftar");
    delay(800);
  }
  if (status == 400) {
    lcd.clear();
    lcd.setCursor(1, 0);
    lcd.print("Absensi Sedang");
    lcd.setCursor(2, 1);
    lcd.print("Tidak Aktif");
    delay(800);
  }
  if (status == 3041) {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Sudah Melakukan");
    lcd.setCursor(1, 1);
    lcd.print("Absensi Hadir");
    delay(800);
  }
  if (status == 3042) {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Sudah Melakukan");
    lcd.setCursor(1, 1);
    lcd.print("Absensi Pulang");
    delay(800);
  }
  if (status == 3) {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Absensi Berhaseil");
    lcd.setCursor(1, 1);
    lcd.print("Status: TELAT");
    delay(800);
  }
  if (status == 2) {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Absensi Berhaseil");
    lcd.setCursor(1, 1);
    lcd.print("Status: PULANG");
    delay(800);
  }
  if (status == 1) {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Absensi Berhaseil");
    lcd.setCursor(1, 1);
    lcd.print("Status: TEPAT");
    delay(800);
  }
  if (status == 0) {
    lcd.clear();
    lcd.setCursor(1, 0);
    lcd.print("Absensi Gagal");
    lcd.setCursor(0, 1);
    lcd.print("Bukan Waktu Absen");
    delay(800);
  }
}