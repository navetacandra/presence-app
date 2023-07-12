import { useEffect, useState } from "react";

export default function DaftarPegawaiScreen() {
  const [listLength, setListLength] = useState(10);
  const [paginate, setPaginate] = useState(0);
  const [pegawaisData, setPegawaisData] = useState([]);

  return (
    <div className="container d-flex justify-content-start flex-column mt-5">
      <section id="daftar-all-0" className="list-pgw-prnt">
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
          Daftar Pegawai
          <i className="ms-2 fs-6 bi bi-caret-right-fill my-auto"></i>
        </h4>
      </section>
      <section id="daftar-all" className="list-pgw-prnt">
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
          Daftar Pegawai Terdaftar
          <i className="ms-2 fs-6 bi bi-caret-right-fill my-auto"></i>
        </h4>
      </section>
      <section id="daftar-hdr" className="list-pgw-prnt">
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
          Daftar Pegawai Hadir
          <i className="ms-2 fs-6 bi bi-caret-right-fill my-auto"></i>
        </h4>
      </section>
    </div>
  );
}
