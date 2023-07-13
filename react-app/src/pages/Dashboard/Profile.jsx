import { useEffect, useState } from "react";
import { auth, db, getUserData, nestATOB, nestBTOA } from "../../firebase";
import {
  equalTo,
  get,
  orderByChild,
  query,
  ref,
  update,
} from "firebase/database";
import {
  EmailAuthProvider,
  signInWithCredential,
  updatePassword,
} from "firebase/auth";

export default function ProfileScreen() {
  const [userData, setUserData] = useState({});
  const [enableEditButton, setEnableEditButton] = useState(false);
  const [name, setName] = useState("");
  const [oldPass, setOldPass] = useState("");
  const [newPass, setNewPass] = useState("");

  useEffect(() => {
    if (!userData.uid) setUserData(getUserData());
    function handleStorageChange(ev) {
      setUserData(getUserData(ev.credential));
      if (name == userData.name) setEnableEditButton(false);
    }
    window.addEventListener("credential", handleStorageChange);

    return () => {
      window.removeEventListener("storage", handleStorageChange);
    };
  }, [name, userData]);

  async function updateProfile(e) {
    e.preventDefault();
    if (enableEditButton) {
      try {
        const _d = await get(
          query(
            ref(db, `pegawai`),
            orderByChild("email"),
            equalTo(userData.email)
          )
        );
        if (_d.exists()) {
          await update(ref(db, `pegawai/${Object.values(_d.val())[0].id}`), {
            name: name,
          });
        }
        await update(ref(db, `users/${userData.uid}`), { name: name });
      } catch (err) {
        //
      }
    }
  }

  async function _updatePassword(e) {
    e.preventDefault();
    try {
      const cred = await EmailAuthProvider.credential(userData.email, oldPass);
      await signInWithCredential(auth, cred);
      await updatePassword(auth.currentUser, newPass);
      await update(ref(db, `users/${auth.currentUser.uid}`), {
        password: nestBTOA(5, newPass),
      });
      e.target.reset();
      document.querySelector('[data-bs-dismiss="modal"]').click();
    } catch (err) {
      //
    }
  }

  return (
    <>
      <div className="container mt-3 d-flex justify-content-center align-items-center">
        <div className="card shadow mt-2 wa-card">
          <div className="card-body">
            <form onSubmit={(e) => updateProfile(e)}>
              <ul className="list-group">
                <li
                  className="list-group-item d-flex justify-content-center border-0"
                  style={{ width: "100%" }}
                >
                  <img
                    src={userData.photoURL}
                    width={200}
                    height={200}
                    className="rounded-circle border-1 border-dark shadow"
                  />
                </li>
                <li
                  className="list-group-item d-flex justify-content-start flex-wrap border-0"
                  style={{ width: "100%" }}
                >
                  <div className="fs-5 fw-bolder">Nama:</div>
                  <div className="ms-2" style={{ width: "80%" }}>
                    <input
                      className="form-control"
                      type="text"
                      defaultValue={userData.name}
                      onInput={(e) => {
                        setName(e.target.value);
                        setEnableEditButton(e.target.value != userData.name);
                      }}
                    />
                  </div>
                </li>
                <li
                  className="list-group-item d-flex justify-content-start flex-wrap border-0"
                  style={{ width: "100%" }}
                >
                  <div className="fs-5 fw-bolder">Email:</div>
                  <div className="ms-2" style={{ width: "80%" }}>
                    <input
                      className="form-control"
                      type="email"
                      defaultValue={userData.email}
                      readOnly
                    />
                  </div>
                </li>
                <li
                  className="list-group-item d-flex justify-content-center flex-wrap mt-5 border-0"
                  style={{ width: "100%" }}
                >
                  <div className="me-2">
                    <button
                      style={{ width: "100%" }}
                      className="btn btn-danger fs-5 fw-bold"
                      data-bs-toggle="modal"
                      data-bs-target="#update-password-modal"
                    >
                      Ganti Password
                    </button>
                  </div>
                  <div className="ms-2">
                    <button
                      type="submit"
                      style={{ width: "100%" }}
                      className={
                        "btn fs-5 fw-bold" +
                        (enableEditButton
                          ? " btn-warning"
                          : " btn-outline-warning disabled")
                      }
                      onClick={() => updateProfile()}
                    >
                      Edit
                    </button>
                  </div>
                </li>
              </ul>
            </form>
          </div>
        </div>
      </div>
      <div
        className="modal fade"
        id="update-password-modal"
        tabIndex="-1"
        aria-labelledby="update-password-modal-button"
        aria-hidden="true"
      >
        <div className="modal-dialog">
          <div className="modal-content">
            <div className="modal-header">
              <h5 className="modal-title" id="exampleModalLabel">
                Ganti Password
              </h5>
              <button
                type="button"
                className="btn-close"
                data-bs-dismiss="modal"
                aria-label="Close"
              ></button>
            </div>
            <div className="modal-body">
              <form onSubmit={(e) => _updatePassword(e)}>
                <div className="mb-3">
                  <input
                    type="password"
                    className="form-control"
                    onInput={(e) => setOldPass(e.target.value)}
                    placeholder="Password Lama"
                  />
                </div>
                <div className="mb-3">
                  <input
                    type="password"
                    className="form-control"
                    onInput={(e) => setNewPass(e.target.value)}
                    placeholder="Password Baru"
                  />
                </div>
                <div className="mb-2">
                  <button
                    type="submit"
                    className={
                      "btn" +
                      ((userData.password ?? "").length &&
                      oldPass == nestATOB(5, userData.password)
                        ? " btn-primary"
                        : " btn-outline-primary disabled")
                    }
                  >
                    Ganti Password
                  </button>
                </div>
              </form>
            </div>
            <div className="modal-footer">
              <button type="button" className="btn btn-primary">
                Save changes
              </button>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
