import { ref, update } from "firebase/database";
import PropTypes from "prop-types";
import { db } from "../../../../../../firebase";
import { useEffect } from "react";

export default function EditModal({ editId, setEditId, allPegawaiData, triggerRefresh, refresh }) {
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
            allPegawaiData.filter((f) => f.id == editId).length ? (
              <>
                <ul className="list-group" id="editForm">
                  <li className="list-group-item border-0">
                    <b className="me-3">ID: </b>
                    {allPegawaiData.filter((f) => f.id == editId)[0].id}
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
                        allPegawaiData.filter((f) => f.id == editId)[0].name
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
                        allPegawaiData.filter((f) => f.id == editId)[0].email
                      }
                    />
                  </li>
                  <li className="list-group-item border-0 d-flex align-items-center">
                    <b className="me-3">ID Card: </b>
                    {allPegawaiData.filter((f) => f.id == editId)[0].card}
                  </li>
                  <li className="list-group-item border-0 d-flex align-items-center">
                    <label htmlFor="telPegawai" className="fw-bold">
                      WhatsApp:
                    </label>
                    <input
                      type="tel"
                      id="telPegawai"
                      className="form-control ms-3"
                      defaultValue={
                        allPegawaiData.filter((f) => f.id == editId)[0]
                          .telPegawai
                      }
                    />
                  </li>
                  <li className="list-group-item border-0 d-flex align-items-center">
                    <label htmlFor="telAtasan" className="fw-bold">
                      WhatsApp Atasan:
                    </label>
                    <input
                      type="tel"
                      id="telAtasan"
                      className="form-control ms-3"
                      defaultValue={
                        allPegawaiData.filter((f) => f.id == editId)[0]
                          .telAtasan
                      }
                    />
                  </li>
                  <li className="list-group-item border-0 d-flex align-items-center">
                    <label htmlFor="telPenanggungJawab" className="fw-bold">
                      WhatsApp PJ:
                    </label>
                    <input
                      type="tel"
                      id="telPenanggungJawab"
                      className="form-control ms-3"
                      defaultValue={
                        allPegawaiData.filter((f) => f.id == editId)[0]
                          .telPenanggungJawab
                      }
                    />
                  </li>
                </ul>
              </>
            ) : null}
          </div>
          {editId.length &&
          allPegawaiData.filter((f) => f.id == editId).length ? (
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
                  const telPegawai = document
                    .querySelector("#editModal input#telPegawai")
                    .value.trim();
                  const telAtasan = document
                    .querySelector("#editModal input#telAtasan")
                    .value.trim();
                  const telPenanggungJawab = document
                    .querySelector("#editModal input#telPenanggungJawab")
                    .value.trim();
                  const _validTelPegawai = await validPhone(telPegawai);
                  const _validTelAtasan = await validPhone(telAtasan);
                  const _validTelPenanggungJawab = await validPhone(
                    telPenanggungJawab
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
                  else if (telPegawai.length < 1)
                    return alert("WhatsApp pegawai wajib di-isi!");
                  else if (telPegawai.length >= 1 && _validTelPegawai == 500)
                    return alert("Gagal mengecek nomor WhatsApp pegawai!");
                  else if (telPegawai.length >= 1 && _validTelPegawai == 400)
                    return alert("Gagal mengecek nomor WhatsApp pegawai!");
                  else if (telPegawai.length >= 1 && _validTelPegawai == 404)
                    return alert("Nomor WhatsApp pegawai tidak terdaftar!");
                  else if (telAtasan.length < 1)
                    return alert("WhatsApp atasan wajib di-isi!");
                  else if (telAtasan.length >= 1 && _validTelAtasan == 500)
                    return alert("Gagal mengecek nomor WhatsApp atasan!");
                  else if (telAtasan.length >= 1 && _validTelAtasan == 400)
                    return alert("Gagal mengecek nomor WhatsApp atasan!");
                  else if (telAtasan.length >= 1 && _validTelAtasan == 404)
                    return alert("Nomor WhatsApp atasan tidak terdaftar!");
                  else if (telPenanggungJawab.length < 1)
                    return alert("WhatsApp PJ wajib di-isi!");
                  else if (
                    telPenanggungJawab.length >= 1 &&
                    _validTelPenanggungJawab == 500
                  )
                    return alert("Gagal mengecek nomor WhatsApp PJ!");
                  else if (
                    telPenanggungJawab.length >= 1 &&
                    _validTelPenanggungJawab == 400
                  )
                    return alert("Gagal mengecek nomor WhatsApp PJ!");
                  else if (
                    telPenanggungJawab.length >= 1 &&
                    _validTelPenanggungJawab == 404
                  )
                    return alert("Nomor WhatsApp PJ tidak terdaftar!");
                  else {
                    try {
                      await update(ref(db, `pegawai/${editId}`), {
                        name,
                        email,
                        telPegawai,
                        telAtasan,
                        telPenanggungJawab,
                      });
                      document
                        .querySelector(`#editModal [data-bs-dismiss="modal"]`)
                        .click();
                      alert("Data pegawai berhasil di-update!");
                      triggerRefresh(true);
                    } catch (err) {
                      console.log(err);
                      alert("Terjadi kesalahan saat update data pegawai!");
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
  allPegawaiData: PropTypes.array.isRequired,
  triggerRefresh: PropTypes.func,
  refresh: PropTypes.bool
};
