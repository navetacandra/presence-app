const express = require("express");
const bodyParser = require("body-parser");
const WhatsApp = require("./whatsapp");
const Firebase = require('./firebase');

const app = express();

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

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

app.listen(3000);