import { useEffect, useState } from "react";
import { db, getUserData } from "../../../firebase";
import { equalTo, get, orderByChild, query, ref } from "firebase/database";

export default function DashboardScreen() {
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
  const [alertShow, setAlertShow] = useState(false);
  const [list, setList] = useState([{}]);
  useEffect(() => {
    const userdata = getUserData();
    let interval = setInterval(async () => {
      const month = months[new Date().getMonth()];
      const date = new Date().getDate();
      const _snap = await get(
        query(
          ref(db, `/siswa`),
          orderByChild("email"),
          equalTo("dummy_001@gmail.com")
        )
      );
      if (!_snap.exists() && !alertShow) {
        setList([]);
        alert(`Siswa dengan email ${userdata.email} tidak ditemukan.`);
        setAlertShow(true);
      } else {
        const siswaId = Object.values(_snap.val())[0].id;
        let _list = [];
        for (let i = 0; i < 31; i++) {
          const snap = await get(
            ref(db, `/absensi/${month}/${i + 1}/siswa/${siswaId}`)
          );
          if (!snap.exists() && i + 1 < date) {
            _list.push({
              tanggal: i + 1,
              status: "Alpha",
              masuk: "-",
              pulang: "-",
            });
          } else if (!snap.exists() && i + 1 >= date) {
            _list.push({
              tanggal: i + 1,
              status: "-",
              masuk: "-",
              pulang: "-",
            });
          } else {
            _list.push({
              tanggal: i + 1,
              status: snap.val().status
                ? snap.val().status.charAt(0).toUpperCase() +
                  snap.val().status.substring(1)
                : "-",
              masuk: snap.val().masuk ?? "-",
              pulang: snap.val().pulang ?? "-",
            });
          }
        }
        setList(_list);
      }
    }, 5000);

    return () => {
      clearInterval(interval);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [alertShow, list]);
  return (
    <div className="container mt-5">
      <div className="d-flex justify-content-center align-items-center">
        <table className="table table-striped">
          <thead>
            <tr>
              <th scope="col">Tanggal</th>
              <th scope="col">Status</th>
              <th scope="col">Masuk</th>
              <th scope="col">Pulang</th>
            </tr>
          </thead>
          <tbody>
            {list.map((el, i) => (
              <tr key={i}>
                <th scope="row">{el.tanggal ?? "-"}</th>
                <th>{el.status ?? "-"}</th>
                <th>{el.masuk ?? "-"}</th>
                <th>{el.pulang ?? "-"}</th>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
