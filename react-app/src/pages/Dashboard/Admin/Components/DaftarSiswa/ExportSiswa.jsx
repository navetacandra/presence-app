import { useState } from "react";
import PropTypes from "prop-types";

export default function ExportSiswa({ allSiswaData }) {
  const [load, setLoad] = useState(false);
  const [format, setFormat] = useState(0);

  async function download() {
    if (!load) {
      setLoad(true);
      if (format == 0) alert("Pilih format export terlebih dulu!");
      const siswaList = allSiswaData
        .map((e) => {
          delete e.absensi;
          return e;
        })
        .sort((a, b) => {
          let _a = a.name.toLowerCase();
          let _b = b.name.toLowerCase();

          if (_a < _b) return -1;
          if (_a > _b) return 1;
          return 0;
        });

      if (format == 1) {
        const filename = "data-siswa.json";
        const blob = new Blob([JSON.stringify(siswaList, null, 2)], {
          type: "application/json",
        });
        const url = URL.createObjectURL(blob);

        const link = document.createElement("a");
        link.href = url;
        link.download = filename;
        link.click();
        URL.revokeObjectURL(url);
      } else if (format == 2) {
        let csvContent = `No.,ID,ID Card,Nama,Email,WhatsApp Siswa,WhatsApp Wali Kelas,WhatsApp Wali Murid\n`;
        csvContent += siswaList
          .map((e, i) => {
            return `${i + 1},${e.id},${e.card ?? "-"},"${e.name}",${e.email},"${
              e.telSiswa
            }","${e.telWaliKelas}","${e.telWaliMurid}"`;
          })
          .join("\n");
        console.log(csvContent);
        const filename = "data-siswa.csv";
        const blob = new Blob([csvContent], {
          type: "text/csv;charset=utf-8;",
        });
        const url = URL.createObjectURL(blob);

        const link = document.createElement("a");
        link.href = url;
        link.download = filename;
        link.click();
        URL.revokeObjectURL(url);
      }

      setLoad(false);
    }
  }

  return (
    <div className="col-6">
      <div className="card shadow">
        <div className="card-body">
          <h5 className="text-center">Export Siswa</h5>
          <div className="mt-3 mb-3">
            <select
              className="form-select"
              onChange={(e) => setFormat(e.target.value)}
            >
              <option value={0}>Pilih Format</option>
              <option value={1}>JSON</option>
              <option value={2}>CSV</option>
            </select>
          </div>
          <div className="mb-3 d-flex justify-content-center">
            <button
              className={
                "btn btn-outline-primary col-8" + (load ? " disabled" : "")
              }
              onClick={() => download()}
            >
              {load ? (
                <div className="spinner-border text-primary" role="status">
                  <span className="visually-hidden">Loading...</span>
                </div>
              ) : (
                "Download"
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

ExportSiswa.propTypes = {
  allSiswaData: PropTypes.array,
};
