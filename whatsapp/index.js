const express = require("express");
const bodyParser = require("body-parser");
const { readFileSync, writeFileSync, unlinkSync } = require("fs");
const { cwd } = require("process");
const { join, resolve } = require("path");
const Controller = require("./controller");
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
const states = JSON.parse(readFileSync(resolve(join(cwd(), "states.json")), "utf-8")).map((e) => ({
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

app.listen(process.env.PORT || 3000);
