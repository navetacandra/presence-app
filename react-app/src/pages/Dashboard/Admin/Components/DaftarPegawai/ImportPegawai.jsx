import { useState } from "react";
import PropTypes from "prop-types";
import ExportPegawai from "./ExportPegawai";
import { ref, update } from "firebase/database";
import { db } from "../../../../../firebase";

export default function ImportPegawai({ allPegawaiData, triggerRefresh }) {
  const [open, setOpen] = useState(false);
  const [load, setLoad] = useState(false);

  function handleFileUpload() {
    setLoad(true);

    if (!load) {
      const fileInput = document.getElementById("fileInput");
      const file = fileInput.files[0];

      if (file) {
        const reader = new FileReader();

        // Read the file asynchronously
        reader.onload = async function (event) {
          const fileData = event.target.result;
          const fileExtension = getFileExtension(file.name);

          if (fileExtension == "json") {
            const _jsonData = JSON.parse(fileData);
            if (_jsonData.length < 1) alert("File JSON tidak valid!");
            const sortedData = _jsonData.map(
              ({
                id,
                name,
                email,
                telPegawai,
                telAtasan,
                telPenanggungJawab,
                card,
              }) => {
                if (typeof id == "undefined" || id == null || id.length < 1) {
                  return false;
                } else if (
                  typeof name == "undefined" ||
                  name == null ||
                  name.length < 1
                ) {
                  return false;
                } else if (
                  typeof email == "undefined" ||
                  email == null ||
                  email.length < 1
                ) {
                  return false;
                } else if (
                  typeof telPegawai == "undefined" ||
                  telPegawai == null ||
                  telPegawai.length < 1
                ) {
                  return false;
                } else if (
                  typeof telAtasan == "undefined" ||
                  telAtasan == null ||
                  telAtasan.length < 1
                ) {
                  return false;
                } else if (
                  typeof telPenanggungJawab == "undefined" ||
                  telPenanggungJawab == null ||
                  telPenanggungJawab.length < 1
                ) {
                  return false;
                } else {
                  return {
                    id,
                    name,
                    email,
                    telPegawai,
                    telAtasan,
                    telPenanggungJawab,
                    card: card ?? "",
                  };
                }
              }
            );

            if (sortedData.filter((f) => f == false).length > 0) {
              alert("File JSON tidak valid!");
            } else {
              let dataAsOBJ = {};
              sortedData.forEach((el) => {
                dataAsOBJ[el.id] = el;
              });
              try {
                await update(ref(db, `/pegawai`), dataAsOBJ);
                triggerRefresh();
                alert("Data berhasil di-import!");
              } catch (err) {
                console.log(err);
              }
            }
          } else if (fileExtension == "csv") {
            const rows = fileData
              .split("\n")
              .filter((f) => f.length > 0 && f.split(",").length >= 7);

            const keys = rows.shift().split(",");
            const allowKeys = [
              "id",
              "id card",
              "card",
              "nama",
              "email",
              "tel pegawai",
              "whatsapp pegawai",
              "tel atasan",
              "whatsapp atasan",
              "tel penanggung jawab",
              "whatsapp penanggung jawab",
            ];

            const invalidKeys =
              keys
                .map((k) =>
                  // eslint-disable-next-line no-useless-escape
                  allowKeys.includes(k.toLowerCase().replace(/\"/g, ""))
                )
                .filter((f) => f == true).length < 7;

            if (rows.length < 1 || invalidKeys) {
              alert("File CSV tidak valid!");
            } else {
              const data = rows.map((el) => {
                let tempData = {};
                el.split(",").forEach((e, i) => {
                  let key = keys[i].toLowerCase();
                  if (allowKeys.includes(key)) {
                    if (key == "id card") key = "card";
                    if (key == "tel pegawai") key = "telPegawai";
                    if (key == "whatsapp pegawai") key = "telPegawai";
                    if (key == "tel atasan") key = "telAtasan";
                    if (key == "whatsapp atasan") key = "telAtasan";
                    if (key == "tel penanggung jawab")
                      key = "telPenanggungJawab";
                    if (key == "whatsapp penanggung jawab")
                      key = "telPenanggungJawab";
                    // eslint-disable-next-line no-useless-escape
                    tempData[key] = e.replace(/\"/g, "");
                  }
                });
                return tempData;
              });
              let dataAsOBJ = {};
              data.forEach(
                ({
                  id,
                  card,
                  nama,
                  email,
                  telPegawai,
                  telAtasan,
                  telPenanggungJawab,
                }) => {
                  dataAsOBJ[id] = {
                    id,
                    card,
                    email,
                    telPegawai,
                    telAtasan,
                    telPenanggungJawab,
                    name: nama,
                  };
                }
              );
              try {
                await update(ref(db, `/pegawai`), dataAsOBJ);
                triggerRefresh();
                alert("Data berhasil di-import!");
              } catch (err) {
                console.log(err);
              }
            }
          } else {
            alert("Format file yang di-dukung hanya CSV dan JSON!");
          }
        };

        reader.readAsText(file);
      }
      setLoad(false);
    }
  }

  function getFileExtension(fileName) {
    return fileName.split(".").pop().toLowerCase();
  }

  return (
    <section className="mb-3">
      <h4
        className="d-flex align-items-center"
        onClick={() => setOpen(!open)}
        style={{ cursor: "pointer" }}
      >
        Import/Export Pegawai
        <i
          className="ms-2 fs-6 bi bi-caret-right-fill my-auto add-pgw-caret"
          onClick={() => setOpen(!open)}
          style={
            open
              ? { transform: "rotate(90deg)", transition: "all .5s" }
              : { transform: "rotate(0deg)", transition: "all .5s" }
          }
        ></i>
      </h4>
      <div
        className="a-content mx-auto d-flex justify-content-around"
        style={
          open
            ? {
                visibility: "visible",
                opacity: "1",
                height: "auto",
                transition: "all .3s",
              }
            : {
                visibility: "hidden",
                opacity: "0",
                height: "0",
                transition: "all .3s",
              }
        }
      >
        <ExportPegawai allPegawaiData={allPegawaiData} />
        <div className="col-6">
          <div className="card shadow">
            <div className="card-body">
              <h5 className="text-center">Import Pegawai</h5>
              <input
                className="form-control"
                type="file"
                id="fileInput"
                style={{ visibility: "hidden", display: "none" }}
                onChange={() => handleFileUpload()}
              />
              <div className="mt-3 mb-2 d-flex justify-content-center">
                <label
                  htmlFor="fileInput"
                  className={
                    "btn btn-outline-primary col-8" + (load ? " disabled" : "")
                  }
                >
                  {load ? (
                    <div className="spinner-border text-primary" role="status">
                      <span className="visually-hidden">Loading...</span>
                    </div>
                  ) : (
                    "Upload"
                  )}
                </label>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

ImportPegawai.propTypes = {
  allPegawaiData: PropTypes.array,
  triggerRefresh: PropTypes.func,
};
