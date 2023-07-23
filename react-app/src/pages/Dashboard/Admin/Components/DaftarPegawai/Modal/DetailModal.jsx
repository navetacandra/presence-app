import PropTypes from "prop-types";

export default function DetailModal({ detailId, allPegawaiData }) {
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
            allPegawaiData.filter((f) => f.id == detailId).length ? (
              <>
                <ul className="list-group">
                  <li className="list-group-item border-0">
                    <b>ID: </b>{" "}
                    {allPegawaiData.filter((f) => f.id == detailId)[0].id}
                  </li>
                  <li className="list-group-item border-0">
                    <b>Nama: </b>{" "}
                    {allPegawaiData.filter((f) => f.id == detailId)[0].name}
                  </li>
                  <li className="list-group-item border-0">
                    <b>Email: </b>{" "}
                    {allPegawaiData.filter((f) => f.id == detailId)[0].email}
                  </li>
                  <li className="list-group-item border-0">
                    <b>ID Card: </b>{" "}
                    {allPegawaiData.filter((f) => f.id == detailId)[0].card}
                  </li>
                  <li className="list-group-item border-0">
                    <b>WhatsApp Pegawai: </b>{" "}
                    {
                      allPegawaiData.filter((f) => f.id == detailId)[0]
                        .telPegawai
                    }
                  </li>
                  <li className="list-group-item border-0">
                    <b>WhatsApp Atasan: </b>{" "}
                    {
                      allPegawaiData.filter((f) => f.id == detailId)[0]
                        .telAtasan
                    }
                  </li>
                  <li className="list-group-item border-0">
                    <b>WhatsApp Penanggung Jawab: </b>{" "}
                    {
                      allPegawaiData.filter((f) => f.id == detailId)[0]
                        .telPenanggungJawab
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
  allPegawaiData: PropTypes.array.isRequired,
};
