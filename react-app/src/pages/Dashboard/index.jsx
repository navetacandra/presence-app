import { useState } from "react";
import SideNav from "./SideNav";
import DashboardComponent from "./DashboardScreen";


export default function Dashboard() {
  const [activeItem, setActiveItem] = useState(0);
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
  const screens = [
    <DashboardComponent key={0} />
  ]

  return (
    <>
      <SideNav
        activeItem={activeItem}
        setActiveItem={setActiveItem}
        sideNavMenuTitle={sideNavMenuTitle}
        sideNavMenuIcon={sideNavMenuIcon}
      />
      {
        screens[activeItem]
      }
    </>
  );
}
