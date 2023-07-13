import { initializeApp } from "firebase/app";
import { firebaseConfig } from "./secret.json";
import { getAuth } from "firebase/auth";
import { getDatabase } from "firebase/database";
import { useEffect, useState } from "react";

initializeApp(firebaseConfig);

export const auth = getAuth();
export const db = getDatabase();
export const nestBTOA = (repeat, string) => {
  let str = string;
  if(str.length < 0) return '';
  for (let i = 0; i < repeat; i++) {
    str = window.btoa(str);
  }
  return str ?? '';
};
export const nestATOB = (repeat, string) => {
  let str = string;
  if(str.length < 0) return '';
  for (let i = 0; i < repeat; i++) {
    str = window.atob(str);
  }
  return str ?? '';
};
export const getUserData = (hasedData) => {
  let _data = hasedData ? hasedData : localStorage.getItem(nestBTOA(3, "user-credential"));
  _data = (typeof _data != "undefined" && _data != null) ? _data : nestBTOA(5, '{}')
  _data = nestATOB(5, _data);
  _data = JSON.parse(_data);
  return _data ?? {};
};

export function useLocalStorage(key, initialValue) {
  const [value, setValue] = useState(() => {
    const storedValue = localStorage.getItem(key);
    return storedValue !== null ? JSON.parse(storedValue) : initialValue;
  });

  useEffect(() => {
    // Update local storage when the value changes
    localStorage.setItem(key, JSON.stringify(value));
  }, [key, value]);

  // Return a value and setter function
  return [value, setValue];
}

export function setCredential(credential = nestBTOA(5, '{}')) {
  localStorage.setItem(nestBTOA(3, 'user-credential'), credential);

  var storageChangeEvent = new CustomEvent('credential', {
    detail: {
      credential
    }
  });
  window.dispatchEvent(storageChangeEvent);
}