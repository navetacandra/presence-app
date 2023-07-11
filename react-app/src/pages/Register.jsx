import PropTypes from "prop-types";
import { useState } from "react";

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

export default function Register() {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [errorName, setErrorName] = useState("");
  const [errorEmail, setErrorEmail] = useState("");
  const [errorPassword, setErrorPassword] = useState("");
  const [errorConfirmPassword, setErrorConfirmPassword] = useState("");
  const [message, setMessage] = useState({});

  async function signIn(e) {
    e.preventDefault();
    setMessage({});

    let isValid = validateForm();

    console.log(isValid);

    if (isValid) {
      setMessage({
        message: "Success cuy",
        type: "success",
      });
      // Register
    }
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

          {/* Login Form */}
          <form action="#" onSubmit={signIn}>
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
            <div className="mb-3 d-flex justify-content-center">
              <button
                type="submit"
                className="btn btn-primary text-center text-white fw-bold"
                style={{ width: "80%" }}
              >
                Sign Up
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}
