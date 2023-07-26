import { useEffect, useState } from "react";
import { API_URL } from "../../../secret.json";

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

export default function LaporanAbsen() {
  const [month, setMonth] = useState(months[new Date().getMonth()]);
  const [dates, setDates] = useState([[]]);
  const [_r, triggerRefresh] = useState(true);

  useEffect(() => {}, [_r]);

  useEffect(() => {
    const itemInChunk = 6;
    let chunkOfDates = Array(31)
      .fill(0)
      .map((_, i) => ({ active: false, date: i + 1 }))
      .reduce((resultArray, item, index) => {
        const chunkIndex = Math.floor(index / itemInChunk);

        if (!resultArray[chunkIndex]) {
          resultArray[chunkIndex] = []; // start a new chunk
        }

        resultArray[chunkIndex].push(item);

        return resultArray;
      }, []);
    setDates(chunkOfDates);
  }, [month]);

  async function download() {
    try {
      const response = await fetch(
        `${API_URL}/export?key=ma5terabsensi&month=${month}&tanggal=${dates
          .flat()
          .filter((f) => f.active)
          .sort((a, b) => a.date - b.date).map(e => e.date)}`,
          {
            method: "POST"
          }
      );
      const json = await response.json();
      if (json.csv != null) {
        const filename = "data-absensi-siswa.csv";
        const blob = new Blob([json.csv], {
          type: "text/csv;charset=utf-8;",
        });
        const url = URL.createObjectURL(blob);

        const link = document.createElement("a");
        link.href = url;
        link.download = filename;
        link.click();
        URL.revokeObjectURL(url);
        alert("Berhasil di-download!");
      }
    } catch (err) {
      console.log(err);
      alert("Gagal men-download laporan!");
    }
  }

  return (
    <div className="container mt-5 d-flex justify-content-around">
      <div className="card shadow-sm">
        <div className="card-body">
          <h4 className="text-center mb-3">Download Laporan</h4>
          <select
            className="form-select form-select-lg mb-3"
            value={month}
            onInput={(e) => setMonth(e.target.value)}
          >
            {months.map((e, i) => (
              <option key={i} value={e}>
                {e.charAt(0).toUpperCase()}
                {e.substring(1)}
              </option>
            ))}
          </select>
          <div className="d-flex flex-column justify-content-around">
            {dates.map((date, key1) => (
              <div className="d-flex justify-content-around my-2" key={key1}>
                {date.map((el, i) => (
                  <div
                    role="button"
                    onClick={() => {
                      let _d = [...dates];
                      _d[key1][i].active = !el.active;
                      setDates(_d);
                      triggerRefresh(!_r);
                    }}
                    className="mx-2 d-flex justify-content-center align-items-center text-light shadow-sm"
                    key={i}
                    style={
                      el.active
                        ? {
                            width: "40px",
                            height: "40px",
                            borderRadius: "5px",
                            backgroundColor: "#20c997",
                            transition: "ease .3s",
                          }
                        : {
                            width: "40px",
                            height: "40px",
                            borderRadius: "5px",
                            backgroundColor: "#dc3545",
                            transition: "ease .3s",
                          }
                    }
                  >
                    <span className="d-block fs-5 fw-bolder">{el.date}</span>
                  </div>
                ))}
              </div>
            ))}
            <button className="btn btn-outline-danger mt-3" onClick={() => download()}>Download</button>
          </div>
        </div>
      </div>
    </div>
  );
}
