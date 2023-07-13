import { useEffect, useState } from "react";
import Dashboard from "./pages/Dashboard";
import Login from "./pages/Authentication/Login";
import Register from "./pages/Authentication/Register";
import { onAuthStateChanged } from "firebase/auth";
import { auth, db, nestBTOA, setCredential } from "./firebase";
import { onValue, ref } from "firebase/database";

function App() {
  const [login, setLogin] = useState(1);
  const [authenticated, setAuthenticated] = useState(false);

  useEffect(() => {
    window.onstorage = (e) => console.log(e);
    onAuthStateChanged(auth, (user) => {
      if (user) {
        onValue(ref(db, `users/${user.uid}`), (snap) => {
          setCredential(nestBTOA(5, JSON.stringify(snap.val())));
        });
        setAuthenticated(true);
      } else {
        setAuthenticated(false);
      }
    });

    return () => {
      setAuthenticated(false);
    };
  }, []);

  return (
    <>
      {authenticated ? (
        <Dashboard />
      ) : (
        <>
          {login ? <Login setLogin={setLogin} /> : null}
          {!login ? <Register setLogin={setLogin} /> : null}
        </>
      )}
    </>
  );
}

export default App;
