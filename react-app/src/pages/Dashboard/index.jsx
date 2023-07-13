import { useEffect, useState } from "react";
import SideNav from "./SideNav";
import DashboardScreen from "./Admin/Dashboard";
import WhatsAppScreen from "./Admin/WhatsApp";
import DaftarPegawaiScreen from "./Admin/DaftarPegawai";
import { auth, db, getUserData } from "../../firebase";
import { onValue, ref } from "firebase/database";
import ProfileScreen from "./Profile";

export default function Dashboard() {
  const [activeItem, setActiveItem] = useState(0);
  const [isOnline, setIsOnline] = useState(true);
  const [currentMenu, setCurrentMenu] = useState([]);

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

    if (!currentMenu.length) {
      setCurrentMenu(getUserData().role == 0 ? navMenu.admin : navMenu.user);
    }

    window.addEventListener("credential", (ev) => {
      setCurrentMenu(
        getUserData(ev.credential).role == 0 ? navMenu.admin : navMenu.user
      );
    });

    return () => {
      clearInterval(checkIsOnline);
      window.removeEventListener("credential", (ev) => {
        setCurrentMenu(
          getUserData(ev.credential).role == 0 ? navMenu.admin : navMenu.user
        );
      });
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentMenu]);

  const navMenu = {
    admin: [
      {
        icon: "bi bi-speedometer2",
        title: "Dashboard",
        element: <DashboardScreen />,
      },
      {
        icon: "bi bi-people-fill",
        title: "Daftar Pegawai",
        element: <DaftarPegawaiScreen />,
      },
      {
        icon: "bi bi-journal-text",
        title: "Laporan Absensi",
        element: null,
      },
      {
        icon: "bi bi-calendar-week",
        title: "Jadwal Absensi",
        element: null,
      },
      {
        icon: "bi bi-whatsapp",
        title: "WhatsApp",
        element: <WhatsAppScreen />,
      },
      {
        icon: "bi bi-person-fill",
        title: "Profile",
        element: <ProfileScreen />,
        hide: true,
      },
    ],
    user: [
      {
        icon: "bi bi-speedometer2",
        title: "Dashboard",
        element: <DashboardScreen />,
      },
      {
        icon: "bi bi-person-fill",
        title: "Profile",
        element: <ProfileScreen />,
        hide: true,
      },
    ],
  };

  return (
    <>
      <SideNav
        activeItem={activeItem}
        setActiveItem={setActiveItem}
        sideNavMenu={
          (getUserData()?.role ?? 3) == 0 ? navMenu.admin : navMenu.user
        }
      />

      {!isOnline ? (
        <div className="container mx-auto my-3">
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
        </div>
      ) : null}

      {currentMenu.filter((f, i) => i == activeItem)[0]?.element ?? null}
    </>
  );
}
