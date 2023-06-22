const express = require("express");
const bodyParser = require("body-parser");
const {readFileSync, writeFileSync, unlinkSync} = require("fs");
const WhatsApp = require("./whatsapp");
const Firebase = require("./firebase");
const { cwd } = require("process");
const { join, resolve } = require("path");

const app = express();
const firebase = new Firebase(WhatsApp);

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.post("/", async (req, res) => {
  try {
    const {
      code,
      data: { user },
    } = await WhatsApp.getMe();
    res.status(code).json({ isReady: WhatsApp.isReady, user });
  } catch (err) {
    res.status(500).json({ message: "QR failed converted.", error: err });
  }
});

app.post("/qr", async (req, res) => {
  try {
    const { code, data } = await WhatsApp.getQR();
    res.status(code).json(data);
  } catch (err) {
    res.status(500).json({ message: "QR failed converted.", error: err });
  }
});

app.post("/info-me", async (req, res) => {
  try {
    const { code, data } = await WhatsApp.getMe();
    res.status(code).json(data);
  } catch (err) {
    res.status(500).json({ message: "Failed get info.", error: err });
  }
});

app.post("/onwhatsapp", async (req, res) => {
  try {
    console.log(req.body);
    const { code, data } = await WhatsApp.onWhatsApp(
      req.body.number || req.query.number
    );
    res.status(code).json(data);
  } catch (err) {
    res.status(500).json({ message: "Failed get info.", error: err });
  }
});

app.post("/logout", async (req, res) => {
  const { code, data } = await WhatsApp.logout();
  res.status(code).json(data);
});

app.post("/export", async (req, res) => {
  try {
    const { code, data } = await firebase.exportAbsen(
      (req.body.month || req.query.month) ?? "januari",
      ((req.body.tanggal || req.query.tanggal) ?? "1").split(",")
    );
    res.status(code).json(data);
  } catch (err) {
    console.log(err);
    res.status(500).json({ message: "Failed get info.", error: err });
  }
});

app.post("/export-csv", async (req, res) => {
  try {
    const {
      code,
      data: { csv },
    } = await firebase.exportAbsen(
      (req.body.month || req.query.month) ?? "januari",
      ((req.body.tanggal || req.query.tanggal) ?? "1").split(",")
    );
    const filePath = resolve(join(cwd(), Date.now() + '.csv'));
    writeFileSync(filePath, csv, 'utf-8');
    res.status(code).sendFile(filePath);
    unlinkSync(filePath)
  } catch (err) {
    console.log(err);
    res.status(500).json({ message: "Failed get info.", error: err });
  }
});

app.listen(3000);
