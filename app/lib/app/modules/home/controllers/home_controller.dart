// ignore_for_file: unnecessary_overridesimport 'dart:io';
import 'dart:async';
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
  RxInt present = 0.obs;
  RxInt role = 1.obs;
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
  List<String> months = [
    "januari",
    "februari",
    "maret",
    "april",
    "mei",
    "juni",
    "juli",
    "agustus",
    "september",
    "oktober",
    "november",
    "desember",
  ];

  RxList currentMenu = [].obs;

  

  @override
  void onInit() async {
    super.onInit();
    authController.streamCredential.listen(
      (User? user) {
        if (user == null) return;
        dbController.stream("users/${user.uid}").listen(
          (DatabaseEvent ev) {
            DataSnapshot snap = ev.snapshot;
            if (!snap.exists) return;
            name.value = snap.child("name").value as String;
            role.value = (snap.child("role").value as int);
            if (role.value == 0) {
              currentMenu.value = allMenus["admin"] ?? [];
            } else if (role.value == 1) {
              currentMenu.value = allMenus["moderator"] ?? [];
            } else if (role.value == 2) {
              currentMenu.value = allMenus["support"] ?? [];
            } else if (role.value == 3) {
              currentMenu.value = allMenus["user"] ?? [];
            } else {
              currentMenu.value = [];
            }
          },
        );
      },
    );
  }

  @override
  void onReady() async {
    super.onReady();
    while (true) {
      date.value = (DateTime.now().toUtc().add(const Duration(hours: 7))).day.toString();
      month.value = months[(DateTime.now().toUtc().add(const Duration(hours: 7))).month - 1];
      DataSnapshot snap = await dbController.gets("/absensi/${month.value}/${date.value}/pegawai");
      if (!snap.exists) {
        present.value = 0;
      } else {
        present.value = snap.children.length;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
