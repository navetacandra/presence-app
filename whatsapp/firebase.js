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
  constructor(
    configuration = {},
    WA = null,
    name = "default",
    controlEmail,
    controlPassword
  ) {
    this.name = name;
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
    this.mode = false;
    this.schedule = {};

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
        console.log(`[${this.name}] Firebase intialize`);
        this.streamMode();
        this.streamSchedule();
        this.streamDeleteSiswa();
        this.streamAbsensi();
      })
      .catch((err) => console.log(`[${this.name}] ${err}`));
  }

  async createAccount(name, email, pass) {
    try {
      await signOut(this.authApp);
      signInWithEmailAndPassword(
        this.authApp,
        this.mainEmail,
        this.mainPassword
      ).catch((err) => console.log(`[${this.name}] ${err}`));
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
      ).catch((err) => console.log(`[${this.name}] ${err}`));
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
      console.log(`[${this.name}] Schedule changed`);
      this.schedule = snap.val();
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
      console.log(`[${this.name}] Mode changed`);
      this.mode = snap.val();
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

  streamDeleteSiswa() {
    onChildRemoved(ref(this.dbApp, "siswa"), (snap) => {
      let removedId = snap.key;
      months.forEach((mth) => {
        Array(31)
          .fill(0)
          .map((_, i) => i + 1)
          .forEach((dy) => {
            remove(
              ref(this.dbApp, `absensi/${mth}/${dy}/siswa/${removedId}`)
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
          const m = await get(ref(this.dbApp, `absensi/${mth}/${dy}/siswa`));
          const intialData = Object.values(m.val() ?? {});

          onChildAdded(
            ref(this.dbApp, `absensi/${mth}/${dy}/siswa`),
            async (snap) => {
              if (intialData.filter((f) => f.id == snap.val().id).length > 0)
                return;

              const d = new Date();
              if (months.indexOf(mth) == d.getMonth() && d.getDate() == dy) {
                if (snap.val().masuk != null) {
                  const pgw = await get(
                    ref(this.dbApp, `/siswa/${snap.val().id}`)
                  );
                  if (!pgw.exists()) console.log(`[${this.name}] ${snap.val().id} is empty`);
                  this.WA.sendMessage(
                    pgw.val()["telWaliMurid"],
                    `Saudara *${pgw.val()["name"].trim()}* telah hadir pada pukul *${
                      snap.val().masuk
                    }* tanggal *${d.getDate()}/${
                      months[d.getMonth()]
                    }/${d.getFullYear()}*`
                  );
                }
              }
            }
          );

          onChildChanged(
            ref(this.dbApp, `absensi/${mth}/${dy}/siswa`),
            async (snap) => {
              if (intialData.filter((f) => f.id == snap.val().id).length > 0)
                return;

              const d = new Date();
              if (months.indexOf(mth) == d.getMonth() && d.getDate() == dy) {
                if (snap.val().masuk != null && snap.val().pulang != null) {
                  const pgw = await get(
                    ref(this.dbApp, `/siswa/${snap.val().id}`)
                  );
                  if (!pgw.exists()) console.log(`[${this.name}] ${snap.val().id} is empty`);
                  this.WA.sendMessage(
                    pgw.val()["telWaliMurid"],
                    `Saudara *${pgw.val().name.trim()}* telah pulang pada pukul *${
                      snap.val().pulang
                    }* tanggal *${d.getDate()}/${
                      months[d.getMonth()]
                    }/${d.getFullYear()}*`
                  );
                }
              }
            }
          );
        });
    });
  }

  async exportAbsen(month = "januari", tanggal = ["1"]) {
    const pgws = await get(ref(this.dbApp, "/siswa"));
    if (!pgws.exists())
      return { code: 400, data: { message: "Siswa is empty" } };

    let dataSiswa = (
      await Promise.all(
        Object.values(pgws.val()).map(async (snap) => {
          const dy = tanggal.map(async (tgl) => {
            const a = await get(
              ref(this.dbApp, `/absensi/${month}/${tgl}/siswa/${snap.id}`)
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
            telSiswa: formatNumber(this.WA.prettifyNumber(snap.telSiswa)),
            telWaliKelas: formatNumber(this.WA.prettifyNumber(snap.telWaliKelas)),
            telWaliMurid: formatNumber(
              this.WA.prettifyNumber(snap.telWaliMurid)
            ),
            dataAbsen: dataDY,
          };
        })
      )
    ).sort((a, b) => a.name - b.name);

    let csvString = `LAPORAN ABSENSI BULAN ${month.toUpperCase()}\n\n`;
    csvString += `No.,ID,Nama,WhatsApp Siswa,WhatsApp Atasan, WhatsApp Wali Murid,${month.toUpperCase()}\n`;
    csvString += ",,,,,," + tanggal.map((e) => e + ",,").join(",") + "\n";
    csvString +=
      ",,,,,," + "Status,Hadir,Pulang,".repeat(tanggal.length) + "\n";

    dataSiswa.forEach((sn, i) => {
      csvString += `${i + 1},${sn.id},${sn.name},${sn.telSiswa},${
        sn.telWaliKelas
      },${sn.telWaliMurid},`;
      sn.dataAbsen.forEach((ab) => {
        csvString += `${ab.status},${ab.hadir},${ab.pulang},`;
      });
      csvString += i < dataSiswa.length - 1 ? `\n` : "";
    });

    return {
      code: 200,
      data: { csv: csvString, json: dataSiswa },
    };
  }
}

module.exports = Firebase;
