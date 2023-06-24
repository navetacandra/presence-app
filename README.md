## Presence
<img src="./app/assets/launcher_icon.png" alt="App Image" width="128px" height="128px" />

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