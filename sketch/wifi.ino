// Connect To WiFi
bool initWiFi() {
  if (ssid == "") {
    Serial.println("Undefined SSID.");
    return false;
  }

  WiFi.mode(WIFI_STA);

  WiFi.begin(ssid.c_str(), pass.c_str());

  int retries = 0;
  while ((WiFi.status() != WL_CONNECTED) && (retries < 15)) {
    retries++;
    delay(500);
    Serial.print(".");
  }

  if (retries > 14) {
    lcd.clear();
    lcd.setCursor(3, 0);
    lcd.print("WiFi Gagal");
    lcd.setCursor(5, 1);
    lcd.print("Terhubung");
    delay(1000);
    lcd.clear();

    return false;
  }
  if (WiFi.status() == WL_CONNECTED) {
    ipaddress = WiFi.localIP().toString();
    lcd.clear();
    lcd.setCursor(1, 0);
    lcd.print("WiFi Terhubung");
    delay(1000);
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print(ipaddress);
    delay(1000);
    lcd.clear();
    connected = true;

    firebaseConnect();

    return true;
  }

  return true;
}

// Server handler when not connected
void handleNetworkConnecting() {
  lcd.setCursor(0, 0);
  lcd.print("Konfigurasi WiFi");

  WiFi.softAP("ESP WIFI MANAGER");
  WiFi.softAPConfig(localIP, localGateway, subnet);

  IPAddress IP = WiFi.softAPIP();

  server.on("/", []() {
    String content = "<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"UTF-8\" /><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\" /><title>ESP WIFI MANAGER</title><style>* {margin: 0;padding: 0;}body {background-color: rgb(180, 180, 180);min-width: 100vw;min-height: 100vh;display: flex;justify-content: center;align-items: center;text-align: center;font-family: Arial, Helvetica, sans-serif;}.container {background-color: rgb(255, 255, 255);width: 80vw;min-height: 80vh;height: 100%;border-radius: 10px;box-shadow: 3px 3px 5px 3px rgba(0, 0, 0, 0.25);-webkit-box-shadow: 3px 3px 5px 3px rgba(0, 0, 0, 0.25);-moz-box-shadow: 3px 3px 5px 3px rgba(0, 0, 0, 0.25);}.wifi-list {text-align: start;padding: 0;}li {padding: 1rem 0;list-style: none;}li > span {margin-left: 2rem;font-weight: 500;}li > span::before {content: \"=> \";font-weight: 700;}li > i {float: right;margin-right: 5rem;width: 1.25rem;height: 1.25rem;}li:nth-child(even) {background-color: rgba(140, 140, 140, 0.25);}form {display: flex;flex-direction: column;align-items: start;padding: 1rem 2rem;}label {margin-bottom: 0.5rem;}input {width: 98%;padding: 0.5rem;border-radius: 5px;border: 1px solid #000;margin-bottom: 1rem;}.submit-container {width: 100%;}.submit {border: none;background-color: #3d2def;color: #fff;padding: 0.75rem 1.25rem;border-radius: 10px;cursor: pointer;float: right;}@media screen and (max-width: 644px) {.container {width: 98vw;}li > span {margin-left: 1rem;}li > i {margin-right: 1rem;}}</style></head><body><div class=\"container\"><ul class=\"wifi-list\">";
    int wifiListLength = WiFi.scanNetworks();
    for (int i = 0; i < wifiListLength; i++) {
      content += "<li>";
      content += "<span>";
      content += WiFi.SSID(i);
      content += "</span>";
      content += (WiFi.encryptionType(i) == ENC_TYPE_NONE) ? "<i class=\"unlock\"></i>" : "<i class=\"lock\"></i>";
      content += "</li>";
    }
    content += "</ul><hr><form action=\"/connect\" method=\"get\"><label for=\"ssid\">SSID</label><input type=\"text\" id=\"ssid\" name=\"ssid\" placeholder=\"SSID\" required><label for=\"password\">Password</label><input type=\"password\" id=\"password\" name=\"password\" placeholder=\"Password\" required>";
    content += "<label for=\"firebaseHost\">Firebase Host</label><input type=\"text\" id=\"firebaseHost\" name=\"firebaseHost\" placeholder=\"Firebase Host\" ";
    content += "value=\"";
    content += firebaseHost;
    content += "\" required>";
    content += "<label for=\"firebaseKey\">Firebase APIKEY</label><input type=\"text\" id=\"firebaseKey\" name=\"firebaseKey\" placeholder=\"Firebase APIKEY\" ";
    content += "value=\"";
    content += firebaseKey;
    content += "\" required>";
    content += "<label for=\"firebaseEmail\">Firebase Auth Email</label><input type=\"text\" id=\"firebaseEmail\" name=\"firebaseEmail\" placeholder=\"Firebase Auth Email\" ";
    content += "value=\"";
    content += firebaseAuthEmail;
    content += "\" required>";
    content += "<label for=\"firebasePass\">Firebase Auth Password</label><input type=\"text\" id=\"firebasePass\" name=\"firebasePass\" placeholder=\"Firebase Auth Password\" ";
    content += "value=\"";
    content += firebaseAuthPassword;
    content += "\" required>";
    content += "<div class=\"submit-container\"><button type=\"submit\" class=\"submit\">SUBMIT</button></div></form></div></body><script>document.querySelectorAll(\"li\").forEach((el) => {el.addEventListener(\"click\", (e) => {document.querySelector(\"#ssid\").value =el.querySelector(\"span\").innerText;});});document.querySelectorAll(\".unlock\").forEach((el) => {el.innerHTML ='<svg xmlns=\"http://www.w3.org/2000/svg\" class=\"ionicon\" viewBox=\"0 0 512 512\"><path d=\"M368 192H192v-80a64 64 0 11128 0 16 16 0 0032 0 96 96 0 10-192 0v80h-16a64.07 64.07 0 00-64 64v176a64.07 64.07 0 0064 64h224a64.07 64.07 0 0064-64V256a64.07 64.07 0 00-64-64z\"/></svg>';});document.querySelectorAll(\".lock\").forEach((el) => {el.innerHTML ='<svg xmlns=\"http://www.w3.org/2000/svg\" class=\"ionicon\" viewBox=\"0 0 512 512\"><path d=\"M368 192h-16v-80a96 96 0 10-192 0v80h-16a64.07 64.07 0 00-64 64v176a64.07 64.07 0 0064 64h224a64.07 64.07 0 0064-64V256a64.07 64.07 0 00-64-64zm-48 0H192v-80a64 64 0 11128 0z\"/></svg>';});</script></html>";
    server.send(200, "text/html", content);
  });

  server.on("/connect", []() {
    for (int i = 0; i < server.args(); i++) {
      if (server.argName(i) == "ssid") {
        writeFile(LittleFS, "/ssid.txt", server.arg(i).c_str());
      }
      if (server.argName(i) == "password") {
        writeFile(LittleFS, "/pass.txt", server.arg(i).c_str());
      }
      if (server.argName(i) == "firebaseHost") {
        writeFile(LittleFS, "/host.txt", server.arg(i).c_str());
      }
      if (server.argName(i) == "firebaseKey") {
        writeFile(LittleFS, "/apikey.txt", server.arg(i).c_str());
      }
      if (server.argName(i) == "firebaseEmail") {
        writeFile(LittleFS, "/auth-email.txt", server.arg(i).c_str());
      }
      if (server.argName(i) == "firebasePass") {
        writeFile(LittleFS, "/auth-pass.txt", server.arg(i).c_str());
      }
    }
    server.send(200, "application/json", "{\"status\": \"sent\"}");
    lcd.clear();
    delay(1500);
    ESP.reset();
  });
}