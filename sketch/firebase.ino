void firebaseConnect() {
  fconfig.api_key = firebaseKey;
  fconfig.database_url = firebaseHost;
  fauth.user.email = firebaseAuthEmail;
  fauth.user.password = firebaseAuthPassword;
  fbdo.setBSSLBufferSize(16384, 16384);
  fbdo.setResponseSize(16384);
  Firebase.setMaxRetry(fbdo, 3);
  Firebase.begin(&fconfig, &fauth);
}

// 500 => Error fetch
// 406 => Already added
// 304 => Already registered
// 200 => Success added
int addTag(String tag) {
  QueryFilter query;
  query.orderBy("card");
  query.equalTo(tag);

  String ref = "/cards/";
  ref += tag;
  ref += "/card";

  if (Firebase.getJSON(fbdo, "/pegawai", query)) {
    if (fbdo.jsonString().length() <= 2) {
      if (Firebase.getString(fbdo, ref)) {
        if ((fbdo.to<String>()).length() < 1) {
          if (Firebase.setString(fbdo, ref, tag)) {
            return 200;
          } else {
            Serial.println(fbdo.errorReason());
            return 500;
          }
        } else {
          return 406;
        }
      } else {
        Serial.println(fbdo.errorReason());
        return 500;
      }
    }
    return 304;
  } else {
    Serial.println(fbdo.errorReason());
    return 500;
  }
}

// 0 => No activity scheduled
// 1 => Present success
// 2 => Home success
// 3 => Late
// 3041 => Already present
// 3042 => Already home
// 400 => Not active date
// 404 => No pegawai
// 500 => Error query
int presentTag(String tag, bool active, int startPresent[2], int endPresent[2], int startHome[2], int endHome[2]) {

  // Get current time
  timeClient.update();
  time_t epochTime = timeClient.getEpochTime();
  struct tm *ptm = gmtime((time_t *)&epochTime);
  int currentMonth = ptm->tm_mon;
  int monthDay = ptm->tm_mday;
  int currentHour = timeClient.getHours();
  int currentMinute = timeClient.getMinutes();

  // Get pegawai data
  QueryFilter query;
  query.orderBy("card");
  query.equalTo(tag);

  String pegawaiRef = "/absensi/" + months[currentMonth] + "/" + String(monthDay) + "/pegawai/";

  // Get isActive
  if (active) {
    // Check is card tag registered
    if (Firebase.getJSON(fbdo, "/pegawai", query)) {
      if (fbdo.jsonString().length() <= 2) {
        return 404;
      }
      String id;
      FirebaseJson &tempPegawai = fbdo.jsonObject();
      FirebaseJsonData tempData;
      FirebaseJson data;

      size_t len = tempPegawai.iteratorBegin();
      String key, value = "";
      int type = 0;
      tempPegawai.iteratorGet(0, type, key, value);
      if (value.startsWith("{\"")) {
        data.set("id", key);
        id = key;
      }
      tempPegawai.iteratorEnd();

      if (Firebase.getJSON(fbdo, pegawaiRef + id)) {
        FirebaseJson &fdata = fbdo.to<FirebaseJson>();
        data = fdata;
      } else {
        Serial.println(fbdo.errorReason());
        if (fbdo.errorReason() != "path not exist") {
          return 500;
        }
      }

      // current time to string
      String time = (String(currentHour).length() < 2 ? "0" + String(currentHour) : String(currentHour)) + ":" + (String(currentMinute).length() < 2 ? "0" + String(currentMinute) : String(currentMinute));

      // Equal/above startPresent hour and equal/below endPresent hour
      if (currentHour >= startPresent[0] && currentHour <= endPresent[0]) {
        data.get(tempData, "masuk");
        // If hour equal startPresent hour and minutes below startPresent minutes
        if (currentHour == startPresent[0] && currentMinute < startPresent[1]) {
          return 0;
        }
        // If already presence
        else if (tempData.to<String>().length() > 3) {
          return 3041;
        }
        // If hour equal startPresent hour and minutes equal/above startPresent minutes
        else if (currentHour == startPresent[0] && currentMinute >= startPresent[1]) {
          data.set("status", "tepat");
          data.set("masuk", time);
          if (Firebase.setJSON(fbdo, pegawaiRef + id, data)) {
            // if (true) {
            return 1;
          } else {
            Serial.println(fbdo.errorReason());
            return 500;
          }
        }
        // If hour equal endPresent hour and minutes equal/below endPresent minutes
        else if (currentHour == endPresent[0] && currentMinute <= endPresent[1]) {
          data.set("status", "tepat");
          data.set("masuk", time);
          if (Firebase.setJSON(fbdo, pegawaiRef + id, data)) {
            // if (true) {
            return 1;
          } else {
            Serial.println(fbdo.errorReason());
            return 500;
          }
        }
        // If hour equal endPresent hour and minutes above endPresent minutes
        else if (currentHour == endPresent[0] && currentMinute > endPresent[1]) {
          data.set("status", "telat");
          data.set("masuk", time);
          if (Firebase.setJSON(fbdo, pegawaiRef + id, data)) {
            // if (true) {
            return 3;
          } else {
            Serial.println(fbdo.errorReason());
            return 500;
          }
        } else {
          data.set("status", "tepat");
          data.set("masuk", time);
          if (Firebase.setJSON(fbdo, pegawaiRef + id, data)) {
            // if (true) {
            return 1;
          } else {
            Serial.println(fbdo.errorReason());
            return 500;
          }
        }
      }

      // Between endPresent and startHome
      if (currentHour > endPresent[0] && currentHour < startHome[0]) {
        data.get(tempData, "masuk");
        if (tempData.to<String>().length() > 3) {
          return 3041;
        }
        data.set("status", "telat");
        data.set("masuk", time);
        if (Firebase.setJSON(fbdo, pegawaiRef + id, data)) {
          // if (true) {
          return 3;
        } else {
          Serial.println(fbdo.errorReason());
          return 500;
        }
      }

      // Equal/above startHome hour and equal/below endHome hour
      if (currentHour >= startHome[0] && currentHour <= endHome[0]) {
        data.get(tempData, "pulang");
        // If hour equal startHome hour and minutes below startHome minutes OR hour equal endHome hour and minutes above endHome minutes
        if ((currentHour == startHome[0] && currentMinute < startHome[1]) || (currentHour == endHome[0] && currentMinute > endHome[1])) {
          return 0;
        } else if (tempData.to<String>().length() > 3) {
          return 3042;
        } else {
          data.set("pulang", time);
          if (Firebase.setJSON(fbdo, pegawaiRef + id, data)) {
            // if (true) {
            return 2;
          } else {
            Serial.println(fbdo.errorReason());
            return 500;
          }
        }
      }
    } else {
      Serial.println(fbdo.errorReason());
      return 500;
    }
  } else {
    return 400;
  }

  return 0;
}