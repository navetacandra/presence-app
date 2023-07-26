const express = require("express");
const bodyParser = require("body-parser");
const { readFileSync, writeFileSync, unlinkSync } = require("fs");
const { cwd } = require("process");
const { join, resolve } = require("path");
const Controller = require("./controller");
const {
  get,
  ref,
  query,
  orderByChild,
  equalTo,
  update,
} = require("firebase/database");
require("dotenv").config();

const app = express();

// [
//   {
//     "key": "KEY",
//     "wa": "WHATSAPP_SESSION",
//     "firebase": {
//        ...
//     },
//     "firebase_email": "FIREBASE_CONTROL_EMAIL",
//     "firebase_password": "FIREBASE_CONTROL_PASSWORD"
//   },
// ]
const states = JSON.parse(
  readFileSync(resolve(join(cwd(), "states.json")), "utf-8")
).map((e) => ({
  key: e.key,
  controller: new Controller(
    e.wa,
    e.firebase,
    e.key,
    e.firebase_email,
    e.firebase_password
  ),
}));

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use((req, res, next) => {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");
  next();
});

app.post("/", async (req, res) => {
  const key = req.body.key || req.query.key;
  if (!key) {
    return res.status(400).json({ message: "KEY not stored." });
  }

  try {
    const {
      code,
      data: { user },
    } = await states.filter((f) => f.key == key)[0].controller.whatsapp.getMe();
    res.status(code).json({
      isReady: states.filter((f) => f.key == key)[0].controller.whatsapp
        .isReady,
      user,
    });
  } catch (err) {
    res.status(500).json({ message: "QR failed converted.", error: err });
  }
});

app.post("/qr", async (req, res) => {
  const key = req.body.key || req.query.key;
  if (!key) {
    return res.status(400).json({ message: "KEY not stored." });
  }

  try {
    const { code, data } = await states
      .filter((f) => f.key == key)[0]
      .controller.whatsapp.getQR();
    res.status(code).json(data);
  } catch (err) {
    res.status(500).json({ message: "QR failed converted.", error: err });
  }
});

app.post("/info-me", async (req, res) => {
  const key = req.body.key || req.query.key;
  if (!key) {
    return res.status(400).json({ message: "KEY not stored." });
  }

  try {
    const { code, data } = await states
      .filter((f) => f.key == key)[0]
      .controller.whatsapp.getMe();
    res.status(code).json(data);
  } catch (err) {
    res.status(500).json({ message: "Failed get info.", error: err });
  }
});

app.post("/onwhatsapp", async (req, res) => {
  const key = req.body.key || req.query.key;
  if (!key) {
    return res.status(400).json({ message: "KEY not stored." });
  }

  try {
    const { code, data } = await states
      .filter((f) => f.key == key)[0]
      .controller.whatsapp.onWhatsApp(req.body.number || req.query.number);
    res.status(code).json(data);
  } catch (err) {
    res.status(500).json({ message: "Failed get info.", error: err });
  }
});

app.post("/logout", async (req, res) => {
  const key = req.body.key || req.query.key;
  if (!key) {
    return res.status(400).json({ message: "KEY not stored." });
  }

  const { code, data } = await states
    .filter((f) => f.key == key)[0]
    .controller.whatsapp.logout();
  res.status(code).json(data);
});

app.post("/export", async (req, res) => {
  const key = req.body.key || req.query.key;
  if (!key) {
    return res.status(400).json({ message: "KEY not stored." });
  }

  try {
    const { code, data } = await states
      .filter((f) => f.key == key)[0]
      .controller.firebase.exportAbsen(
        (req.body.month || req.query.month) ?? "januari",
        ((req.body.tanggal || req.query.tanggal) ?? "1").split(",")
      );
    res.status(code).json(data);
  } catch (err) {
    res.status(500).json({ message: "Failed get info.", error: err });
  }
});

app.get("/export-csv", async (req, res) => {
  const key = req.body.key || req.query.key;
  if (!key) {
    return res.status(400).json({ message: "KEY not stored." });
  }

  try {
    const {
      code,
      data: { csv },
    } = await states
      .filter((f) => f.key == key)[0]
      .controller.firebase.exportAbsen(
        (req.body.month || req.query.month) ?? "januari",
        ((req.body.tanggal || req.query.tanggal) ?? "1").split(",")
      );
    const filePath = resolve(join(cwd(), Date.now() + ".csv"));
    writeFileSync(filePath, csv, "utf-8");
    res.status(code).send(readFileSync(filePath));
    unlinkSync(filePath);
  } catch (err) {
    res.status(500).json({ message: "Failed get info.", error: err });
  }
});

app.post("/esp-handling", async (req, res) => {
  const key = req.body.key || req.query.key;
  if (!key) {
    return res.status(400).json({ message: "KEY not stored." });
  }

  const firebase = await states.filter((f) => f.key == key)[0].controller
    .firebase;

  const month = req.body.month || req.query.month;
  const date = req.body.date || req.query.date;
  const time = req.body.time || req.query.time;
  const tag = req.body.tag || req.query.tag;

  try {
    if (firebase.mode) {
      const isActive = await get(
        ref(firebase.dbApp, `/absensi/${month}/${date}/details/active`)
      );
      if (!isActive) {
        return res.status(400).json({
          mode: "absen",
          error: "date-not-active",
        });
      } else {
        const currentSiswa = await get(
          query(
            ref(firebase.dbApp, `/siswa`),
            orderByChild(`card`),
            equalTo(tag)
          )
        );
        if (!currentSiswa.exists()) {
          return res
            .status(404)
            .json({ mode: "absen", error: "card-not-found" });
        } else {
          const siswaId = Object.values(currentSiswa.val())[0].id;
          const _absenSiswa = await get(
            ref(
              firebase.dbApp,
              `/absensi/${month}/${date}/siswa/${siswaId}`
            )
          );
          const jamMasukStart = firebase.schedule.jam_hadir_start
            .split(":")
            .map((e) => Number(e));
          const jamMasukEnd = firebase.schedule.jam_hadir_end
            .split(":")
            .map((e) => Number(e));
          const jamPulangStart = firebase.schedule.jam_pulang_start
            .split(":")
            .map((e) => Number(e));
          const jamPulangEnd = firebase.schedule.jam_pulang_end
            .split(":")
            .map((e) => Number(e));
          const currTime = time.split(":").map((e) => Number(e));

          if (
            currTime[0] >= jamMasukStart[0] &&
            currTime[0] <= jamMasukEnd[0]
          ) {
            if (
              _absenSiswa.exists() &&
              _absenSiswa.child("masuk").exists()
            ) {
              return res
                .status(400)
                .json({ mode: "absen", error: "already-absen-hadir" });
            }

            // kurang dari menit awal
            if (
              currTime[0] == jamMasukStart[0] &&
              currTime[1] < jamMasukStart[1]
            ) {
              return res
                .status(400)
                .json({ mode: "absen", error: "no-schedule" });
            }

            // antara jam awal hadir s/d jam akhir hadir
            if (
              currTime[0] > jamMasukStart[0] &&
              currTime[0] < jamMasukEnd[0]
            ) {
              await update(
                ref(
                  firebase.dbApp,
                  `/absensi/${month}/${date}/siswa/${siswaId}`
                ),
                {
                  status: "tepat",
                  masuk: time,
                  id: siswaId,
                }
              );
              return res
                .status(200)
                .json({ mode: "absen", status: "absen-tepat" });
            }

            // lebih dari/sama dengan menit awal
            if (
              currTime[0] == jamMasukStart[0] &&
              currTime[1] >= jamMasukStart[1]
            ) {
              await update(
                ref(
                  firebase.dbApp,
                  `/absensi/${month}/${date}/siswa/${siswaId}`
                ),
                {
                  status: "tepat",
                  masuk: time,
                  id: siswaId,
                }
              );
              return res
                .status(200)
                .json({ mode: "absen", status: "absen-tepat" });
            }

            // kurang dari/sama dengan menit akhir
            if (
              currTime[0] == jamMasukEnd[0] &&
              currTime[1] <= jamMasukEnd[1]
            ) {
              await update(
                ref(
                  firebase.dbApp,
                  `/absensi/${month}/${date}/siswa/${siswaId}`
                ),
                {
                  status: "tepat",
                  masuk: time,
                  id: siswaId,
                }
              );
              return res
                .status(200)
                .json({ mode: "absen", status: "absen-tepat" });
            }

            // kurang dari/sama dengan 15 menit akhir jam hadir
            if (
              currTime[0] == jamMasukEnd[0] &&
              currTime[1] > jamMasukEnd[1] &&
              currTime[1] <= jamMasukEnd[1] + 15
            ) {
              await update(
                ref(
                  firebase.dbApp,
                  `/absensi/${month}/${date}/siswa/${siswaId}`
                ),
                {
                  status: "telat",
                  masuk: time,
                  id: siswaId,
                }
              );
              return res
                .status(200)
                .json({ mode: "absen", status: "absen-telat" });
            }

            // lebih dari 15 menit akhir jam hadir
            if (
              currTime[0] == jamMasukEnd[0] &&
              currTime[1] > jamMasukEnd[1] + 15
            ) {
              return res
                .status(400)
                .json({ mode: "absen", error: "no-schedule" });
            }
          }

          if (
            currTime[0] > jamMasukEnd[0] + 15 &&
            currTime[0] < jamPulangStart[0]
          ) {
            return res
              .status(400)
              .json({ mode: "absen", error: "no-schedule" });
          }

          if (
            currTime[0] >= jamPulangStart[0] &&
            currTime[0] <= jamPulangEnd[0]
          ) {
            if (
              _absenSiswa.exists() &&
              _absenSiswa.child("pulang").exists()
            ) {
              return res
                .status(400)
                .json({ mode: "absen", error: "already-absen-pulang" });
            }

            // lebih dari/sama dengan menit awal pulang
            if (
              currTime[0] == jamPulangStart[0] &&
              currTime[1] >= jamPulangStart[1]
            ) {
              await update(
                ref(
                  firebase.dbApp,
                  `/absensi/${month}/${date}/siswa/${siswaId}`
                ),
                {
                  masuk: time,
                  id: siswaId,
                }
              );
              return res
                .status(200)
                .json({ mode: "absen", status: "absen-pulang" });
            }

            // antara jam awal pulang s/d jam akhir pulang
            if (
              currTime[0] > jamPulangStart[0] &&
              currTime[0] < jamPulangEnd[0]
            ) {
              await update(
                ref(
                  firebase.dbApp,
                  `/absensi/${month}/${date}/siswa/${siswaId}`
                ),
                {
                  masuk: time,
                  id: siswaId,
                }
              );
              return res
                .status(200)
                .json({ mode: "absen", status: "absen-pulang" });
            }

            // kurang dari/sama dengan menit akhir pulang
            if (
              currTime[0] == jamPulangEnd[0] &&
              currTime[1] <= jamPulangEnd[1]
            ) {
              await update(
                ref(
                  firebase.dbApp,
                  `/absensi/${month}/${date}/siswa/${siswaId}`
                ),
                {
                  masuk: time,
                  id: siswaId,
                }
              );
              return res
                .status(200)
                .json({ mode: "absen", status: "absen-pulang" });
            }
          }
        }
      }
    } else {
      const card = await get(ref(firebase.dbApp, `/cards/${tag}/card`));
      const cardInSiswa = await get(
        query(
          ref(firebase.dbApp, `/siswa`),
          orderByChild(`card`),
          equalTo(tag)
        )
      );

      if (card.exists()) {
        return res.status(400).json({ mode: "add", error: "already-add" });
      }
      if (cardInSiswa.exists()) {
        return res
          .status(400)
          .json({ mode: "add", error: "already-registered" });
      }

      if (!(card.exists() && cardInSiswa.exists())) {
        await update(ref(firebase.dbApp, `/cards/${tag}`), { card: tag });
        return res.status(200).json({ mode: "add", status: "registered" });
      }
    }
  } catch (err) {
    console.log(err);
  }
});

app.listen(process.env.PORT || 3000);
