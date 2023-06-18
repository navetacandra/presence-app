const { Client, LocalAuth } = require('whatsapp-web.js');
const Qrcode = require("qrcode");
const qrt = require('qrcode-terminal');

class WhatsApp {
  constructor() {
    this.qrcode = "";
    this.socket = null;
    this.isReady = false;
    this.client = new Client({
      restartOnAuthFail: true,
      authStrategy: new LocalAuth({ clientId: 'wa-session' }),
      puppeteer: {
        timeout: 0,
        // executablePath: '/nix/store/x205pbkd5xh5g4iv0g58xjla55has3cx-chromium-108.0.5359.94/bin/chromium-browser',
        // headless: true,
        args: [
          '--no-sandbox',
          '--headless=new',
          '--disable-setuid-sandbox',
          '--disable-dev-shm-usage',
          '--disable-accelerated-2d-canvas',
          '--no-first-run',
          '--no-zygote',
          '--single-process', // <- this one doesn't works in Windows
          '--disable-gpu'
        ],
      },
    })
    
    this.client.on('authenticated', m => {
      this.qrcode = '';
    })
    this.client.on('ready', m => {
      this.isReady = true;
      console.log("WhatsApp is ready.");
    });
    this.client.on('disconnected', async m => {
      this.isReady = false;
      console.log("WhatsApp disconnected.");
      await this.client.initialize();
    });
    this.client.on('qr', qr => {
      this.qrcode = qr;
      qrt.generate(qr, {small: true});
    });
    this.client.initialize();
  }

  // ---------------------------------- logout current session ----------------------------------- //
  async getQR() {
    if (this.qrcode.length > 1) {
      try {
        const _qr = await Qrcode.toDataURL(this.qrcode);
        return { code: 200, data: { qrcode: _qr } };
      } catch (err) {
        return { code: 500, data: { message: "QR failed converted." } };
      }
    }
    return { code: 400, data: { message: "There is no qrcode." } };
  }
  // ------------------------------------- get session info -------------------------------------- //
  async getMe() {
    if (this.isReady) {
      return {
        code: 200,
        data: {
          user: {
            id: this.client.info.wid._serialized,
            name: this.client.info.pushname,
            profilePict: await this.getProfilePict(),
          },
        },
      };
    }
    return { code: 400, data: { message: "No whatsapp connection." } };
  }
  // ---------------------------------- logout current session ----------------------------------- //
  async logout() {
    if (this.isReady) {
      try {
        await this.client.logout();
        this.isReady = false;
        await this.client.initialize();
        return { code: 200, data: {} };
      } catch (error) {
        return { code: 500, data: {} };
      }
    }
    return { code: 400, data: { message: "No whatsapp connection." } };
  }
  // -------------------------------- check number is on whatsapp --------------------------------- //
  async onWhatsApp(number = "0") {
    if (this.isReady) {
      const result = await this.client.isRegisteredUser(this.prettifyNumber(number));
      return {
        code: result ? 200 : 404,
        data: {
          phoneNumber: number,
          isOnWhatsApp: result,
        },
      };
    }
    return { code: 400, data: { message: "No whatsapp connection." } };
  }
  // ---------------------------------- prettify normal number ----------------------------------- //
  prettifyNumber(number = "0") {
    if (number.startsWith("0")) number = "62" + number.substring(1);
    if (!number.endsWith("@c.us"))
      number = number + "@c.us";
    return number;
  }
  // --------------------------------- getting user profile pict --------------------------------- //
  async getProfilePict() {
    try {
      return await this.client.getProfilePicUrl(this.client.info.me._serialized);
    } catch (err) {
      return "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png";
    }
  }
}

module.exports = new WhatsApp();
