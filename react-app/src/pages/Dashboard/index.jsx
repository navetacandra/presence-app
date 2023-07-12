import { useEffect, useState } from "react";
import SideNav from "./SideNav";
import DashboardScreen from "./DashboardScreen";
import WhatsAppScreen from "./WhatsAppScreen";
import DaftarPegawaiScreen from "./DaftarPegawaiScreen";

export default function Dashboard() {
  const [activeItem, setActiveItem] = useState(0);
  const [isOnline, setIsOnline] = useState(true);

  useEffect(() => {
    const checkIsOnline = setInterval(() => {
      setIsOnline(window.navigator.onLine);
    }, 100);

    return () => {
      clearInterval(checkIsOnline);
    };
  }, []);

  const sideNavMenuTitle = [
    "Dashboard",
    "Daftar Pegawai",
    "Laporan Absensi",
    "Jadwal Absensi",
    "WhatsApp",
  ];
  const sideNavMenuIcon = [
    "bi bi-speedometer2",
    "bi bi-people-fill",
    "bi bi-journal-text",
    "bi bi-calendar-week",
    "bi bi-whatsapp",
  ];

  return (
    <>
      <SideNav
        activeItem={activeItem}
        setActiveItem={setActiveItem}
        sideNavMenuTitle={sideNavMenuTitle}
        sideNavMenuIcon={sideNavMenuIcon}
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

      {activeItem == 0 ? <DashboardScreen /> : null}
      {activeItem == 1 ? <DaftarPegawaiScreen /> : null}
      {activeItem == 2 ? null : null}
      {activeItem == 3 ? null : null}
      {activeItem == 4 ? <WhatsAppScreen /> : null}
    </>
  );
}
