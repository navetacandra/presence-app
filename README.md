## Presence
<img src="./app/assets/launcher_icon.png" alt="App Image" width="128px" height="128px" />
<br>
<img src="https://github.com/navetacandra/presence-app/assets/70505125/179640c5-a57f-4ed7-a5ee-19dba368b6db" alt="Flutter Icon" width="50px" />
<img src="https://github.com/navetacandra/presence-app/assets/70505125/302c2476-9021-40e0-9922-26c24fbbd45c" alt="NodeJS Icon" width="50px" />
<img src="https://github.com/navetacandra/presence-app/assets/70505125/e3652f5f-f44b-4a70-b35f-40bbd13a6ee1" alt="Arduino Icon" width="50px" />
<br><br>

Aplikasi dibangun dengan flutter dan terkoneksi dengan Firebase Realtime Database. Aplikasi ini berfungsi untuk mengubah data di dalam database. Database juga dihubungkan dengan NodeJS sebagai listener untuk mendeteksi perubahan di child database. Kemudian perangkat ESP8266 mengambil data ke database setiap user melakukan scan rfid.

Fitur-fitur yang ada antara lain:
- Menampilkan data pegawai
- Mengedit data pegawai
- Menghapus data pegawai
- Menambahkan kartu baru ke pegawai baru
- Menambahkan kariu ke pegawai yang sudah ada
- Mengubah jadwal absensi (tanggal dan jam)
- Mengubah mode alat (absen dan menambah kartu)
- Mengkoneksikan alat ke WiFi melalui aplikasi maupun browser
- Mengkoneksikan WhatsApp dengan scan QR
- Mendownload data absensi (maks. 1 bulan)
- Mengirim pesan WhatsApp ke nomor penanggung jawab
- Memvalidasi nomor WhatsApp saat mengubah/menambah data pegawai

Bahasa dan library yang digunakan:
- Flutter
  - ```get```
    Library ini digunakan sebagai state management dan route management dan membantu memercepat dalam pembuatan aplikasi karena kode yang ditulis dapat lebih ringkas.
  - ```http```
    Library ini digunakan sebagai mengirim request ke API, seperti mengirim request untuk mendapat QR WhatsApp.
  - ```firebase_core```
    Library ini digunakan untuk menginisialisasi firebase pada aplikasi.
  - ```firebase_auth```
    Library ini digunakan untuk melakukan kegiatan autentikasi seperti signup, signin, dan signout.
  - ```firebase_database```
    Library ini digunakan untuk melakukan query ke database, seperti menambah, mengambil, mengubah, dan menghapus data.
  - ```network_info_plus```
    Library ini berfungsi untuk mengambil info network yang digunakan/tersambung dengan device.
  - ```path_provider```
    Library ini berfungsi untuk mendapatkan path direktori download.
  - ```permission_handler```
    Library ini berfungsi untuk meminta izin/permissin untuk mengelola penyimpanan.
  - ```dio```
    Library ini digunakan untuk mendownload file CSV laporan absensi dari API.
  - ```email_validator```
    Library ini berfungsi untuk memvalidasi konten string apakah email atau bukan.
  - ```google_fonts```
    Library ini berfungsi untuk merubah style font pada widget text, seperti merubah warna, ukuran, ketebalan, dan jenis font.
  
- Javascript (NodeJS)
  - ```express```
    Library ini berfungsi sebagai http server untuk menerima request dari client (aplikasi).
  - ```body-parser```
    Library ini berfungsi untuk parsing data yang dikirim oleh client menjadi sebuah object.
  - ```dotenv```
     Library ini berfungsi untuk mengambil data dari local env variable dari file .env
  - ```firebase```
    Library ini digunakan untuk mendeteksi perubahan-perubahan pada child database, seperti mendeteksi perubahan pada daftar kehadiran.
  - ```crypto-js```
     Library ini berfungsi untuk melakukan enkripsi dan dekripsi password pada fungsi create user dan delete user.
  - ```qrcode-terminal```
    Library ini berfungsi untuk menampilkan QR WhatsApp pada console terminal.
  - ```qrcode```
     Library ini berfungsi untuk merubah token autentikasi WhatsApp menjadi gambar QR berbasis base64.
  - ```whatsapp-web.js```
    Library ini berfungsi sebagai WhatsApp Web API untuk menghubungkan WhatsApp dan mengirim pesan.
  - ```pm2```
    Library ini digunakan sebagai uptime manager agar server dapat berjalan secara terus meneru
    
- C++ (Arduino)
