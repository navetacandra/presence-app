import PropTypes from "prop-types";

export default function DetailModal({ detailId, allSiswaData }) {
  return (
    <div
      className="modal fade"
      id="detailModal"
      tabIndex="-1"
      aria-labelledby="detailModalLabel"
      aria-hidden="true"
    >
      <div className="modal-dialog">
        <div className="modal-content">
          <div className="modal-header">
            <h5 className="modal-title" id="detailModalLabel">
              Detail
            </h5>
            <button
              type="button"
              className="btn-close"
              data-bs-dismiss="modal"
              aria-label="Close"
            ></button>
          </div>
          <div className="modal-body">
            {detailId.length &&
            allSiswaData.filter((f) => f.id == detailId).length ? (
              <>
                <ul className="list-group">
                  <li className="list-group-item border-0">
                    <b>ID: </b>{" "}
                    {allSiswaData.filter((f) => f.id == detailId)[0].id}
                  </li>
                  <li className="list-group-item border-0">
                    <b>Nama: </b>{" "}
                    {allSiswaData.filter((f) => f.id == detailId)[0].name}
                  </li>
                  <li className="list-group-item border-0">
                    <b>Email: </b>{" "}
                    {allSiswaData.filter((f) => f.id == detailId)[0].email}
                  </li>
                  <li className="list-group-item border-0">
                    <b>ID Card: </b>{" "}
                    {allSiswaData.filter((f) => f.id == detailId)[0].card}
                  </li>
                  <li className="list-group-item border-0">
                    <b>WhatsApp Siswa: </b>{" "}
                    {
                      allSiswaData.filter((f) => f.id == detailId)[0]
                        .telSiswa
                    }
                  </li>
                  <li className="list-group-item border-0">
                    <b>WhatsApp Wali Kelas: </b>{" "}
                    {
                      allSiswaData.filter((f) => f.id == detailId)[0]
                        .telWaliKelas
                    }
                  </li>
                  <li className="list-group-item border-0">
                    <b>WhatsApp Wali Murid: </b>{" "}
                    {
                      allSiswaData.filter((f) => f.id == detailId)[0]
                        .telWaliMurid
                    }
                  </li>
                </ul>
              </>
            ) : null}
          </div>
        </div>
      </div>
    </div>
  );
}

DetailModal.propTypes = {
  detailId: PropTypes.string.isRequired,
  allSiswaData: PropTypes.array.isRequired,
};
