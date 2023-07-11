import { useState } from "react";
import Dashboard from "./pages/Dashboard";
import Login from "./pages/Login";
import Register from "./pages/Register";

function App() {
  const [login, setLogin] = useState(1);
  const authenticated = true;

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
