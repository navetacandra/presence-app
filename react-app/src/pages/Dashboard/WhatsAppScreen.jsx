import { useEffect, useState } from "react";
import secret from "../../secret.json";

export default function WhatsAppScreen() {
  const [isLoading, setIsLoading] = useState(false);
  const [qr, setQr] = useState("");
  const [infoMe, setInfoMe] = useState({});

  useEffect(() => {
    setInterval(async () => {
      try {
        setIsLoading(true);
        const response = await fetch(`${secret.API_URL}/`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ key: "ma5terabsensi" }),
          mode: "cors",
        });
        const jsonReponse = await response.json();
        setQr("");
        setInfoMe({});
        if (!jsonReponse.isReady) {
          const qrResponse = await fetch(`${secret.API_URL}/qr`, {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify({ key: "ma5terabsensi" }),
            mode: "cors",
          });
          const jsonQrReponse = await qrResponse.json();
          console.log(jsonQrReponse.qrcode);
          setQr(jsonQrReponse.qrcode);
        } else {
          const profileData = jsonReponse.user;
          profileData.profilePicture =
            profileData.profilePicture ??
            "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png";
          profileData.id = profileData.id.replace("@c.us", "");
          let _matchId = profileData.id.match(
            // eslint-disable-next-line no-useless-escape
            /^(\d{2})(\d{3})(\d{4})(\d{0,})$/
          );
          if (_matchId) {
            profileData.id = `+${_matchId[1]} ${_matchId[2]}-${_matchId[3]}-${_matchId[4]}`;
          }
          setInfoMe(profileData);
        }
      } finally {
        setIsLoading(false);
      }
    }, 10000);
  }, []);

  return (
    <div className="container d-flex justify-content-center">
      <div className="card shadow mt-5 wa-card">
        <div className="card-body">
          <div className="fs-4 fw-bolder text-center">
            {isLoading ? "Loading..." : qr ? "Scan QR" : (infoMe.profilePicture && infoMe.name && infoMe.id) ? "Info Profil" : "Loading..."}
          </div>
          {qr ? (
            <div
              className="d-flex justify-content-center mx-auto my-auto"
              style={{ width: "90%", height: "90%" }}
            >
              <img src={qr} alt="WhatsApp QR" />
            </div>
          ) : (infoMe.profilePicture && infoMe.name && infoMe.id) ? (
            <ul className="list-group">
              <li
                className="list-group-item d-flex justify-content-center"
                style={{ width: "100%" }}
              >
                {infoMe.profilePicture ? (
                  <img
                    className="mx-auto rounded-circle"
                    src={infoMe.profilePicture}
                    alt="WhatsApp Profile Picture"
                    width={200}
                    height={200}
                  />
                ) : null}
              </li>
              <li className="list-group-item">
                <span className="fw-bolder">Nama:</span> {infoMe.name ?? "-"}
              </li>
              <li className="list-group-item">
                <span className="fw-bolder">No. Tel: </span>
                {infoMe.id ? infoMe.id.replace("@c.us", "") : "-"}
              </li>
            </ul>
          ) : null}
        </div>
      </div>
    </div>
  );
}
