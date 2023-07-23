import { ref, remove } from "firebase/database";
import PropTypes from "prop-types";
import { db } from "../../../../../../firebase";
import { useEffect } from "react";

export default function DeleteModal({ deleteId, setDeleteId, allPegawaiData, triggerRefresh, refresh }) {
  useEffect(() => {
    document
      .querySelector("#deleteModal")
      .addEventListener("hidden.bs.modal", () => {
        setDeleteId("");
        triggerRefresh(!refresh);
      });
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [refresh, deleteId])

  return (
    <div
      className="modal fade"
      id="deleteModal"
      tabIndex="-1"
      aria-labelledby="deleteModalLabel"
      aria-hidden="true"
    >
      <div className="modal-dialog">
        <div className="modal-content">
          <div className="modal-header">
            <h5 className="modal-title" id="deleteModalLabel">
              Delete
            </h5>
            <button
              type="button"
              className="btn-close"
              data-bs-dismiss="modal"
              aria-label="Close"
            ></button>
          </div>
          <div className="modal-body">
            {deleteId.length &&
            allPegawaiData.filter((f) => f.id == deleteId).length ? (
              <>
                <ul className="list-group">
                  <li className="list-group-item border-0">
                    <b>ID: </b>{" "}
                    {allPegawaiData.filter((f) => f.id == deleteId)[0].id}
                  </li>
                  <li className="list-group-item border-0">
                    <b>Nama: </b>{" "}
                    {allPegawaiData.filter((f) => f.id == deleteId)[0].name}
                  </li>
                  <li className="list-group-item border-0">
                    <b>Email: </b>{" "}
                    {allPegawaiData.filter((f) => f.id == deleteId)[0].email}
                  </li>
                  <li className="list-group-item border-0">
                    <b>ID Card: </b>{" "}
                    {allPegawaiData.filter((f) => f.id == deleteId)[0].card}
                  </li>
                  <li className="list-group-item border-0">
                    <b>WhatsApp Pegawai: </b>{" "}
                    {
                      allPegawaiData.filter((f) => f.id == deleteId)[0]
                        .telPegawai
                    }
                  </li>
                  <li className="list-group-item border-0">
                    <b>WhatsApp Atasan: </b>{" "}
                    {
                      allPegawaiData.filter((f) => f.id == deleteId)[0]
                        .telAtasan
                    }
                  </li>
                  <li className="list-group-item border-0">
                    <b>WhatsApp Penanggung Jawab: </b>{" "}
                    {
                      allPegawaiData.filter((f) => f.id == deleteId)[0]
                        .telPenanggungJawab
                    }
                  </li>
                </ul>
              </>
            ) : null}
          </div>
          {deleteId.length &&
          allPegawaiData.filter((f) => f.id == deleteId).length ? (
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
                className="btn btn-danger"
                onClick={async () => {
                  await remove(ref(db, `/pegawai/${deleteId}`));
                  document
                    .querySelector('#deleteModal [data-bs-dismiss="modal"]')
                    .click();
                    triggerRefresh(true);
                }}
              >
                Delete
              </button>
            </div>
          ) : null}
        </div>
      </div>
    </div>
  );
}

DeleteModal.propTypes = {
  deleteId: PropTypes.string.isRequired,
  setDeleteId: PropTypes.func,
  allPegawaiData: PropTypes.array.isRequired,
  triggerRefresh: PropTypes.func,
  refresh: PropTypes.bool
};
