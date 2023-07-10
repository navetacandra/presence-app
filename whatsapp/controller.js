const Firebase = require("./firebase");
const WhatsApp = require("./whatsapp");

class Controller {
  constructor(whatsapp, firebase, name, femail, fpass) {
    this.whatsapp = new WhatsApp(whatsapp, name);
    this.firebase = new Firebase(firebase, this.whatsapp, name, femail, fpass);
  }
}

module.exports = Controller;