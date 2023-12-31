const { initializeApp } = require("firebase/app");
const { getDatabase, ref, set } = require("firebase/database");
const { writeFileSync } = require("fs");
require("dotenv").config();

const app = initializeApp({
  "apiKey": "AIzaSyD-JP8GCi27H55NBuh3nNhVMS4UzU0B6As",
  "authDomain": "ma5ter-absensi.firebaseapp.com",
  "databaseURL": "https://ma5ter-absensi-default-rtdb.asia-southeast1.firebasedatabase.app",
  "projectId": "ma5ter-absensi",
  "storageBucket": "ma5ter-absensi.appspot.com",
  "messagingSenderId": "199771004996",
  "appId": "1:199771004996:web:4b93e9d4a1c318162d9c11",
  "measurementId": "G-4WZS5RF9C0"
});
const db = getDatabase(app);
const arg = process.argv[2];

const months = [
  "januari",
  "februari",
  "maret",
  "april",
  "mei",
  "juni",
  "juli",
  "agustus",
  "september",
  "oktober",
  "november",
  "desember",
];

const obj = {};
const tgl_obj = {};

const template_detail = {
  jam_hadir_start: "00:01",
  jam_hadir_end: "06:45",
  jam_pulang_start: "15:00",
  jam_pulang_end: "23:00",
};

Array(31)
  .fill(0)
  .map((_, i) => {
    tgl_obj[i + 1] = {
      siswa: [],
      details: {
        mode: true,
        active: true,
        ...template_detail,
      },
    };
  });

months.forEach((e) => {
  obj[e] = tgl_obj;
});

if (arg == "setup-db") {
  set(ref(db, "schedule"), template_detail);
  set(ref(db, "absensi"), obj);
}

if (arg == "setup-rules") {
  const rules = {
    ".read": "auth.uid != null",
    ".write": "auth.uid != null",
    siswa: {
      ".indexOn": ["uid", "card", "email"],
    },
    users: {
      ".indexOn": ["uid", "card", "email"],
      $uid: {
        password: {
          ".read": "auth.uid != null || auth.uid == ''",
          ".write": "auth.uid != null || auth.uid == ''",
        },
      },
    },
    absensi: {}
  };
  months.forEach((e) => {
    rules.absensi[e] = {};
    Array(31)
    .fill(0)
    .map((_, i) => i + 1)
    .forEach((el) => {
        rules.absensi[e][el] = {
          siswa: {".indexOn": ["id", "card"]}
        };
      });
  });
  writeFileSync("./dbrules.json", JSON.stringify({rules}, null, 2).split(`
          "siswa": {
            ".indexOn": [
              "id",
              "card"
            ]
          }
        `).join(` "siswa": { ".indexOn": [ "id", "card" ] } `));
}
