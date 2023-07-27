// ignore_for_file: unnecessary_overrides
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence/app/controllers/auth_controller.dart';
import 'package:presence/app/controllers/db_controller.dart';
import 'package:presence/app/routes/app_pages.dart';

class AbsenTableController extends GetxController {
  final authC = Get.find<AuthController>();
  final dbC = Get.find<DbController>();
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
  RxString currentDate = "1".obs;
  RxString currentMonth = "januari".obs;
  RxBool isStreamMonth = false.obs;
  RxList<Map> dataAbsenList = [{}].obs;

  @override
  void onInit() {
    super.onInit();
    isStreamMonth.value = true;
    streamMonth();
    getMonthsReport();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    isStreamMonth.value = false;
  }

  void streamMonth() async {
    while (isStreamMonth.isTrue) {
      final tz = (DateTime.now().toUtc().add(const Duration(hours: 7)));
      int currentMonthIndex = tz.month - 1;
      currentDate.value = tz.day.toString();
      currentMonth.value = months[currentMonthIndex];
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  void getMonthsReport() async {
    User? currentUser = authC.mAuth.currentUser;
    if (currentUser == null) Get.offAllNamed(Routes.HOME);
    DataSnapshot data = await dbC.mDb.ref('/siswa').orderByChild('email').equalTo(currentUser!.email).get();
    if (!data.exists) {
      Get.snackbar(
        "",
        "",
        colorText: Colors.white,
        backgroundColor: const Color.fromRGBO(225, 10, 10, .7),
        titleText: Text(
          "Email tidak ditemukan!",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        messageText: Text(
          "Siswa dengan email ${currentUser.email} tidak ditemukan.",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      );
    } else {
      String siswaId = data.children.first.child("id").value as String;
      dataAbsenList.clear();
      for (var i = 0; i < 31; i++) {
        DataSnapshot dataAbsen = await dbC.mDb.ref('/absensi/${currentMonth.value}/${i + 1}/siswa/$siswaId').get();
        if (!dataAbsen.exists && i + 1 < int.parse(currentDate.value)) {
          dataAbsenList.add(
            {
              "tanggal": (i + 1).toString(),
              "masuk": "-",
              "status": "Alpha",
              "pulang": "-",
            },
          );
        } else if (!dataAbsen.exists && i + 1 >= int.parse(currentDate.value)) {
          dataAbsenList.add(
            {
              "tanggal": (i + 1).toString(),
              "masuk": "-",
              "status": "-",
              "pulang": "-",
            },
          );
        } else {
          dataAbsenList.add(
            {
              "tanggal": (i + 1).toString(),
              "masuk": dataAbsen.child("masuk").value ?? "-",
              "status": (dataAbsen.child("status").value as String).capitalizeFirst ?? "-",
              "pulang": dataAbsen.child("pulang").value ?? "-",
            },
          );
        }
      }
    }
  }
}
