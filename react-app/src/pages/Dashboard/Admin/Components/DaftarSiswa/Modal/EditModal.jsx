import { ref, update } from "firebase/database";
import PropTypes from "prop-types";
import { db } from "../../../../../../firebase";
import { useEffect } from "react";

export default function EditModal({ editId, setEditId, allSiswaData, triggerRefresh, refresh }) {
  useEffect(() => {
    document
      .querySelector("#editModal")
      .addEventListener("hidden.bs.modal", () => {
        setEditId("");
        triggerRefresh(!refresh);
      });
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [refresh, editId])
  return (
    <div
      className="modal fade"
      id="editModal"
      tabIndex="-1"
      aria-labelledby="editModalLabel"
      aria-hidden="true"
    >
      <div className="modal-dialog">
        <div className="modal-content">
          <div className="modal-header">
            <h5 className="modal-title" id="editModalLabel">
              Edit
            </h5>
            <button
              type="button"
              className="btn-close"
              data-bs-dismiss="modal"
              aria-label="Close"
            ></button>
          </div>
          <div className="modal-body">
            {editId.length &&
            allSiswaData.filter((f) => f.id == editId).length ? (
              <>
                <ul className="list-group" id="editForm">
                  <li className="list-group-item border-0">
                    <b className="me-3">ID: </b>
                    {allSiswaData.filter((f) => f.id == editId)[0].id}
                  </li>
                  <li className="list-group-item border-0 d-flex align-items-center">
                    <label htmlFor="nama" className="fw-bold">
                      Nama:
                    </label>
                    <input
                      type="text"
                      id="nama"
                      className="form-control ms-3"
                      defaultValue={
                        allSiswaData.filter((f) => f.id == editId)[0].name
                      }
                    />
                  </li>
                  <li className="list-group-item border-0 d-flex align-items-center">
                    <label htmlFor="email" className="fw-bold">
                      Email:
                    </label>
                    <input
                      type="email"
                      id="email"
                      className="form-control ms-3"
                      defaultValue={
                        allSiswaData.filter((f) => f.id == editId)[0].email
                      }
                    />
                  </li>
                  <li className="list-group-item border-0 d-flex align-items-center">
                    <b className="me-3">ID Card: </b>
                    {allSiswaData.filter((f) => f.id == editId)[0].card}
                  </li>
                  <li className="list-group-item border-0 d-flex align-items-center">
                    <label htmlFor="telSiswa" className="fw-bold">
                      WhatsApp:
                    </label>
                    <input
                      type="tel"
                      id="telSiswa"
                      className="form-control ms-3"
                      defaultValue={
                        allSiswaData.filter((f) => f.id == editId)[0]
                          .telSiswa
                      }
                    />
                  </li>
                  <li className="list-group-item border-0 d-flex align-items-center">
                    <label htmlFor="telWaliKelas" className="fw-bold">
                      WhatsApp Wali Kelas:
                    </label>
                    <input
                      type="tel"
                      id="telWaliKelas"
                      className="form-control ms-3"
                      defaultValue={
                        allSiswaData.filter((f) => f.id == editId)[0]
                          .telWaliKelas
                      }
                    />
                  </li>
                  <li className="list-group-item border-0 d-flex align-items-center">
                    <label htmlFor="telWaliMurid" className="fw-bold">
                      WhatsApp PJ:
                    </label>
                    <input
                      type="tel"
                      id="telWaliMurid"
                      className="form-control ms-3"
                      defaultValue={
                        allSiswaData.filter((f) => f.id == editId)[0]
                          .telWaliMurid
                      }
                    />
                  </li>
                </ul>
              </>
            ) : null}
          </div>
          {editId.length &&
          allSiswaData.filter((f) => f.id == editId).length ? (
            <div className="modal-footer">
              <button
                type="button"
                className="btn btn-secondary"
                data-bs-dismiss="modal"
              >
                Cancel
              </button>
              <button
                type="button"
                className="btn btn-warning"
                onClick={async () => {
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

                  const name = document
                    .querySelector("#editModal input#nama")
                    .value.trim();
                  const email = document
                    .querySelector("#editModal input#email")
                    .value.trim();
                  const telSiswa = document
                    .querySelector("#editModal input#telSiswa")
                    .value.trim();
                  const telWaliKelas = document
                    .querySelector("#editModal input#telWaliKelas")
                    .value.trim();
                  const telWaliMurid = document
                    .querySelector("#editModal input#telWaliMurid")
                    .value.trim();
                  const _validTelSiswa = await validPhone(telSiswa);
                  const _validTelWaliKelas = await validPhone(telWaliKelas);
                  const _validTelWaliMurid = await validPhone(
                    telWaliMurid
                  );

                  if (name.length < 1) return alert("Nama wajib di-isi!");
                  else if (email.length < 1)
                    return alert("Email wajib di-isi!");
                  else if (email.length >= 1 && !emailRegex.test(email))
                    return alert("Email tidak valid!");
                  else if (
                    email.length >= 1 &&
                    emailRegex.test(email) &&
                    !email.endsWith("gmail.com")
                  )
                    return alert("Email harus beralamat gmail.com!");
                  else if (telSiswa.length < 1)
                    return alert("WhatsApp siswa wajib di-isi!");
                  else if (telSiswa.length >= 1 && _validTelSiswa == 500)
                    return alert("Gagal mengecek nomor WhatsApp siswa!");
                  else if (telSiswa.length >= 1 && _validTelSiswa == 400)
                    return alert("Gagal mengecek nomor WhatsApp siswa!");
                  else if (telSiswa.length >= 1 && _validTelSiswa == 404)
                    return alert("Nomor WhatsApp siswa tidak terdaftar!");
                  else if (telWaliKelas.length < 1)
                    return alert("WhatsApp atasan wajib di-isi!");
                  else if (telWaliKelas.length >= 1 && _validTelWaliKelas == 500)
                    return alert("Gagal mengecek nomor WhatsApp atasan!");
                  else if (telWaliKelas.length >= 1 && _validTelWaliKelas == 400)
                    return alert("Gagal mengecek nomor WhatsApp atasan!");
                  else if (telWaliKelas.length >= 1 && _validTelWaliKelas == 404)
                    return alert("Nomor WhatsApp atasan tidak terdaftar!");
                  else if (telWaliMurid.length < 1)
                    return alert("WhatsApp PJ wajib di-isi!");
                  else if (
                    telWaliMurid.length >= 1 &&
                    _validTelWaliMurid == 500
                  )
                    return alert("Gagal mengecek nomor WhatsApp PJ!");
                  else if (
                    telWaliMurid.length >= 1 &&
                    _validTelWaliMurid == 400
                  )
                    return alert("Gagal mengecek nomor WhatsApp PJ!");
                  else if (
                    telWaliMurid.length >= 1 &&
                    _validTelWaliMurid == 404
                  )
                    return alert("Nomor WhatsApp PJ tidak terdaftar!");
                  else {
                    try {
                      await update(ref(db, `siswa/${editId}`), {
                        name,
                        email,
                        telSiswa,
                        telWaliKelas,
                        telWaliMurid,
                      });
                      document
                        .querySelector(`#editModal [data-bs-dismiss="modal"]`)
                        .click();
                      alert("Data siswa berhasil di-update!");
                      triggerRefresh(true);
                    } catch (err) {
                      console.log(err);
                      alert("Terjadi kesalahan saat update data siswa!");
                    }
                  }
                }}
              >
                Edit
              </button>
            </div>
          ) : null}
        </div>
      </div>
    </div>
  );
}

EditModal.propTypes = {
  editId: PropTypes.string.isRequired,
  setEditId: PropTypes.func,
  allSiswaData: PropTypes.array.isRequired,
  triggerRefresh: PropTypes.func,
  refresh: PropTypes.bool
};
