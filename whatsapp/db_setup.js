const { initializeApp } = require("firebase/app");
const { getDatabase, ref, set } = require("firebase/database");
const { writeFileSync } = require("fs");
require("dotenv").config();

const app = initializeApp({});
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
      pegawai: [],
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
    pegawai: {
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
          pegawai: {".indexOn": ["id", "card"]}
        };
      });
  });
  writeFileSync("./dbrules.json", JSON.stringify({rules}, null, 2).split(`
          "pegawai": {
            ".indexOn": [
              "id",
              "card"
            ]
          }
        `).join(` "pegawai": { ".indexOn": [ "id", "card" ] } `));
}
