// ignore_for_file: unnecessary_overrides
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:presence/app/controllers/auth_controller.dart';
import 'package:presence/app/controllers/db_controller.dart';
import 'package:presence/app/routes/app_pages.dart';

class HomeController extends GetxController {
  final authController = Get.find<AuthController>();
  final dbController = Get.find<DbController>();
  RxString date = ''.obs;
  RxString month = ''.obs;
  RxString name = '...'.obs;
  Map<String, List<List<Map>>> allMenus = {
    "admin": [
      [
        {
          "image": "assets/users.png",
          "label": "Daftar Pegawai",
          "navigation": Routes.DAFTAR_PEGAWAI,
        },
        {
          "image": "assets/user-plus.png",
          "label": "Tambah Pegawai",
          "navigation": Routes.TAMBAH_PEGAWAI,
        },
        {
          "image": "assets/card-plus.png",
          "label": "Tambah Kartu",
          "navigation": Routes.TAMBAH_KARTU,
        },
        {
          "image": "assets/report.png",
          "label": "Buat Laporan",
          "navigation": Routes.LAPORAN_ABSEN,
        },
      ],
      [
        {
          "image": "assets/calendar.png",
          "label": "Jadwal Absen",
          "navigation": Routes.JADWAL_ABSEN,
        },
        {
          "image": "assets/switch.png",
          "label": "Ganti Mode",
          "navigation": Routes.KONTROL_MODE,
        },
        {
          "image": "assets/esp-hotspot.png",
          "label": "Koneksi ESP8266",
          "navigation": Routes.KONEKSI_ESP,
        },
        {
          "image": "assets/whatsapp.png",
          "label": "Koneksi WhatsApp",
          "navigation": Routes.KONEKSI_WHATSAPP,
        },
      ],
    ],
  };

  RxList currentMenu = [].obs;

  @override
  void onInit() {
    super.onInit();
    authController.streamCredential.listen(
      (User? user) {
        if (user == null) return;
        dbController.stream("users/${user.uid}").listen(
          (DatabaseEvent ev) {
            DataSnapshot snap = ev.snapshot;
            if (!snap.exists) return;
            name.value = snap.child("name").value as String;
            if ((snap.child("role").value as int) == 0) currentMenu.value = allMenus["admin"]!;
          },
        );
      },
    );
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
