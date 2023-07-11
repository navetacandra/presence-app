import AppIcon from "../../assets/app_icon.png";
import PropTypes from "prop-types";

export default function SideNav({
  activeItem,
  setActiveItem,
  sideNavMenuTitle,
  sideNavMenuIcon,
}) {
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
            style={{ transition: "all" }}
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
          <ul className="list-group">
            {sideNavMenuTitle.map((el, i) => (
              <li
                key={i}
                onClick={() => setActiveItem(i)}
                className={
                  "list-group-item" + (activeItem == i ? " active-item" : "")
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
