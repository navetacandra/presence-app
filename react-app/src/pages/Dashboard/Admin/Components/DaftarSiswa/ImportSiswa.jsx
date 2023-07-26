import { useState } from "react";
import PropTypes from "prop-types";
import ExportSiswa from "./ExportSiswa";
import { ref, update } from "firebase/database";
import { db } from "../../../../../firebase";

export default function ImportSiswa({ allSiswaData, triggerRefresh }) {
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
                telSiswa,
                telWaliKelas,
                telWaliMurid,
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
                  typeof telSiswa == "undefined" ||
                  telSiswa == null ||
                  telSiswa.length < 1
                ) {
                  return false;
                } else if (
                  typeof telWaliKelas == "undefined" ||
                  telWaliKelas == null ||
                  telWaliKelas.length < 1
                ) {
                  return false;
                } else if (
                  typeof telWaliMurid == "undefined" ||
                  telWaliMurid == null ||
                  telWaliMurid.length < 1
                ) {
                  return false;
                } else {
                  return {
                    id,
                    name,
                    email,
                    telSiswa,
                    telWaliKelas,
                    telWaliMurid,
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
                await update(ref(db, `/siswa`), dataAsOBJ);
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
              "tel siswa",
              "whatsapp siswa",
              "tel wali kelas",
              "whatsapp wali kelas",
              "tel wali murid",
              "whatsapp wali murid",
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
                    if (key == "tel siswa") key = "telSiswa";
                    if (key == "whatsapp siswa") key = "telSiswa";
                    if (key == "tel wali kelas") key = "telWaliKelas";
                    if (key == "whatsapp wali kelas") key = "telWaliKelas";
                    if (key == "tel wali murid")
                      key = "telWaliMurid";
                    if (key == "whatsapp wali murid")
                      key = "telWaliMurid";
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
                  telSiswa,
                  telWaliKelas,
                  telWaliMurid,
                }) => {
                  dataAsOBJ[id] = {
                    id,
                    card,
                    email,
                    telSiswa,
                    telWaliKelas,
                    telWaliMurid,
                    name: nama,
                  };
                }
              );
              try {
                await update(ref(db, `/siswa`), dataAsOBJ);
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
        Import/Export Siswa
        <i
          className="ms-2 fs-6 bi bi-caret-right-fill my-auto add-ssw-caret"
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
        <ExportSiswa allSiswaData={allSiswaData} />
        <div className="col-6">
          <div className="card shadow">
            <div className="card-body">
              <h5 className="text-center">Import Siswa</h5>
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

ImportSiswa.propTypes = {
  allSiswaData: PropTypes.array,
  triggerRefresh: PropTypes.func,
};
