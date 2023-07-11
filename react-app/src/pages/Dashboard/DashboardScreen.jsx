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
import { faker } from "@faker-js/faker";

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

  dataset.forEach(
    (el) =>
      (el.data = tglLabels.map(() =>
        faker.datatype.number({ min: 0, max: 2000 })
      ))
  );
  return dataset;
}

export default function DashboardComponent() {
  const [show, setShow] = useState([
    "Hadir Tepat",
    "Hadir Telat",
    "Izin",
    "Sakit",
    "Tanpa Keterangan",
  ]);
  const [datasetGraph, setDatasetGraph] = useState([]);
  const [currentMonth, setCurrentMonth] = useState("");
  // const months = ;

  useEffect(() => {
    console.log(getDataset());
    setDatasetGraph(getDataset());
    setInterval(() => {
      setCurrentMonth([
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
      ][new Date().getMonth()]);
    }, 10);
  }, []);

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
            <div className="text-center fs-5 fw-bolder">2000</div>
          </div>
        </div>
        <div className="card shadow" id="jumlah-pegawai-hadir-card">
          <div className="card-body" id="jumlah-pegawai-hadir-card-content">
            <div className="d-flex align-items-center mb-2">
              <i className="bi bi-people-fill me-2 fs-5 my-auto"></i>
              <span className="fs-5 fw-normal">Pegawai Hadir</span>
            </div>
            <div className="text-center fs-5 fw-bolder">1500</div>
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
