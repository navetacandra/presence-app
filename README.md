## Presence
pla<img src="./app/assets/launcher_icon.png" alt="App Image" width="128px" height="128px" />
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
  - ```get``` <br>
    Library ini digunakan sebagai state management dan route management dan membantu memercepat dalam pembuatan aplikasi karena kode yang ditulis dapat lebih ringkas.
  - ```http``` <br>
    Library ini digunakan sebagai mengirim request ke API, seperti mengirim request untuk mendapat QR WhatsApp.
  - ```firebase_core``` <br>
    Library ini digunakan untuk menginisialisasi firebase pada aplikasi.
  - ```firebase_auth``` <br>
    Library ini digunakan untuk melakukan kegiatan autentikasi seperti signup, signin, dan signout.
  - ```firebase_database``` <br>
    Library ini digunakan untuk melakukan query ke database, seperti menambah, mengambil, mengubah, dan menghapus data.
  - ```network_info_plus``` <br>
    Library ini berfungsi untuk mengambil info network yang digunakan/tersambung dengan device.
  - ```path_provider``` <br>
    Library ini berfungsi untuk mendapatkan path direktori download.
  - ```permission_handler``` <br>
    Library ini berfungsi untuk meminta izin/permissin untuk mengelola penyimpanan.
  - ```dio``` <br>
    Library ini digunakan untuk mendownload file CSV laporan absensi dari API.
  - ```email_validator``` <br>
    Library ini berfungsi untuk memvalidasi konten string apakah email atau bukan.
  - ```google_fonts``` <br>
    Library ini berfungsi untuk merubah style font pada widget text, seperti merubah warna, ukuran, ketebalan, dan jenis font.
  
- Javascript (NodeJS)
  - ```express``` <br>
    Library ini berfungsi sebagai http server untuk menerima request dari client (aplikasi).
  - ```body-parser``` <br>
    Library ini berfungsi untuk parsing data yang dikirim oleh client menjadi sebuah object.
  - ```dotenv``` <br>
     Library ini berfungsi untuk mengambil data dari local env variable dari file .env
  - ```firebase``` <br>
    Library ini digunakan untuk mendeteksi perubahan-perubahan pada child database, seperti mendeteksi perubahan pada daftar kehadiran.
  - ```crypto-js``` <br>
     Library ini berfungsi untuk melakukan enkripsi dan dekripsi password pada fungsi create user dan delete user.
  - ```qrcode-terminal``` <br>
    Library ini berfungsi untuk menampilkan QR WhatsApp pada console terminal.
  - ```qrcode``` <br>
     Library ini berfungsi untuk merubah token autentikasi WhatsApp menjadi gambar QR berbasis base64.
  - ```whatsapp-web.js``` <br>
    Library ini berfungsi sebagai WhatsApp Web API untuk menghubungkan WhatsApp dan mengirim pesan.
  - ```pm2``` <br>
    Library ini digunakan sebagai uptime manager agar server dapat berjalan secara terus meneru
    
- C++ (Arduino)
  - ```ESP8266WebServer``` <br>
    Library ini digunakan sebagai WiFi Manager API.
  - ```ESP8266WiFi``` <br>
    Library ini digunakan untuk menyambungkan ESP8266 dengan WiFi.
  - ```FirebaseESP8266``` <br>
    Library ini digunakan untuk mengakses Firebase Realtime Database agar bisa melakukan query.
  - ```LiquidCrystal_I2C``` <br>
    Library ini digunakan untuk menampilkan tulisan ke LED LiquidCrystal_I2C.
  - ```LittleFS``` <br>
    Library ini digunakan sebagai menyimpan state untuk WiFi Manager dan Firebase Configuration.
  - ```MFRC522``` <br>
    Library ini digunakan sebagai reader tag RFID.
  - ```NTPClient``` <br>
    Library ini digunakan untuk mendapat waktu dari server NTP.
  - ```WiFiUdp``` <br>
    Library ini digunakan sebagai pendukung library NTPClient.
  - ```SPI``` <br>
    Library ini digunakan sebagai pendukung library MFRC522.

Cara kerja alat:
```flow
Mulai 
  └────────────────▸ Cek State WiFi ──────────▸ Mencoba Menghubungkan ke WiFi ────────────────▸ Berhasil ◂┼▸ Gagal
                                                                                                   │           │
                                                                                                   │           ▾
            ┌──────────────────────────────────── Absen (true) ◂──────────────────────┐            │   Masuk Konfigurasi WiFi ◂──┐
            ▾                                       │                                 │            │           │                 │
Cek Apakah Kartu Terdaftar                    Tambah Kartu (false)                 Cek Mode        │           ▾                 │
            │                                       │                                 ▴            │       Berhasil ◂┼▸ Gagal ───┘
            ▾                                       ▾                                 │            │           │
      Terdaftar ◂┼▸ Tidak               Cek Apakah Kartu Terdaftar                Scan Kartu ◂─────┴───────────┘
            │         │                             │
            ▾         ▾                             ▾
          Absen     Gagal                       Terdaftar ◂┼▸ Tidak ───┐
                                                      │                ▾
                                                      ▾         Menambah Kartu
                                                    Gagal
```

Menu dan Cara Kerjanya:
- Daftar Pegawai
  ```flow
  Ambil data pegawai ──▸ Ada Data  ◂─┼─▸ Kosong ──▸ "Hasil Tidak Ditemukan"
                                           │
                                           ▾
                                    Tampilkan Data
  ```
- Tambah Pegawai
  ```flow
  Menunggu user input data ──▸ Validasi data ──┐
          ▴                                    ▾
          └───────────────────────────────── Tidak ◂┼▸ valid ──▸ Tambah Pegawai
  ```
- Tambah Kartu
  ```flow
  Mengambil data kartu yang ada (belum terdaftar sebagai pegawai)
    │
    └──▸ Ada Data ◂┼▸ Kosong ─▸ "Tidak Ada Kartu Baru"
            │
            ▾
        Tampilkan Data ──▸ Menunggu user memilih kartu baru ──▸ Menunggu user memilih "pilih pegawai"/"tambah pegawai" ─┐
                                                                                                                        │
                    ┌──── Masuk Halaman Seperti Halaman Tambah Pegawai ◂───── Pilih Pegawai ◂┼▸ Tambah Pegawai ◂────────┘
                    │                                                                                 │
                    │                                                                                 ▾
                    └──▸ Pilih Pegawai ──▸ Update data pegawai                         Masuk ke halaman tambah pegawai
  ```
- Ganti Mode
  ```flow
  Stream nilai "mode" ke nilai switch
    └──▸ Jika switch dirubah nilainya ──▸ rubah nilai "mode" di database sesuai nilai switch
  ```
  
- Koneksi ESP8266
  ```flow
  Stream nilai gateway network yang terhubung
    │
    └──▸ Jika nilai gateway sama dengan gateway alat ─┐
                                                      ▾
    ┌─────────────────────────────────────────────── Ya ◂┼▸ Tidak ──▸ "Perangkat tidak terhubung dengan WiFi ESP WIFI MANAGER"
    │
    └──▸ Memastikan perangkat terhubung (request ke <gateway>/is-esp) ──▸ Ambil state esp ──▸ Kirim data state baru
  ```
- Koneksi WhatsApp
  ```flow
  Stream koneksi WhatsApp ke API
    │
    └▸ WhatsApp belum login ◂┼▸ WhatsApp sudah login ──▸ Ambil data akun yang terkoneksi
                │
                │
                └──▸ Request QR WhatsApp
  ```
- Buat Laporan
  ```flow
  User memilih bulan dan tanggal yang akan di rekap
    │
    └▸ Mendownload file CSV dari API sesuai request yang dikirim
  ```
- Jadwal Absen
  ```flow
  Mengambil jadwal absen yang sudah diterapkan
    │
    ├▸ User memilih tanggal untuk mengaktifkan atau menonaktifkan absen pada tanggal itu
    │
    └▸ User menyesuaikan jam/waktu mulai dan akhir kehadiran dan kepulangan
  ```