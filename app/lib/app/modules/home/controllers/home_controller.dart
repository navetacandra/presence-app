// ignore_for_file: unnecessary_overridesimport 'dart:io';, unnecessary_overrides
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
  RxString hour = ''.obs;
  RxString minute = ''.obs;
  RxString second = ''.obs;
  RxString date = ''.obs;
  RxString month = ''.obs;
  RxString year = ''.obs;
  RxString name = '...'.obs;
  RxInt present = 0.obs;
  RxInt role = 1.obs;
  Map<String, List<List<Map>>> allMenus = {
    "admin": [
      [
        {
          "image": "assets/users.png",
          "label": "Daftar Siswa",
          "navigation": Routes.DAFTAR_SISWA,
        },
        {
          "image": "assets/user-plus.png",
          "label": "Tambah Siswa",
          "navigation": Routes.TAMBAH_SISWA,
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
    "support": [
      [{}]
    ],
    "user": [
      [
        {
          "image": "assets/users.png",
          "label": "Data Absen",
          "navigation": Routes.ABSEN_TABLE,
        }
      ]
    ]
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
      final tz = (DateTime.now().toUtc().add(const Duration(hours: 7)));
      hour.value = tz.hour.toString().length > 1 ? tz.hour.toString() : "0${tz.hour.toString()}";
      minute.value = tz.minute.toString().length > 1 ? tz.minute.toString() : "0${tz.minute.toString()}";
      second.value = tz.second.toString().length > 1 ? tz.second.toString() : "0${tz.second.toString()}";
      date.value = tz.day.toString().length > 1 ? tz.day.toString() : "0${tz.day.toString()}";
      month.value = months[tz.month - 1];
      year.value = tz.year.toString();
      if (role.value == 0) {
        DataSnapshot snap = await dbController.gets("/absensi/${month.value}/${date.value}/siswa");
        if (!snap.exists) {
          present.value = 0;
        } else {
          present.value = snap.children.length;
        }
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
