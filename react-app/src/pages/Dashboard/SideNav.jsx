import { useEffect, useState } from "react";
import AppIcon from "../../assets/app_icon.png";
import PropTypes from "prop-types";
import { auth, getUserData, nestBTOA } from "../../firebase";
import { signOut } from "firebase/auth";

export default function SideNav({
  activeItem,
  setActiveItem,
  sideNavMenuTitle,
  sideNavMenuIcon,
}) {
  const [profile, setProfile] = useState({});
  const [_refresh, _refreshState] = useState({});
  useEffect(() => {
    let prf = getUserData();
    setProfile(prf);
    if (!prf.email) {
      _refreshState({});
    }
  }, [_refresh]);

  return (
    <>
      <nav className="navbar navbar-light bg-light shadow">
        <div className="container d-flex justify-content-between">
          <a className="navbar-brand ms-4" href="#">
            <img
              src={AppIcon}
              alt="App Icon"
              width={32}
              className="d-inline-block align-text-top"
            />
            Ma5Ter Absensi
          </a>
          <button
            className="btn btn-outline-dark"
            type="button"
            data-bs-toggle="offcanvas"
            data-bs-target="#sideNavOffCanvas"
            aria-controls="sideNavOffCanvas"
          >
            <i className="bi bi-list"></i>
          </button>
        </div>
      </nav>
      <div
        className="offcanvas offcanvas-start"
        data-bs-scroll="true"
        tabIndex="-1"
        id="sideNavOffCanvas"
        aria-labelledby="sideNavOffCanvasLabel"
      >
        <div className="offcanvas-header">
          <div
            className="offcanvas-title d-flex align-items-center"
            id="sideNavOffCanvasLabel"
          >
            <img
              src={AppIcon}
              alt="App Icon"
              width={32}
              className="my-auto me-1"
            />
            <h5 className="my-auto">Ma5Ter Absensi</h5>
          </div>
          <button
            type="button"
            className="btn-close text-reset"
            data-bs-dismiss="offcanvas"
            aria-label="Close"
          ></button>
        </div>
        <div className="offcanvas-body">
          <div
            className="d-flex justify-content-between flex-column"
            style={{ minHeight: "100%" }}
          >
            <div>
              <ul className="list-group sidenav-links">
                {sideNavMenuTitle.map((el, i) => (
                  <li
                    key={i}
                    onClick={() => setActiveItem(i)}
                    className={
                      "list-group-item" +
                      (activeItem == i ? " active-item" : "")
                    }
                  >
                    <i
                      style={{ fontSize: "1.15rem" }}
                      className={sideNavMenuIcon[i]}
                    ></i>
                    <span className="ms-2">{el}</span>
                  </li>
                ))}
              </ul>
            </div>
            <div className="dropdown">
              <div
                className="mb-3 d-flex justify-content-between align-items-center"
                id="dropdownProfile"
                data-bs-toggle="dropdown"
                aria-expanded="false"
                role="button"
              >
                <div className="d-flex" style={{ maxWidth: "80%" }}>
                  <img
                    className="rounded-circle border border-1 border-dark shadow"
                    src={profile.photoURL}
                    width={38}
                    alt="user profile picture"
                  />
                  <span className="fs-5 ms-2 my-auto text-truncate">
                    {profile.name}
                  </span>
                </div>
                <div>
                  <i className="bi bi-caret-right-fill fs-6 my-auto"></i>
                </div>
              </div>
              <ul className="dropdown-menu" aria-labelledby="dropdownProfile">
                <li
                  onClick={() => {
                    document
                      .querySelector('[data-bs-dismiss="offcanvas"')
                      .click();
                    localStorage.removeItem(nestBTOA(3, "user-credential"));
                    signOut(auth);
                  }}
                  onMouseEnter={(e) => {
                    if (e.target.outerHTML.startsWith("<a")) {
                      e.target.classList.remove("text-danger");
                      e.target.classList.remove("bg-light");
                      e.target.classList.add("text-light");
                      e.target.classList.add("bg-danger");
                    } else {
                      e.target
                        .querySelector("a")
                        .classList.remove("text-danger");
                      e.target.querySelector("a").classList.remove("bg-light");
                      e.target.querySelector("a").classList.add("text-light");
                      e.target.querySelector("a").classList.add("bg-danger");
                    }
                  }}
                  onMouseLeave={(e) => {
                    if (e.target.outerHTML.startsWith("<a")) {
                      e.target.classList.add("text-danger");
                      e.target.classList.add("bg-light");
                      e.target.classList.remove("text-light");
                      e.target.classList.remove("bg-danger");
                    } else {
                      e.target.querySelector("a").classList.add("text-danger");
                      e.target.querySelector("a").classList.add("bg-light");
                      e.target
                        .querySelector("a")
                        .classList.remove("text-light");
                      e.target.querySelector("a").classList.remove("bg-danger");
                    }
                  }}
                >
                  <a className="dropdown-item text-danger" href="#">
                    Sign Out
                  </a>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}

SideNav.propTypes = {
  activeItem: PropTypes.number.isRequired,
  setActiveItem: PropTypes.func.isRequired,
  sideNavMenuTitle: PropTypes.array.isRequired,
  sideNavMenuIcon: PropTypes.array.isRequired,
};
