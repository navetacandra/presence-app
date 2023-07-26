import { get, onValue, ref } from "firebase/database";
import { useEffect, useState } from "react";
import { db } from "../../../firebase";
import DeleteModal from "./Components/DaftarSiswa/Modal/DeleteModal";
import DetailModal from "./Components/DaftarSiswa/Modal/DetailModal";
import EditModal from "./Components/DaftarSiswa/Modal/EditModal";
import AddSiswa from "./Components/DaftarSiswa/AddSiswa";
import ImportSiswa from "./Components/DaftarSiswa/ImportSiswa";

export default function DaftarSiswaScreen() {
  const [listLength, setListLength] = useState(10);
  const [maxPaginate, setMaxPaginate] = useState(0);
  const [paginateMenu, setPaginateMenu] = useState([]);
  const [paginate, setPaginate] = useState(1);
  const [allSiswaData, setAllSiswaData] = useState([]);
  const [siswasData, setSiswasData] = useState([]);
  const [sortLogic, setSortLogic] = useState("nama");
  const [searchQuery, setSearchQuery] = useState("");
  const [_refresh, _triggerRefresh] = useState(true);
  const [currentMonth, setCurrentMonth] = useState("");
  const [editId, setEditId] = useState("");
  const [deleteId, setDeleteId] = useState("");
  const [detailId, setDetailId] = useState("");

  const sortName = (n1, n2) => {
    if (n1.toLowerCase() < n2.toLowerCase()) return -1;
    if (n1.toLowerCase() > n2.toLowerCase()) return 1;
    return 0;
  };

  useEffect(() => {
    const getCurrentMonth = setInterval(() => {
      setCurrentMonth(
        [
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
        ][new Date().getMonth()]
      );
    }, 10);

    return () => {
      clearInterval(getCurrentMonth);
    };
  }, []);

  useEffect(() => {
    onValue(ref(db, `siswa`), async (snap) => {
      if (!snap.exists()) setAllSiswaData([]);
      const _p = Object.values(snap.val());
      let cm;
      if (!currentMonth.length) {
        cm = [
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
        ][new Date().getMonth()];
      }
      const list = await Promise.all(
        _p.map(async (e) => ({
          ...e,
          absensi: await Promise.all(
            Array(31)
              .fill(0)
              .map((_, i) => i + 1)
              .map(async (dy) => {
                let _d = await get(
                  ref(
                    db,
                    `absensi/${
                      currentMonth.length ? currentMonth : cm
                    }/${dy}/siswa/${e.id}`
                  )
                );

                if (_d.exists()) {
                  return { tanggal: dy, ..._d.val() };
                } else {
                  return {
                    tanggal: dy,
                    status: dy >= new Date().getDate() ? "-" : "",
                    id: e.id,
                  };
                }
              })
          ),
        }))
      );

      setAllSiswaData(list);
    });

    if (!allSiswaData.length) {
      _triggerRefresh(!_refresh);
    }
  }, [currentMonth, _refresh, allSiswaData.length]);

  useEffect(() => {
    setSiswasData(
      allSiswaData
        .filter((f) => f.name.toLowerCase().includes(searchQuery.toLowerCase()))
        .sort((a, b) =>
          sortLogic == "nama"
            ? sortName(a.name, b.name)
            : sortLogic == "tepat"
            ? b.absensi.filter((f) => f.status == "tepat").length -
              a.absensi.filter((f) => f.status == "tepat").length
            : sortLogic == "telat"
            ? b.absensi.filter((f) => f.status == "telat").length -
              a.absensi.filter((f) => f.status == "telat").length
            : sortLogic == "izin"
            ? b.absensi.filter((f) => f.status == "izin").length -
              a.absensi.filter((f) => f.status == "izin").length
            : sortLogic == "sakit"
            ? b.absensi.filter((f) => f.status == "sakit").length -
              a.absensi.filter((f) => f.status == "sakit").length
            : sortLogic == "alpha"
            ? b.absensi.filter((f) => f.status == "alpha" || f.status == "")
                .length -
              a.absensi.filter((f) => f.status == "alpha" || f.status == "")
                .length
            : sortName(a.name, b.name)
        )
        .slice(listLength * (paginate - 1), listLength * paginate)
    );
    // console.log(siswasData);

    let _maxPaginate = Math.ceil(
      allSiswaData.filter((f) =>
        f.name.toLowerCase().includes(searchQuery.toLowerCase())
      ).length / listLength
    );

    const pgnMenu = Array(_maxPaginate > 5 ? 5 : _maxPaginate).fill(0);
    const _mid = Math.floor((_maxPaginate > 5 ? 5 : _maxPaginate) / 2);

    for (let i = 0; i < (_maxPaginate > 5 ? 5 : _maxPaginate); i++) {
      pgnMenu[i] = paginate + i - _mid;
    }

    const startGap =
      pgnMenu[0] == 0 ? 1 : pgnMenu[0] < 1 ? paginate - pgnMenu[0] : 0;
    const endGap =
      pgnMenu[pgnMenu.length - 1] > _maxPaginate
        ? pgnMenu[pgnMenu.length - 1] - _maxPaginate
        : 0;

    setMaxPaginate(_maxPaginate);
    setPaginateMenu(
      startGap > 0
        ? pgnMenu.map((e) => ({
            number: e + startGap,
            active: e + startGap == paginate,
          }))
        : endGap > 0
        ? pgnMenu.map((e) => ({
            number: e - endGap,
            active: e - endGap == paginate,
          }))
        : pgnMenu.map((e) => ({ number: e, active: e == paginate }))
    );

    // return () => {};

    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [searchQuery, listLength, paginate, sortLogic, _refresh]);

  useEffect(() => {
    setPaginate(1);
  }, [sortLogic, listLength, searchQuery]);

  useEffect(() => {
    document
      .querySelector("#editModal")
      .addEventListener("hidden.bs.modal", () => {
        setEditId("");
      });
    document
      .querySelector("#detailModal")
      .addEventListener("hidden.bs.modal", () => {
        setDetailId("");
      });
  }, []);

  return (
    <>
      <EditModal
        editId={editId}
        setEditId={setEditId}
        allSiswaData={allSiswaData}
        triggerRefresh={_triggerRefresh}
        refresh={_refresh}
      />
      <DeleteModal
        deleteId={deleteId}
        setDeleteId={setDeleteId}
        allSiswaData={allSiswaData}
        triggerRefresh={_triggerRefresh}
        refresh={_refresh}
      />
      <DetailModal detailId={detailId} allSiswaData={allSiswaData} />

      <div className="container d-flex justify-content-start flex-column mt-5">
        <ImportSiswa allSiswaData={allSiswaData} triggerRefresh={_triggerRefresh} />
        <AddSiswa triggerRefresh={_triggerRefresh} />

        {/* Daftar Siswa */}
        <section id="daftar-all-0" className="list-ssw-prnt">
          <h4
            className="d-flex align-items-center"
            onClick={(el) =>
              el.target.outerHTML.startsWith("<i")
                ? el.target.parentElement.parentElement.classList.toggle(
                    "show-table"
                  )
                : el.target.parentElement.classList.toggle("show-table")
            }
          >
            Daftar Siswa
            <i className="ms-2 fs-6 bi bi-caret-right-fill my-auto"></i>
          </h4>
          <div className="l-content">
            <div className="container d-flex justify-content-between align-items-end flex-wrap mt-2 mb-2">
              <div className="mb-1">
                <div className="input-group mb-3">
                  <input
                    type="text"
                    className="form-control"
                    placeholder="Cari Nama"
                    onInput={(e) => setSearchQuery(e.target.value)}
                  />
                  <button
                    className="btn btn-outline-dark disabled"
                    type="button"
                  >
                    <i className="bi bi-search"></i>
                  </button>
                </div>
              </div>
              <div className="d-flex flex-column my-auto">
                <div className="d-flex justify-content-end">
                  <label htmlFor="sort-order" className="fs-5 me-3">
                    Urutkan Berdasarkan:
                  </label>
                  <div>
                    <select
                      className="form-select form-select mb-3"
                      id="sort-order"
                      onChange={(e) => setSortLogic(e.target.value)}
                      defaultValue={"nama"}
                    >
                      <option value="nama">Nama</option>
                      <option value="tepat">Jumlah Hadir Tepat</option>
                      <option value="telat">Jumlah Hadir Telat</option>
                      <option value="izin">Jumlah Izin</option>
                      <option value="sakit">Jumlah Sakit</option>
                      <option value="alpha">Jumlah Alpha</option>
                    </select>
                  </div>
                </div>
                <div className="d-flex justify-content-end my-auto">
                  <label htmlFor="sort-order" className="fs-5 me-3">
                    Tampilkan {listLength} Data:
                  </label>
                  <div>
                    <div className="input-group mb-3">
                      <button
                        className="btn btn-outline-dark"
                        type="button"
                        onClick={() =>
                          listLength - 1 < 1
                            ? setListLength(listLength)
                            : setListLength(listLength - 1)
                        }
                      >
                        <i className="bi bi-caret-left-fill fs-6"></i>
                      </button>
                      <input
                        type="number"
                        min="1"
                        max={
                          allSiswaData.filter((f) =>
                            f.name
                              .toLowerCase()
                              .includes(searchQuery.toLowerCase())
                          ).length
                        }
                        className="form-control list-length-input"
                        placeholder="Data"
                        onInput={(e) => {
                          if (e.target.value < 1) {
                            e.target.value = 1;
                            setListLength(1);
                          } else if (
                            e.target.value >
                            allSiswaData.filter((f) =>
                              f.name
                                .toLowerCase()
                                .includes(searchQuery.toLowerCase())
                            ).length
                          ) {
                            e.target.value = allSiswaData.filter((f) =>
                              f.name
                                .toLowerCase()
                                .includes(searchQuery.toLowerCase())
                            ).length;
                            setListLength(
                              allSiswaData.filter((f) =>
                                f.name
                                  .toLowerCase()
                                  .includes(searchQuery.toLowerCase())
                              ).length
                            );
                          } else {
                            setListLength(e.target.value);
                          }
                        }}
                        value={listLength}
                      />
                      <button
                        className="btn btn-outline-dark"
                        type="button"
                        onClick={() =>
                          listLength + 1 >
                          allSiswaData.filter((f) =>
                            f.name
                              .toLowerCase()
                              .includes(searchQuery.toLowerCase())
                          ).length
                            ? setListLength(listLength)
                            : setListLength(listLength + 1)
                        }
                      >
                        <i className="bi bi-caret-right-fill fs-6"></i>
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div className="table-responsive mb-2">
              <table className="table table-striped table-bordered">
                <thead>
                  <tr>
                    <th scope="col">No</th>
                    <th scope="col">Nama</th>
                    <th scope="col">Email</th>
                    <th scope="col">No. Telpon</th>
                    <th scope="col">Tepat</th>
                    <th scope="col">Telat</th>
                    <th scope="col">Izin</th>
                    <th scope="col">Sakit</th>
                    <th scope="col">Alpha</th>
                    <th scope="col">Edit</th>
                    <th scope="col">Hapus</th>
                    <th scope="col">Detail</th>
                  </tr>
                </thead>
                <tbody>
                  {siswasData
                    .filter(
                      (f) =>
                        f.name
                          .split(" ")
                          .filter((fe) =>
                            fe.toLowerCase().includes(searchQuery.toLowerCase())
                          )
                          .filter((fe) => fe).length
                    )
                    .map((el, i) => (
                      <tr key={i}>
                        <th scope="row">{i + 1}</th>
                        <td>{el.name}</td>
                        <td>{el.email}</td>
                        <td>{el.telSiswa}</td>
                        <td>
                          {el.absensi.filter((f) => f.status == "tepat").length}
                        </td>
                        <td>
                          {el.absensi.filter((f) => f.status == "telat").length}
                        </td>
                        <td>
                          {el.absensi.filter((f) => f.status == "izin").length}
                        </td>
                        <td>
                          {el.absensi.filter((f) => f.status == "sakit").length}
                        </td>
                        <td>
                          {
                            el.absensi.filter(
                              (f) => f.status == "alpha" || f.status == ""
                            ).length
                          }
                        </td>
                        <td className="text-center">
                          <i
                            className="bi bi-pencil-square text-warning fs-5 table-icon"
                            data-bs-toggle="modal"
                            data-bs-target="#editModal"
                            onClick={() => setEditId(el.id)}
                          ></i>
                        </td>
                        <td className="text-center">
                          <i
                            className="bi bi-trash-fill text-danger fs-5 table-icon"
                            data-bs-toggle="modal"
                            data-bs-target="#deleteModal"
                            onClick={() => setDeleteId(el.id)}
                          ></i>
                        </td>
                        <td className="text-center">
                          <i
                            className="bi bi-eye-fill text-success fs-5 table-icon"
                            data-bs-toggle="modal"
                            data-bs-target="#detailModal"
                            onClick={() => setDetailId(el.id)}
                          ></i>
                        </td>
                      </tr>
                    ))}
                </tbody>
              </table>
            </div>
            <div className="d-flex justify-content-center">
              <div
                className="btn-group me-2"
                role="group"
                aria-label="First group"
              >
                {paginate - 1 <= 0 ? null : (
                  <button
                    type="button"
                    className="btn btn-outline-dark"
                    onClick={() => setPaginate(paginate - 1)}
                  >
                    <i className="bi bi-caret-left-fill fs-6"></i>
                  </button>
                )}
                {paginateMenu.map(({ number, active }, i) => (
                  <button
                    type="button"
                    className={
                      "btn btn-outline-dark" + (active ? " active" : "")
                    }
                    onClick={() => setPaginate(number)}
                    key={i}
                  >
                    {number}
                  </button>
                ))}
                {paginate + 1 > maxPaginate ? null : (
                  <button
                    type="button"
                    className="btn btn-outline-dark"
                    onClick={() => setPaginate(paginate + 1)}
                  >
                    <i className="bi bi-caret-right-fill fs-6"></i>
                  </button>
                )}
              </div>
            </div>
          </div>
        </section>
      </div>
    </>
  );
}
