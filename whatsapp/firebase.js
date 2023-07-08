const { initializeApp } = require("firebase/app");
const {
  getAuth,
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  deleteUser,
  signOut,
} = require("firebase/auth");
const {
  getDatabase,
  onChildAdded,
  update,
  remove,
  get,
  ref,
  query,
  orderByChild,
  equalTo,
  onChildChanged,
  onValue,
  onChildRemoved,
} = require("firebase/database");
const { AES, enc } = require("crypto-js");
require("dotenv").config();

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

class Firebase {
  constructor(configuration = {}, WA = null, name = "default", controlEmail, controlPassword) {
    this.encryptionAlgorithm = "aes-256-cbc";
    this.encryptionKey = "presence key";
    this.mainEmail = controlEmail;
    this.mainPassword = controlPassword;
    this.mainApp = initializeApp(configuration, name);
    this.authApp = getAuth(this.mainApp);
    this.dbApp = getDatabase(this.mainApp);
    this.MOBJ = {};
    this.WA = WA;
    this.firstRun = true;

    const tgl_obj = {};
    Array(31)
      .fill(0)
      .map((_, i) => {
        tgl_obj[i + 1] = {};
      });
    months.forEach((e) => {
      this.MOBJ[e] = tgl_obj;
    });

    this.#setup();
  }

  async #setup() {
    await signOut(this.authApp);
    signInWithEmailAndPassword(this.authApp, this.mainEmail, this.mainPassword)
      .then(() => {
        console.log("Firebase intialize");
        this.streamMode();
        this.streamSchedule();
        this.streamDeletePegawai();
        this.streamAbsensi();
      })
      .catch((err) => console.log(err));
  }

  async createAccount(name, email, pass) {
    try {
      await signOut(this.authApp);
      signInWithEmailAndPassword(
        this.authApp,
        this.mainEmail,
        this.mainPassword
      ).catch((err) => console.log(err));
      const u = await createUserWithEmailAndPassword(this.authApp, email, pass);
      await update(ref(this.dbApp, `users/${u.user.uid}`), {
        name,
        email,
        uid: u.user.uid,
        password: AES.encrypt(pass, this.encryptionKey).toString(),
        role: 3,
      });
      await signOut(this.authApp);
      signInWithEmailAndPassword(
        this.authApp,
        this.mainEmail,
        this.mainPassword
      ).catch((err) => console.log(err));
      return {
        code: 200,
        response: u,
      };
    } catch (err) {
      return {
        code: 400,
        response: err.code,
      };
    }
  }

  async deleteAccount(email) {
    await signOut(this.authApp);
    await signInWithEmailAndPassword(
      this.authApp,
      this.mainEmail,
      this.mainPassword
    );
    const target = await get(
      query(ref(this.dbApp, `users/`), orderByChild("email"), equalTo(email))
    );
    if (!target.exists()) {
      return {
        code: 404,
        response: "user-not-found",
      };
    }

    const targetPass = AES.decrypt(
      Object.values(target.val())[0].password,
      this.encryptionKey
    ).toString(enc.Utf8);
    try {
      await signOut(this.authApp);
      const u = await signInWithEmailAndPassword(
        this.authApp,
        email,
        targetPass
      );
      await deleteUser(u.user);
      await signOut(this.authApp);
      await signInWithEmailAndPassword(
        this.authApp,
        this.mainEmail,
        this.mainPassword
      );
      await remove(ref(this.dbApp, `users/${Object.keys(target.val())[0]}`));
      return {
        code: 200,
        response: `${email}-was-deleted`,
      };
    } catch (err) {
      return {
        code: 400,
        response: err.code,
      };
    }
  }

  streamSchedule() {
    onValue(ref(this.dbApp, "schedule"), (snap) => {
      months.forEach((mth) => {
        Array(31)
          .fill(0)
          .map((_, i) => i + 1)
          .forEach((dy) => {
            update(ref(this.dbApp, `absensi/${mth}/${dy}/details`), snap.val());
          });
      });
    });
  }

  streamMode() {
    onValue(ref(this.dbApp, "mode"), (snap) => {
      months.forEach((mth) => {
        Array(31)
          .fill(0)
          .map((_, i) => i + 1)
          .forEach((dy) => {
            update(ref(this.dbApp, `absensi/${mth}/${dy}/details`), {
              [snap.key]: snap.val(),
            });
          });
      });
    });
  }

  streamDeletePegawai() {
    onChildRemoved(ref(this.dbApp, "pegawai"), (snap) => {
      let removedId = snap.key;
      months.forEach((mth) => {
        Array(31)
          .fill(0)
          .map((_, i) => i + 1)
          .forEach((dy) => {
            remove(
              ref(this.dbApp, `absensi/${mth}/${dy}/pegawai/${removedId}`)
            );
          });
      });
    });
  }

  streamAbsensi() {
    months.forEach((mth) => {
      Array(31)
        .fill(0)
        .map((_, i) => i + 1)
        .forEach(async (dy) => {
          const m = await get(ref(this.dbApp, `absensi/${mth}/${dy}/pegawai`));
          const intialData = Object.values(m.val() ?? {});

          onChildAdded(
            ref(this.dbApp, `absensi/${mth}/${dy}/pegawai`),
            async (snap) => {
              if (intialData.filter((f) => f.id == snap.val().id).length > 0)
                return;

              const d = new Date();
              if (months.indexOf(mth) == d.getMonth() && d.getDate() == dy) {
                if (snap.val().masuk != null) {
                  const pgw = await get(
                    ref(this.dbApp, `/pegawai/${snap.val().id}`)
                  );
                  if (!pgw.exists()) console.log(snap.val().id, "is empty");
                  this.WA.sendMessage(
                    pgw.val()["telPenanggungJawab"],
                    `Saudara *${pgw.val()["name"]}* telah hadir pada pukul *${
                      snap.val().masuk
                    }*`
                  );
                }
              }
            }
          );

          onChildChanged(
            ref(this.dbApp, `absensi/${mth}/${dy}/pegawai`),
            async (snap) => {
              if (intialData.filter((f) => f.id == snap.val().id).length > 0)
                return;

              const d = new Date();
              if (months.indexOf(mth) == d.getMonth() && d.getDate() == dy) {
                if (snap.val().masuk != null && snap.val().pulang != null) {
                  const pgw = await get(
                    ref(this.dbApp, `/pegawai/${snap.val().id}`)
                  );
                  if (!pgw.exists()) console.log(snap.val().id, "is empty");
                  this.WA.sendMessage(
                    pgw.val()["telPenanggungJawab"],
                    `Saudara *${pgw.val().name}* telah pulang pada pukul *${
                      snap.val().pulang
                    }*`
                  );
                }
              }
            }
          );
        });
    });
  }

  async exportAbsen(month = "januari", tanggal = ["1"]) {
    const pgws = await get(ref(this.dbApp, "/pegawai"));
    if (!pgws.exists())
      return { code: 400, data: { message: "Pegawai is empty" } };

    let dataPegawai = (
      await Promise.all(
        Object.values(pgws.val()).map(async (snap) => {
          const dy = tanggal.map(async (tgl) => {
            const a = await get(
              ref(this.dbApp, `/absensi/${month}/${tgl}/pegawai/${snap.id}`)
            );
            return {
              tanggal: tgl,
              status: a.child("status").exists()
                ? a.child("status").val()
                : "alpha",
              hadir: a.child("masuk").exists() ? a.child("masuk").val() : "-",
              pulang: a.child("pulang").exists()
                ? a.child("pulang").val()
                : "-",
            };
          });
          const dataDY = await Promise.all(dy);

          const formatNumber = (number = "0@.us") =>
            number
              .replace("@c.us", "")
              .replace(/\D+/g, "")
              .replace(/(\d{2})(\d{3})(\d{3})(\d)/, "+$1 $2-$3-$4");

          return {
            id: snap.id,
            name: snap.name,
            telPegawai: formatNumber(this.WA.prettifyNumber(snap.telPegawai)),
            telAtasan: formatNumber(this.WA.prettifyNumber(snap.telAtasan)),
            telPenanggungJawab: formatNumber(
              this.WA.prettifyNumber(snap.telPenanggungJawab)
            ),
            dataAbsen: dataDY,
          };
        })
      )
    ).sort((a, b) => a.name - b.name);

    let csvString = `LAPORAN ABSENSI BULAN ${month.toUpperCase()}\n\n`;
    csvString += `No.,ID,Nama,No. Telpon Pegawai,No. Telpon Atasan, No. Telpon Penanggung Jawab,${month.toUpperCase()}\n`;
    csvString += ",,,,,," + tanggal.map((e) => e + ",,").join(",") + "\n";
    csvString +=
      ",,,,,," + "Status,Hadir,Pulang,".repeat(tanggal.length) + "\n";

    dataPegawai.forEach((sn, i) => {
      csvString += `${i + 1},${sn.id},${sn.name},${sn.telPegawai},${
        sn.telAtasan
      },${sn.telPenanggungJawab},`;
      sn.dataAbsen.forEach((ab) => {
        csvString += `${ab.status},${ab.hadir},${ab.pulang},`;
      });
      csvString += i < dataPegawai.length - 1 ? `\n` : "";
    });

    return {
      code: 200,
      data: { csv: csvString, json: dataPegawai },
    };
  }
}

module.exports = Firebase;
