
// Import library
#include <ESP8266WebServer.h>
#include <Arduino_JSON.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClient.h>
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
String apikey;
String ipaddress;

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
  apikey = readFile(LittleFS, "/apikey.txt");

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
    content += "\"apikey\": \"";
    content += apikey;
    content += "\"}";
    server.send(200, "application/json", content);
  });

  server.on("/is-esp", []() {
    server.send(200, "application/json", "{\"isEsp\": true}");
  });

  server.on("/is-connected", []() {
    server.send(200, "application/json", connected ? "{\"isConnected\": true}" : "{\"isConnected\": false}");
  });

  if(connected) {
    server.on("/reset-esp", []() {
      server.send(200, "application/json", "{\"reset\": true}");
      lcd.clear();
      lcd.setCursor(3, 0);
      lcd.print("RESET ESP");
      delay(1000);
      lcd.clear();
      ESP.reset();
    });

    server.on("/delete-config", []() {
      server.send(200, "application/json", "{\"delete\": true}");
      lcd.clear();
      lcd.setCursor(2, 0);
      lcd.print("DELETE CONFIG");
      writeFile(LittleFS, "/ssid.txt", String("").c_str());
      writeFile(LittleFS, "/pass.txt", String("").c_str());
      writeFile(LittleFS, "/apikey.txt", String("").c_str());
      delay(1000);
      lcd.clear();
      ESP.reset();
    });
  }

  server.begin();
}

void loop() {
  server.handleClient();
  if (connected) {
    if (!welcomeMessagePrinted && (!mfrc522.PICC_IsNewCardPresent() || !mfrc522.PICC_ReadCardSerial())) {
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
    BEEP(1, 80);
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

    httpRequest(content);
    BEEP(2, 80);
    delay(510);

    welcomeMessagePrinted = false;
    delay(250);
  }
}

void BEEP(int count, int duration) {
  int i = 0;
  for (i = 0; i < count; i++) {
    digitalWrite(buzzerPin, HIGH);
    delay(duration);
    digitalWrite(buzzerPin, LOW);
    if(i+1 < count) {
      delay(duration);
    }
  }
}

void httpRequest(String tag) {
  timeClient.update();
  time_t epochTime = timeClient.getEpochTime();
  struct tm *ptm = gmtime((time_t *)&epochTime);
  int currentMonth = ptm->tm_mon;
  int monthDay = ptm->tm_mday;
  int currentHour = timeClient.getHours();
  int currentMinute = timeClient.getMinutes();

  String time = String(currentHour).length() > 1 ? String(currentHour) : ("0" + String(currentHour));
  time += ":";
  time += String(currentMinute).length() > 1 ? String(currentMinute) : ("0" + String(currentMinute));

  WiFiClient client;
  HTTPClient http;

  String serverPath = "http://103.181.183.181:3000/esp-handling";
  serverPath += "?nocache=" + String(millis());

  http.setReuse(false);
  http.begin(client, serverPath.c_str());
  http.addHeader("Content-Type", "application/x-www-form-urlencoded");

  String httpRequestData = "key=";
  httpRequestData += apikey;
  httpRequestData += "&tag=";
  httpRequestData += tag;
  httpRequestData += "&date=";
  httpRequestData += String(monthDay);
  httpRequestData += "&month=";
  httpRequestData += months[currentMonth];
  httpRequestData += "&time=";
  httpRequestData += time;

  int httpResponseCode = http.POST(httpRequestData);

  if (httpResponseCode > 0) {
    String _payload = http.getString();
    JSONVar payload = JSON.parse(_payload);
    String mode = String(payload["mode"]);

    if (mode == "absen") {
      if (httpResponseCode == 200) {
        String status = String(payload["status"]);
        Serial.println("Status: " + status);

        if (status == "absen-tepat") {
          lcd.clear();
          lcd.setCursor(1, 0);
          lcd.print("Absen Berhasil");
          lcd.setCursor(1, 1);
          lcd.print("Status: TEPAT");
        } else if (status == "absen-telat") {
          lcd.clear();
          lcd.setCursor(1, 0);
          lcd.print("Absen Berhasil");
          lcd.setCursor(1, 1);
          lcd.print("Status: TELAT");
        } else if (status == "absen-pulang") {
          lcd.clear();
          lcd.setCursor(1, 0);
          lcd.print("Absen Berhasil");
          lcd.setCursor(1, 1);
          lcd.print("Status: PULANG");
        }
      } else {
        String error = String(payload["error"]);
        Serial.println("Error: " + error);

        if (error == "card-not-found") {
          lcd.clear();
          lcd.setCursor(2, 0);
          lcd.print("Kartu Belum");
          lcd.setCursor(3, 1);
          lcd.print("Terdaftar");
        } else if (error == "date-not-active") {
          lcd.clear();
          lcd.setCursor(0, 0);
          lcd.print("Gagal Absen Buka");
          lcd.setCursor(0, 1);
          lcd.print("n Jadwal Absen");
        } else if (error == "no-schedule") {
          lcd.clear();
          lcd.setCursor(3, 0);
          lcd.print("Gagal Absen Buka");
          lcd.setCursor(0, 1);
          lcd.print("n Waktu Absen");
        } else if (error == "already-absen-hadir") {
          lcd.clear();
          lcd.setCursor(0, 0);
          lcd.print("Sudah Melakukan");
          lcd.setCursor(0, 1);
          lcd.print("Absen Kehadiran");
        } else if (error == "already-absen-pulang") {
          lcd.clear();
          lcd.setCursor(0, 0);
          lcd.print("Sudah Melakukan");
          lcd.setCursor(0, 1);
          lcd.print("Absen Pulang");
        }
      }
    } else if(mode == "add") {
      if(httpResponseCode == 200) {
          lcd.clear();
          lcd.setCursor(1, 0);
          lcd.print("Kartu Berhasil");
          lcd.setCursor(2, 1);
          lcd.print("Ditambahkan");
      } else {
        String error = String(payload["error"]);

        if(error == "already-add") {
          lcd.clear();
          lcd.setCursor(1, 0);
          lcd.print("Kartu Sudah");
          lcd.setCursor(2, 1);
          lcd.print("Ditambahkan");
        } else if(error == "already-registered") {
          lcd.clear();
          lcd.setCursor(1, 0);
          lcd.print("Kartu Sudah");
          lcd.setCursor(3, 1);
          lcd.print("Terdaftar");
        }
      }
    }
  } else {
    Serial.print("Error code: ");
    Serial.println(httpResponseCode);
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Terjadi Kesalaha");
    lcd.setCursor(0, 1);
    lcd.print("n Pada Sistem");
  }
  // Free resources
  http.end();
}
