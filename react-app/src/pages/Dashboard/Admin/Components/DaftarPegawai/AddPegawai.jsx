import PropTypes from "prop-types";
import { v4 as uuidv4 } from "uuid";
import { get, ref, update } from "firebase/database";
import { useState } from "react";
import { db } from "../../../../../firebase";

export default function AddPegawai({ triggerRefresh }) {
  const [open, setOpen] = useState(false);
  const [load, setLoad] = useState(false);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [telPegawai, setTelPegawai] = useState("");
  const [telAtasan, setTelAtasan] = useState("");
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

  const addPegawaiToDB = async () => {
    const uid = uuidv4().replace(/-/g, "");
    const _pgw = await get(ref(db, `/pegawai/${uid}`));
    if (_pgw.exists()) addPegawaiToDB();
    else {
      await update(ref(db, `/pegawai/${uid}`), {
        name: name.trim(),
        email: email.trim(),
        telPegawai: telPegawai.trim(),
        telAtasan: telAtasan.trim(),
        id: uid,
        telPenanggungJawab: telPJ.trim(),
      });
    }
  };

  async function addPegawai(e) {
    e.preventDefault();
    if (!load) {
      setLoad(true);

      const _validTelPegawai = await validPhone(telPegawai.trim());
      const _validTelAtasan = await validPhone(telAtasan.trim());
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
      else if (telPegawai.trim().length < 1)
        alert("WhatsApp pegawai wajib di-isi!");
      else if (telPegawai.trim().length >= 1 && _validTelPegawai == 500)
        alert("Gagal mengecek nomor WhatsApp pegawai!");
      else if (telPegawai.trim().length >= 1 && _validTelPegawai == 400)
        alert("Gagal mengecek nomor WhatsApp pegawai!");
      else if (telPegawai.trim().length >= 1 && _validTelPegawai == 404)
        alert("Nomor WhatsApp pegawai tidak terdaftar!");
      else if (telAtasan.trim().length < 1)
        alert("WhatsApp atasan wajib di-isi!");
      else if (telAtasan.trim().length >= 1 && _validTelAtasan == 500)
        alert("Gagal mengecek nomor WhatsApp atasan!");
      else if (telAtasan.trim().length >= 1 && _validTelAtasan == 400)
        alert("Gagal mengecek nomor WhatsApp atasan!");
      else if (telAtasan.trim().length >= 1 && _validTelAtasan == 404)
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
          await addPegawaiToDB();
          e.target.reset();
          setName("");
          setEmail("");
          setTelPegawai("");
          setTelAtasan("");
          setTelPJ("");
          triggerRefresh();
          alert("Pegawai berhasil ditambahkan!");
        } catch (error) {
          console.log(error);
          alert("Pegawai gagal ditambahkan!");
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
        Tambah Pegawai
        <i
          className="ms-2 fs-6 bi bi-caret-right-fill my-auto add-pgw-caret"
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
            <h5 className="text-center">Tambah Pegawai</h5>
            <form onSubmit={(e) => addPegawai(e)}>
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
                <label htmlFor="telPegawai" className="form-label">
                  WhatsApp Pegawai
                </label>
                <input
                  type="tel"
                  className="form-control"
                  id="telPegawai"
                  placeholder="WhatsApp Pegawai"
                  onInput={(e) => setTelPegawai(e.target.value)}
                />
              </div>
              <div className="mb-3">
                <label htmlFor="telAtasan" className="form-label">
                  WhatsApp Atasan
                </label>
                <input
                  type="tel"
                  className="form-control"
                  id="telAtasan"
                  placeholder="WhatsApp Atasan"
                  onInput={(e) => setTelAtasan(e.target.value)}
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
                  placeholder="WhatsApp Penanggung Jawab"
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
                    "Tambah Pegawai"
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

AddPegawai.propTypes = {
  triggerRefresh: PropTypes.func,
};
