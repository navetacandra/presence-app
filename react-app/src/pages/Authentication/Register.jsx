import {
  createUserWithEmailAndPassword,
  updateProfile,
} from "firebase/auth";
import PropTypes from "prop-types";
import { useEffect, useState } from "react";
import { auth, db, nestBTOA } from "../../firebase";
import { ref, update } from "firebase/database";

function FormControl({ id, label, type, className, placeholder, onChange }) {
  return (
    <>
      <label htmlFor={id} className="form-label">
        {label}
      </label>
      <input
        type={type ?? "text"}
        className={
          "form-control" + ((className ?? "").length ? ` ${className}` : "")
        }
        id={id}
        placeholder={placeholder}
        onChange={onChange}
      />
    </>
  );
}

FormControl.propTypes = {
  id: PropTypes.string.isRequired,
  label: PropTypes.string.isRequired,
  type: PropTypes.string,
  className: PropTypes.string,
  placeholder: PropTypes.string,
  onChange: PropTypes.any,
};

export default function Register({ setLogin }) {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [errorName, setErrorName] = useState("");
  const [errorEmail, setErrorEmail] = useState("");
  const [errorPassword, setErrorPassword] = useState("");
  const [errorConfirmPassword, setErrorConfirmPassword] = useState("");
  const [message, setMessage] = useState({});
  const [isOnline, setIsOnline] = useState(true);
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    const checkIsOnline = setInterval(() => {
      setIsOnline(window.navigator.onLine);
      if (isOnline) {
        fetch("https://www.example.com", { method: "HEAD", mode: "no-cors" })
          .then(() => {
            setIsOnline(true);
          })
          .catch(() => {
            setIsOnline(false);
          });
      }
    }, 100);

    return () => {
      clearInterval(checkIsOnline);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function signUp(e) {
    e.preventDefault();
    if (!isOnline) return;

    setIsLoading(true);
    setMessage({});
    let isValid = validateForm();

    if (isValid) {
      // Register
      try {
        const userCredential = await createUserWithEmailAndPassword(
          auth,
          email,
          password
        );
        const { user } = userCredential;
          
          update(ref(db, `users/${user.uid}`), {
            email,
            name,
            role: 3,
            uid: user.uid,
            photoURL:
              "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
              password: nestBTOA(5, password),
            })
            .then(() => {
            updateProfile(user, {
              displayName: name,
              photoURL:
              "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
            })
              .catch((err) => console.log(err));
          })
          .catch((err) => console.log(err));
      } catch (err) {
        if (err.code == "auth/email-already-in-use") {
          setMessage({
            type: "danger",
            message: "Akun sudah terdaftar.",
          });
        }
        if (err.code == "auth/too-many-requests") {
          setMessage({
            type: "danger",
            message: "Terlalu banyak percobaan! coba lagi nanti.",
          });
        }
        if (err.code == "auth/network-error") {
          setMessage({
            type: "danger",
            message: "Terjadi kesalahan jaringan.",
          });
        }

        if (err.code == "auth/weak-password") {
          setErrorPassword("Password lemah");
        }
      }
    }
    setIsLoading(false);
  }

  function validateForm() {
    let validName = false;
    let validEmail = false;
    let validPassword = false;
    let validConfirmPassword = false;

    if (name.trim().length < 1) {
      setErrorName("Nama wajib di-isi!");
      validName = false;
    } else {
      setErrorName("");
      validName = true;
    }

    if (email.trim().length < 1) {
      setErrorEmail("Email wajib di-isi!");
      validEmail = false;
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim())) {
      setErrorEmail("Email tidak valid!");
      validEmail = false;
    } else if (!email.trim().endsWith("gmail.com")) {
      setErrorEmail("Email harus beralamat gmail.com!");
      validEmail = false;
    } else {
      setErrorEmail("");
      validEmail = true;
    }

    if (password.length < 1) {
      setErrorPassword("Password wajib di-isi!");
      validPassword = false;
    } else if (password.length > 0 && password.length < 6) {
      setErrorPassword("Password minimal berisi 6 karakter!");
      validPassword = false;
    } else {
      setErrorPassword("");
      validPassword = true;
    }

    if (confirmPassword.length < 1) {
      setErrorConfirmPassword("Konfirmasi Password wajib di-isi!");
      validConfirmPassword = false;
    } else if (confirmPassword.length > 0 && confirmPassword.length < 6) {
      setErrorConfirmPassword("Konfirmasi Password minimal berisi 6 karakter!");
      validConfirmPassword = false;
    } else if (confirmPassword != password) {
      setErrorConfirmPassword("Konfirmasi Password tidak sesuai!");
      validConfirmPassword = false;
    } else {
      setErrorConfirmPassword("");
      validConfirmPassword = true;
    }

    return validName && validEmail && validPassword && validConfirmPassword;
  }

  return (
    <div
      className="d-flex justify-content-center align-items-center"
      style={{ minHeight: "90vh" }}
    >
      <div className="card rounded shadow" style={{ minWidth: "50vw" }}>
        <div className="card-body">
          <h2 className="mb-2 text-center">Sign Up</h2>
          {/* Alert */}
          {message.message ? (
            <div
              className={
                "mb-1 alert alert-dismissible fade show alert-" + message.type
              }
              role="alert"
            >
              {message.message}
              <button
                type="button"
                className="btn-close"
                data-bs-dismiss="alert"
                aria-label="Close"
                onClick={() => setMessage({})}
              ></button>
            </div>
          ) : null}
          {!isOnline ? (
            <div
              className="alert alert-danger d-flex align-items-center"
              role="alert"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width={24}
                height={24}
                fill="currentColor"
                className="bi bi-exclamation-triangle-fill flex-shrink-0 me-2"
                viewBox="0 0 16 16"
                role="img"
                aria-label="Warning:"
              >
                <path d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5c.535 0 .954.462.9.995l-.35 3.507a.552.552 0 0 1-1.1 0L7.1 5.995A.905.905 0 0 1 8 5zm.002 6a1 1 0 1 1 0 2 1 1 0 0 1 0-2z" />
              </svg>
              <div>Anda tidak terhubung dengan internet!</div>
            </div>
          ) : null}

          {/* Register Form */}
          <form action="#" onSubmit={signUp}>
            <div className="mb-3">
              <FormControl
                id="name"
                label="Nama"
                placeholder="Nama"
                type="text"
                onChange={(e) => setName(e.target.value)}
              />
              <p className="fs-6 text-danger">{errorName}</p>
            </div>
            <div className="mb-3">
              <FormControl
                id="email"
                label="Alamat Email"
                placeholder="username@gmail.com"
                type="email"
                onChange={(e) => setEmail(e.target.value)}
              />
              <p className="fs-6 text-danger">{errorEmail}</p>
            </div>
            <div className="mb-3">
              <FormControl
                id="password"
                label="Password"
                placeholder="▪▪▪▪▪▪"
                type="password"
                onChange={(e) => setPassword(e.target.value)}
              />
              <p className="fs-6 text-danger">{errorPassword}</p>
            </div>
            <div className="mb-4">
              <FormControl
                id="confirm-password"
                label="Konfirmasi Password"
                placeholder="▪▪▪▪▪▪"
                type="password"
                onChange={(e) => setConfirmPassword(e.target.value)}
              />
              <p className="fs-6 text-danger">{errorConfirmPassword}</p>
            </div>
            <div className="mb-1 d-flex justify-content-center">
              <button
                type="submit"
                className="btn btn-primary text-center text-white fw-bold"
                style={{ width: "80%" }}
              >
                {!isLoading ? (
                  "Sign Up"
                ) : (
                  <div className="spinner-border" role="status">
                    <span className="visually-hidden">Loading...</span>
                  </div>
                )}
              </button>
            </div>
            <hr />
            <div className="mb-3 text-center">
              <span className="text-muted">
                Sudah punya akun?{" "}
                <a
                  className="text-decoration-none"
                  href="#"
                  onClick={(e) => {
                    e.preventDefault();
                    setLogin(1);
                  }}
                >
                  Masuk Disini
                </a>
              </span>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}

Register.propTypes = { setLogin: PropTypes.func };
