import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App.jsx";
// eslint-disable-next-line no-unused-vars
import * as Popper from "@popperjs/core";
import "bootstrap/dist/css/bootstrap.css";
import "bootstrap/dist/js/bootstrap.bundle.js";
import "bootstrap-icons/font/bootstrap-icons.css";
import "./assets/index.css";
import "./assets/app_icon.ico";

ReactDOM.createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
