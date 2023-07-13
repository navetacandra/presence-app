import { initializeApp } from "firebase/app";
import { firebaseConfig } from "./secret.json";
import { getAuth } from "firebase/auth";
import { getDatabase } from "firebase/database";

initializeApp(firebaseConfig);

export const auth = getAuth();
export const db = getDatabase();
export const nestBTOA = (repeat, string) => {
  let str = string;
  for (let i = 0; i < repeat; i++) {
    str = window.btoa(str);
  }
  return str;
};
export const nestATOB = (repeat, string) => {
  let str = string;
  for (let i = 0; i < repeat; i++) {
    str = window.atob(str);
  }
  return str;
};
export const getUserData = () => {
  let _data = localStorage.getItem(nestBTOA(3, "user-credential"));
  _data = nestATOB(5, _data ?? nestBTOA(5, '{}'));
  _data = JSON.parse(_data);
  return _data ?? '';
};
