import { onValue, ref, update } from "firebase/database";
import { useEffect } from "react";
import { useState } from "react";
import { db } from "../../../firebase";

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

export default function JadwalAbsen() {
  const [mode, setMode] = useState(false);
  const [schedule, setSchedule] = useState([[[]]]);
  const [jamHadirStart, setJamHadirStart] = useState(0);
  const [menitHadirStart, setMenitHadirStart] = useState(0);
  const [jamHadirEnd, setJamHadirEnd] = useState(0);
  const [menitHadirEnd, setMenitHadirEnd] = useState(0);
  const [jamPulangStart, setJamPulangStart] = useState(0);
  const [menitPulangStart, setMenitPulangStart] = useState(0);
  const [jamPulangEnd, setJamPulangEnd] = useState(0);
  const [menitPulangEnd, setMenitPulangEnd] = useState(0);
  const [_r, triggerRefresh] = useState(false);

  useEffect(() => {
    const absensiListen = onValue(ref(db, `/absensi`), (snap) => {
      if (!snap.exists()) return;
      const scheduleDetails = months.map((m) => {
        const monthDetails = Array(31)
          .fill(0)
          .map((_, i) => {
            const dateDetails = snap
              .child(m)
              .child(`${i + 1}`)
              .child(`details`);
            if (!dateDetails.exists()) return;

            return { date: `${i + 1}`, active: dateDetails.val().active };
          });

        return monthDetails.reduce((resultArray, item, index) => {
          const chunkIndex = Math.floor(index / 6);
          if (!resultArray[chunkIndex]) {
            resultArray[chunkIndex] = []; // start a new chunk
          }

          resultArray[chunkIndex].push(item);
          return resultArray;
        }, []);
      });

      setSchedule(scheduleDetails);
    });

    const scheduleListen = onValue(ref(db, `/schedule`), (snap) => {
      if (!snap.exists()) return;

      // Jam Hadir Start + Menit Hadir Start
      setJamHadirStart(parseInt(snap.val().jam_hadir_start.split(":")[0]));
      setMenitHadirStart(parseInt(snap.val().jam_hadir_start.split(":")[1]));
      // Jam Hadir End + Menit Hadir End
      setJamHadirEnd(parseInt(snap.val().jam_hadir_end.split(":")[0]));
      setMenitHadirEnd(parseInt(snap.val().jam_hadir_end.split(":")[1]));
      // Jam Pulang Start + Menit Pulang Start
      setJamPulangStart(parseInt(snap.val().jam_pulang_start.split(":")[0]));
      setMenitPulangStart(parseInt(snap.val().jam_pulang_start.split(":")[1]));
      // Jam Pulang End + Menit Pulang End
      setJamPulangEnd(parseInt(snap.val().jam_pulang_end.split(":")[0]));
      setMenitPulangEnd(parseInt(snap.val().jam_pulang_end.split(":")[1]));
    });

    onValue(ref(db, `/mode`), (snap) => {
      if (!snap.exists()) return;
      setMode(snap.val());
    });

    if (
      jamHadirStart == jamHadirEnd &&
      jamHadirEnd == jamPulangStart &&
      jamPulangStart == jamPulangEnd
    ) {
      triggerRefresh(!_r);
    }

    return () => {
      absensiListen();
      scheduleListen();
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [_r]);

  async function updateJamHadirStart(jam, menit) {
    const _jam = jam ?? jamHadirStart;
    const _menit = menit ?? menitHadirStart;
    if (_jam > jamHadirEnd)
      alert("Jam Hadir Mulai tidak boleh lebih dari Jam Hadir Akhir");
    else if (_jam == jamHadirEnd && _menit >= menitHadirEnd)
      alert("Jam Hadir Mulai tidak boleh lebih dari Jam Hadir Akhir");
    else {
      try {
        await update(ref(db, `/schedule`), {
          jam_hadir_start: `${`${_jam}`.length > 1 ? _jam : `0${_jam}`}:${
            `${_menit}`.length > 1 ? _menit : `0${_menit}`
          }`,
        });
        alert("Jam Hadir Mulai berhasil diubah!");
      } catch (err) {
        console.log(err);
        alert("Jam Hadir Mulai gagal diubah!");
      }
    }
    triggerRefresh(!_r);
  }
  async function updateJamHadirEnd(jam, menit) {
    const _jam = jam ?? jamHadirEnd;
    const _menit = menit ?? menitHadirEnd;
    if (_jam < jamHadirStart)
      alert("Jam Hadir Akhir tidak boleh kurang dari Jam Hadir Mulai");
    else if (_jam == jamHadirStart && _menit <= menitHadirStart)
      alert("Jam Hadir Akhir tidak boleh kurang dari Jam Hadir Mulai");
    else if (_jam > jamPulangStart)
      alert("Jam Hadir Akhir tidak boleh lebih dari Jam Pulang Mulai");
    else if (_jam == jamPulangStart && _menit + 15 >= menitPulangStart)
      alert("Jam Hadir Akhir tidak boleh lebih dari Jam Pulang Mulai");
    else {
      try {
        await update(ref(db, `/schedule`), {
          jam_hadir_end: `${`${_jam}`.length > 1 ? _jam : `0${_jam}`}:${
            `${_menit}`.length > 1 ? _menit : `0${_menit}`
          }`,
        });
        alert("Jam Hadir Akhir berhasil diubah!");
      } catch (err) {
        console.log(err);
        alert("Jam Hadir Akhir gagal diubah!");
      }
    }
    triggerRefresh(!_r);
  }

  async function updateJamPulangStart(jam, menit) {
    const _jam = jam ?? jamPulangStart;
    const _menit = menit ?? menitPulangStart;
    if (_jam < jamHadirEnd)
      alert("Jam Pulang Mulai tidak boleh kurang dari Jam Hadir Akhir");
    else if (_jam == jamHadirEnd && _menit <= menitHadirEnd + 15)
      alert("Jam Pulang Mulai tidak boleh kurang dari Jam Hadir Akhir");
    else if (_jam > jamPulangEnd)
      alert("Jam Pulang Mulai tidak boleh lebih dari Jam Pulang Akhir");
    else if (_jam == jamPulangEnd && _menit >= menitPulangEnd)
      alert("Jam Pulang Mulai tidak boleh lebih dari Jam Pulang Akhir");
    else {
      try {
        await update(ref(db, `/schedule`), {
          jam_pulang_start: `${`${_jam}`.length > 1 ? _jam : `0${_jam}`}:${
            `${_menit}`.length > 1 ? _menit : `0${_menit}`
          }`,
        });
        alert("Jam Pulang Mulai berhasil diubah!");
      } catch (err) {
        console.log(err);
        alert("Jam Pulang Mulai gagal diubah!");
      }
    }
    triggerRefresh(!_r);
  }

  async function updateJamPulangEnd(jam, menit) {
    const _jam = jam ?? jamPulangEnd;
    const _menit = menit ?? menitPulangEnd;
    if (_jam < jamPulangStart)
      alert("Jam Pulang Akhir tidak boleh kurang dari Jam Pulang Mulai");
    else if (_jam == jamPulangStart && _menit <= menitHadirStart)
      alert("Jam Pulang Akhir tidak boleh kurang dari Jam Pulang Mulai");
    else {
      try {
        await update(ref(db, `/schedule`), {
          jam_pulang_end: `${`${_jam}`.length > 1 ? _jam : `0${_jam}`}:${
            `${_menit}`.length > 1 ? _menit : `0${_menit}`
          }`,
        });
        alert("Jam Pulang Akhir berhasil diubah!");
      } catch (err) {
        console.log(err);
        alert("Jam Pulang Akhir gagal diubah!");
      }
    }
    triggerRefresh(!_r);
  }

  return (
    <div className="container mt-5 d-flex flex-column">
      <div className="d-flex justify-content-center align-items-center mb-5">
        <h5 className="mb-1">Registrasi Kartu</h5>
        <div className="form-check form-switch mx-5">
          {mode ? (
            <input
              className="form-check-input shadow-sm"
              type="checkbox"
              style={{ width: "65px", height: "32.5px" }}
              onChange={(e) => {
                setMode(e.target.checked);
                update(ref(db, `/`), { mode: e.target.checked });
              }}
              checked
            />
          ) : (
            <input
              className="form-check-input shadow-sm"
              type="checkbox"
              onChange={(e) => {
                setMode(e.target.checked);
                update(ref(db, `/`), { mode: e.target.checked });
              }}
              style={{ width: "65px", height: "32.5px" }}
            />
          )}
        </div>
        <h5 className="mt-1">Presensi</h5>
      </div>
      <div className="d-flex flex-column justify-content-around align-items-center mb-3">
        <div className="d-flex justify-content-around mb-3">
          <div className="d-flex flex-column mx-5">
            <h5 className="mb-2">Jam Hadir Mulai</h5>
            <div className="d-flex justify-content-around">
              <select
                className="form-select"
                value={jamHadirStart}
                onChange={(e) => {
                  updateJamHadirStart(
                    parseInt(e.target.value),
                    menitHadirStart
                  );
                }}
              >
                {Array(24)
                  .fill(0)
                  .map((_, i) => (
                    <option key={i} value={i}>
                      {`${i}`.length > 1 ? i : `0${i}`}
                    </option>
                  ))}
              </select>
              <select
                className="form-select"
                value={menitHadirStart}
                onChange={(e) => {
                  updateJamHadirStart(jamHadirStart, parseInt(e.target.value));
                }}
              >
                {Array(60)
                  .fill(0)
                  .map((_, i) => (
                    <option key={i} value={i}>
                      {`${i}`.length > 1 ? i : `0${i}`}
                    </option>
                  ))}
              </select>
            </div>
          </div>
          <div className="d-flex flex-column mx-5">
            <h5 className="mb-2">Jam Hadir Akhir</h5>
            <div className="d-flex justify-content-around">
              <select
                className="form-select"
                value={jamHadirEnd}
                onChange={(e) => {
                  updateJamHadirEnd(parseInt(e.target.value), menitHadirEnd);
                }}
              >
                {Array(24)
                  .fill(0)
                  .map((_, i) => (
                    <option key={i} value={i}>
                      {`${i}`.length > 1 ? i : `0${i}`}
                    </option>
                  ))}
              </select>
              <select
                className="form-select"
                value={menitHadirEnd}
                onChange={(e) => {
                  updateJamHadirEnd(jamHadirEnd, parseInt(e.target.value));
                }}
              >
                {Array(60)
                  .fill(0)
                  .map((_, i) => (
                    <option key={i} value={i}>
                      {`${i}`.length > 1 ? i : `0${i}`}
                    </option>
                  ))}
              </select>
            </div>
          </div>
        </div>
        <div className="d-flex justify-content-around">
          <div className="d-flex flex-column mx-5">
            <h5 className="mb-2">Jam Pulang Mulai</h5>
            <div className="d-flex justify-content-around">
              <select
                className="form-select"
                value={jamPulangStart}
                onChange={(e) => {
                  updateJamPulangStart(
                    parseInt(e.target.value),
                    menitPulangStart
                  );
                }}
              >
                {Array(24)
                  .fill(0)
                  .map((_, i) => (
                    <option key={i} value={i}>
                      {`${i}`.length > 1 ? i : `0${i}`}
                    </option>
                  ))}
              </select>
              <select
                className="form-select"
                value={menitPulangStart}
                onChange={(e) => {
                  updateJamPulangStart(
                    jamPulangStart,
                    parseInt(e.target.value)
                  );
                }}
              >
                {Array(60)
                  .fill(0)
                  .map((_, i) => (
                    <option key={i} value={i}>
                      {`${i}`.length > 1 ? i : `0${i}`}
                    </option>
                  ))}
              </select>
            </div>
          </div>
          <div className="d-flex flex-column mx-5">
            <h5 className="mb-2">Jam Pulang Akhir</h5>
            <div className="d-flex justify-content-around">
              <select
                className="form-select"
                value={jamPulangEnd}
                onChange={(e) => {
                  updateJamPulangEnd(parseInt(e.target.value), menitPulangEnd);
                }}
              >
                {Array(24)
                  .fill(0)
                  .map((_, i) => (
                    <option key={i} value={i}>
                      {`${i}`.length > 1 ? i : `0${i}`}
                    </option>
                  ))}
              </select>
              <select
                className="form-select"
                value={menitPulangEnd}
                onChange={(e) => {
                  updateJamPulangEnd(jamPulangEnd, parseInt(e.target.value));
                }}
              >
                {Array(60)
                  .fill(0)
                  .map((_, i) => (
                    <option key={i} value={i}>
                      {`${i}`.length > 1 ? i : `0${i}`}
                    </option>
                  ))}
              </select>
            </div>
          </div>
        </div>
      </div>
      <div className="d-flex align-items-center justify-content-around flex-wrap">
        {schedule.map((s, idx) => (
          <div className="card shadow-sm my-3" key={idx}>
            <div className="card-body">
              <h4 className="text-center mb-3">
                {months[idx].charAt(0).toUpperCase()}
                {months[idx].substring(1)}
              </h4>
              <div className="d-flex justify-content-around flex-column">
                {s.map((date, key1) => (
                  <div
                    className="d-flex justify-content-around my-2"
                    key={key1}
                  >
                    {date.map((el, i) => (
                      <div
                        role="button"
                        onClick={() => {
                          update(
                            ref(
                              db,
                              `/absensi/${months[idx]}/${el.date}/details`
                            ),
                            { active: !el.active }
                          );
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
                        <span className="d-block fs-5 fw-bolder">
                          {el.date}
                        </span>
                      </div>
                    ))}
                  </div>
                ))}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
