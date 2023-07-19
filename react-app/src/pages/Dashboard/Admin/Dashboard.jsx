import PropTypes from "prop-types";
import { Fragment, useEffect, useState } from "react";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
} from "chart.js";
import { Line } from "react-chartjs-2";
import { onValue, ref } from "firebase/database";
import { db } from "../../../firebase";

const tglLabels = Array(31)
  .fill(0)
  .map((_, i) => String(i + 1));

const DataKehadiran = ({ month, dataset, show, setShow }) => {
  return (
    <>
      <div className="d-flex justify-content-center mt-5 mb-3">
        <div
          className="btn-group"
          role="group"
          aria-label="Basic checkbox toggle button group"
        >
          {dataset.map((el, i) => (
            <Fragment key={i}>
              <input
                type="checkbox"
                className="btn-check"
                autoComplete="off"
                id={el.label.toLowerCase().replace(/ /g, "-")}
                checked={show.includes(el.label)}
                onChange={() =>
                  show.includes(el.label)
                    ? setShow(show.filter((l) => l != el.label))
                    : setShow([...show, el.label])
                }
              />
              <label
                className="btn"
                htmlFor={el.label.toLowerCase().replace(/ /g, "-")}
                style={{
                  "--bs-btn-color": el.backgroundColor,
                  "--bs-btn-border-color": el.backgroundColor,
                  "--bs-btn-hover-color": "#000",
                  "--bs-btn-hover-bg": el.backgroundColor,
                  "--bs-btn-hover-border-color": el.backgroundColor,
                  "--bs-btn-focus-shadow-rgb": "255, 193, 7",
                  "--bs-btn-active-color": el.textColor,
                  "--bs-btn-active-bg": el.backgroundColor,
                  "--bs-btn-active-border-color": el.backgroundColor,
                  "--bs-btn-active-shadow":
                    "inset 0 3px 5px rgba(0, 0, 0, 0.125)",
                  "--bs-btn-disabled-color": el.backgroundColor,
                  "--bs-btn-disabled-bg": "transparent",
                  "--bs-btn-disabled-border-color": el.backgroundColor,
                  "--bs-gradient": "none",
                }}
              >
                {el.label}
              </label>
            </Fragment>
          ))}
        </div>
      </div>
      <div className="dashboard-graph-container mx-auto mb-5">
        <Line
          options={{
            responsive: true,
            plugins: {
              legend: {
                position: "top",
              },
              title: {
                display: true,
                text: `Data Kehadiran Bulan ${month}`,
              },
            },
            scales: {
              y: {
                beginAtZero: true,
                ticks: {
                  precision: 0,
                  callback: (value) => Math.round(value),
                },
              },
            },
          }}
          data={{
            labels: tglLabels,
            datasets: dataset.filter((l) => show.includes(l.label)),
          }}
        />
      </div>
    </>
  );
};

DataKehadiran.propTypes = {
  month: PropTypes.string.isRequired,
  dataset: PropTypes.array.isRequired,
  show: PropTypes.array.isRequired,
  setShow: PropTypes.func.isRequired,
};

function getDataset() {
  const dataset = [
    {
      label: "Hadir Tepat",
      data: [],
      borderColor: "rgb(25,135,84)",
      backgroundColor: "rgb(25,135,84)",
      textColor: "#fff",
    },
    {
      label: "Hadir Telat",
      data: [],
      borderColor: "rgb(13,110,253)",
      backgroundColor: "rgb(13,110,253)",
      textColor: "#fff",
    },
    {
      label: "Izin",
      data: [],
      borderColor: "rgb(67,40,116)",
      backgroundColor: "rgb(67,40,116)",
      textColor: "#fff",
    },
    {
      label: "Sakit",
      data: [],
      borderColor: "rgb(253,126,20)",
      backgroundColor: "rgb(253,126,20)",
      textColor: "#fff",
    },
    {
      label: "Tanpa Keterangan",
      data: [],
      borderColor: "rgb(220, 53, 69)",
      backgroundColor: "rgb(220, 53, 69)",
      textColor: "#fff",
    },
  ];

  return dataset;
}

export default function DashboardScreen() {
  const [show, setShow] = useState([
    "Hadir Tepat",
    "Hadir Telat",
    "Izin",
    "Sakit",
    "Tanpa Keterangan",
  ]);
  const [datasetGraph, setDatasetGraph] = useState([]);
  const [currentMonth, setCurrentMonth] = useState("");
  const [jumlahPegawai, setJumlahPegawai] = useState(0);
  const [jumlahPegawaiHadir, setJumlahPegawaiHadir] = useState(0);
  const [_refresh, _refreshState] = useState(true);

  useEffect(() => {
    setDatasetGraph(getDataset());
    const getCurrentMonth = setInterval(() => {
      setCurrentMonth(
        [
          "Januari",
          "Februari",
          "Maret",
          "April",
          "Mei",
          "Juni",
          "Juli",
          "Agustus",
          "September",
          "Oktober",
          "November",
          "Desember",
        ][new Date().getMonth()]
      );
    }, 10);

    return () => {
      clearInterval(getCurrentMonth);
    };
  }, []);

  useEffect(() => {
    // Get Pegawai Length
    onValue(ref(db, "pegawai"), (snap) =>
      setJumlahPegawai(snap.exists() ? Object.values(snap.val()).length : 0)
    );

    if (!currentMonth) {
      _refreshState(true);
    }
    // Get absensi data
    const _cm = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ][new Date().getMonth()].toLowerCase();
    onValue(
      ref(
        db,
        `absensi/${currentMonth.length ? currentMonth.toLowerCase() : _cm}`
      ),
      (snap) => {
        if (snap.exists()) {
          const keys = Object.values(snap.val());
          let _dataset = getDataset();

          const pegawaiPath = snap
            .child(new Date().getDate().toString())
            .child("pegawai");
          setJumlahPegawaiHadir(
            pegawaiPath.exists() ? Object.keys(pegawaiPath.val()).length : 0
          );
          const setDataset = (label, filter) => {
            _dataset = _dataset.map((e) =>
              e.label == label
                ? {
                    ...e,
                    data: keys.map(
                      (_, tgl) =>
                        (
                          Object.values(
                            Object.values(snap.val())[tgl]?.pegawai ?? {}
                          )?.filter((f) =>
                            filter.split("|").includes(f.status)
                          ) ?? []
                        ).length
                    ),
                  }
                : e
            );
          };
          setDataset("Hadir Tepat", "tepat");
          setDataset("Hadir Telat", "telat");
          setDataset("Izin", "izin");
          setDataset("Sakit", "sakit");
          setDataset("Tanpa Keterangan", "|alpha");

          setDatasetGraph(_dataset);
        }
      }
    );

    if (
      !datasetGraph.length ||
      !currentMonth ||
      !jumlahPegawai ||
      !jumlahPegawaiHadir
    ) {
      _refreshState(true);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentMonth, _refresh, jumlahPegawai, jumlahPegawaiHadir]);

  ChartJS.register(
    CategoryScale,
    LinearScale,
    PointElement,
    LineElement,
    Title,
    Tooltip,
    Legend
  );

  return (
    <div className="container mt-5">
      <div className="d-flex flex-wrap justify-content-center mb-5 pb-5">
        <div className="card shadow" id="jumlah-pegawai-terdaftar-card">
          <div className="card-body" id="jumlah-pegawai-terdaftar-card-content">
            <div className="d-flex align-items-center mb-2">
              <i className="bi bi-people-fill me-2 fs-5 my-auto"></i>
              <span className="fs-5 fw-normal">Pegawai Terdaftar</span>
            </div>
            <div className="text-center fs-5 fw-bolder">{jumlahPegawai}</div>
          </div>
        </div>
        <div className="card shadow" id="jumlah-pegawai-hadir-card">
          <div className="card-body" id="jumlah-pegawai-hadir-card-content">
            <div className="d-flex align-items-center mb-2">
              <i className="bi bi-people-fill me-2 fs-5 my-auto"></i>
              <span className="fs-5 fw-normal">Pegawai Hadir</span>
            </div>
            <div className="text-center fs-5 fw-bolder">
              {jumlahPegawaiHadir}
            </div>
          </div>
        </div>
      </div>
      <DataKehadiran
        dataset={datasetGraph}
        month={currentMonth}
        show={show}
        setShow={setShow}
      />
    </div>
  );
}
