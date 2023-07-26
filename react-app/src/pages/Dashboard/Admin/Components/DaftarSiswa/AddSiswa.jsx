import PropTypes from "prop-types";
import { v4 as uuidv4 } from "uuid";
import { get, ref, update } from "firebase/database";
import { useState } from "react";
import { db } from "../../../../../firebase";

export default function AddSiswa({ triggerRefresh }) {
  const [open, setOpen] = useState(false);
  const [load, setLoad] = useState(false);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [telSiswa, setTelSiswa] = useState("");
  const [telWaliKelas, setTelWaliKelas] = useState("");
  const [telPJ, setTelPJ] = useState("");

  const validPhone = async (phone) => {
    const res = await fetch(
      `http://103.181.183.181:3000/onwhatsapp?key=ma5terabsensi&number=${phone}`,
      {
        method: "POST",
      }
    );
    return res.status;
  };
  const emailRegex =
    /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(?:\.[a-zA-Z]{2,})?$/;

  const addSiswaToDB = async () => {
    const uid = uuidv4().replace(/-/g, "");
    const _ssw = await get(ref(db, `/siswa/${uid}`));
    if (_ssw.exists()) addSiswaToDB();
    else {
      await update(ref(db, `/siswa/${uid}`), {
        name: name.trim(),
        email: email.trim(),
        telSiswa: telSiswa.trim(),
        telWaliKelas: telWaliKelas.trim(),
        id: uid,
        telWaliMurid: telPJ.trim(),
      });
    }
  };

  async function addSiswa(e) {
    e.preventDefault();
    if (!load) {
      setLoad(true);

      const _validTelSiswa = await validPhone(telSiswa.trim());
      const _validTelWaliKelas = await validPhone(telWaliKelas.trim());
      const _validTelPJ = await validPhone(telPJ.trim());

      if (name.trim().length < 1) alert("Nama wajib di-isi!");
      else if (email.trim().length < 1) alert("Email wajib di-isi!");
      else if (email.trim().length >= 1 && !emailRegex.test(email))
        alert("Email tidak valid!");
      else if (
        email.trim().length >= 1 &&
        emailRegex.test(email) &&
        !email.endsWith("gmail.com")
      )
        alert("Email harus beralamat gmail.com!");
      else if (telSiswa.trim().length < 1)
        alert("WhatsApp siswa wajib di-isi!");
      else if (telSiswa.trim().length >= 1 && _validTelSiswa == 500)
        alert("Gagal mengecek nomor WhatsApp siswa!");
      else if (telSiswa.trim().length >= 1 && _validTelSiswa == 400)
        alert("Gagal mengecek nomor WhatsApp siswa!");
      else if (telSiswa.trim().length >= 1 && _validTelSiswa == 404)
        alert("Nomor WhatsApp siswa tidak terdaftar!");
      else if (telWaliKelas.trim().length < 1)
        alert("WhatsApp atasan wajib di-isi!");
      else if (telWaliKelas.trim().length >= 1 && _validTelWaliKelas == 500)
        alert("Gagal mengecek nomor WhatsApp atasan!");
      else if (telWaliKelas.trim().length >= 1 && _validTelWaliKelas == 400)
        alert("Gagal mengecek nomor WhatsApp atasan!");
      else if (telWaliKelas.trim().length >= 1 && _validTelWaliKelas == 404)
        alert("Nomor WhatsApp atasan tidak terdaftar!");
      else if (telPJ.trim().length < 1) alert("WhatsApp PJ wajib di-isi!");
      else if (telPJ.trim().length >= 1 && _validTelPJ == 500)
        alert("Gagal mengecek nomor WhatsApp PJ!");
      else if (telPJ.trim().length >= 1 && _validTelPJ == 400)
        alert("Gagal mengecek nomor WhatsApp PJ!");
      else if (telPJ.trim().length >= 1 && _validTelPJ == 404)
        alert("Nomor WhatsApp PJ tidak terdaftar!");
      else {
        try {
          await addSiswaToDB();
          e.target.reset();
          setName("");
          setEmail("");
          setTelSiswa("");
          setTelWaliKelas("");
          setTelPJ("");
          triggerRefresh();
          alert("Siswa berhasil ditambahkan!");
        } catch (error) {
          console.log(error);
          alert("Siswa gagal ditambahkan!");
        }
      }

      setLoad(false);
    }
  }

  return (
    <section className="mb-3">
      <h4
        className="d-flex align-items-center"
        onClick={() => setOpen(!open)}
        style={{ cursor: "pointer" }}
      >
        Tambah Siswa
        <i
          className="ms-2 fs-6 bi bi-caret-right-fill my-auto add-ssw-caret"
          onClick={() => setOpen(!open)}
          style={
            open
              ? { transform: "rotate(90deg)", transition: "all .5s" }
              : { transform: "rotate(0deg)", transition: "all .5s" }
          }
        ></i>
      </h4>
      <div
        className="a-content col-8 mx-auto"
        style={
          open
            ? {
                visibility: "visible",
                opacity: "1",
                height: "auto",
                transition: "all .3s",
              }
            : {
                visibility: "hidden",
                opacity: "0",
                height: "0",
                transition: "all .3s",
              }
        }
      >
        <div className="card shadow">
          <div className="card-body">
            <h5 className="text-center">Tambah Siswa</h5>
            <form onSubmit={(e) => addSiswa(e)}>
              <div className="mb-3">
                <label htmlFor="nama" className="form-label">
                  Nama
                </label>
                <input
                  type="text"
                  className="form-control"
                  id="nama"
                  placeholder="Nama"
                  onInput={(e) => setName(e.target.value)}
                />
              </div>
              <div className="mb-3">
                <label htmlFor="email" className="form-label">
                  Email
                </label>
                <input
                  type="email"
                  className="form-control"
                  id="email"
                  placeholder="employee@gmail.com"
                  onInput={(e) => setEmail(e.target.value)}
                />
              </div>
              <div className="mb-3">
                <label htmlFor="telSiswa" className="form-label">
                  WhatsApp Siswa
                </label>
                <input
                  type="tel"
                  className="form-control"
                  id="telSiswa"
                  placeholder="WhatsApp Siswa"
                  onInput={(e) => setTelSiswa(e.target.value)}
                />
              </div>
              <div className="mb-3">
                <label htmlFor="telWaliKelas" className="form-label">
                  WhatsApp Wali Kelas
                </label>
                <input
                  type="tel"
                  className="form-control"
                  id="telWaliKelas"
                  placeholder="WhatsApp Wali Kelas"
                  onInput={(e) => setTelWaliKelas(e.target.value)}
                />
              </div>
              <div className="mb-3">
                <label htmlFor="telPJ" className="form-label">
                  WhatsApp PJ
                </label>
                <input
                  type="tel"
                  className="form-control"
                  id="telPJ"
                  placeholder="WhatsApp Wali Murid"
                  onInput={(e) => setTelPJ(e.target.value)}
                />
              </div>
              <div className="d-flex justify-content-center">
                <button
                  type="submit"
                  className={
                    "btn btn-primary col-8" + (load ? " disabled" : "")
                  }
                >
                  {load ? (
                    <div className="spinner-border text-light" role="status">
                      <span className="visually-hidden">Loading...</span>
                    </div>
                  ) : (
                    "Tambah Siswa"
                  )}
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </section>
  );
}

AddSiswa.propTypes = {
  triggerRefresh: PropTypes.func,
};
