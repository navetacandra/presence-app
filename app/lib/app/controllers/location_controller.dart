// ignore_for_file: unnecessary_overrides

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence/app/controllers/auth_controller.dart';
import 'package:presence/app/controllers/db_controller.dart';

class LocationController extends GetxController {
  final authController = Get.put(AuthController());
  final dbController = Get.put(DbController());
  double fenceLat = -6.058777934418119;
  double fenceLon = 106.50581821453851;
  double fenceRad = 210;
  List months = ['januari', 'februari', 'maret', 'april', 'mei', 'juni', 'juli', 'agustus', 'september', 'oktober', 'november', 'desember'];
  RxList prevPos = [].obs;

  @override
  void onInit() {
    super.onInit();
    _getPermission();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void _getPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      bool locSetting = await Geolocator.openLocationSettings();
      if (!locSetting) {
        _getPermission();
      }
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) _getPermission();
    }

    // Geolocator.

    if ((permission == LocationPermission.always || permission == LocationPermission.whileInUse) && serviceEnabled) {
      // _updatePosition();
      while (true) {
        if (authController.mAuth.currentUser != null) {
          Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best, forceAndroidLocationManager: true);
          // print(pos.latitude);
          // print(pos.longitude);
          if (!_isLocationInconsistent(pos)) {
            _checkLocation(pos, authController.mAuth.currentUser);
          } else {
            // ignore: avoid_print
            print("Fake GPS!");
          }
        }
      }
    }
  }

  bool _isLocationInconsistent(Position position) {
    if (prevPos.isNotEmpty) {
      double distanceThreshold = 100;

      for (var prevPosition in prevPos) {
        double distance = Geolocator.distanceBetween(
          prevPosition.latitude,
          prevPosition.longitude,
          position.latitude,
          position.longitude,
        );

        if (distance > distanceThreshold) {
          return true;
        }
      }
    }

    prevPos.add(position);

    int maxPositions = 10;
    if (prevPos.length > maxPositions) {
      prevPos.removeAt(0);
    }

    return false;
  }

  void _checkLocation(Position pos, User? user) async {
    try {
      DateTime tz = DateTime.now().toUtc().subtract(const Duration(hours: -7));
      double userLat = pos.latitude;
      double userLon = pos.longitude;

      double distance = Geolocator.distanceBetween(userLat, userLon, fenceLat, fenceLon);

      if (distance <= fenceRad) {
        final pegawaiData = await dbController.getDataPegawai(user!.email ?? "");
        if (!pegawaiData.exists) return;
        String pegawaiId = pegawaiData.children.first.child("id").value as String;
        DataSnapshot schedule = await dbController.gets("schedule");
        DataSnapshot dataAbsen = await dbController.gets("absensi/${months.elementAt(tz.month - 1)}/${tz.day}/pegawai/$pegawaiId");

        List<int> jamHadirStart = (schedule.child("jam_hadir_start").value as String).split(":").map((e) => int.parse(e)).toList();
        List<int> jamHadirEnd = (schedule.child("jam_hadir_end").value as String).split(":").map((e) => int.parse(e)).toList();
        List<int> jamPulangStart = (schedule.child("jam_pulang_start").value as String).split(":").map((e) => int.parse(e)).toList();
        List<int> jamPulangEnd = (schedule.child("jam_pulang_end").value as String).split(":").map((e) => int.parse(e)).toList();
        String time = '${"${tz.hour}".length < 2 ? "0${tz.hour}" : "${tz.hour}"}:${"${tz.minute}".length < 2 ? "0${tz.minute}" : "${tz.minute}"}';

        if (dataAbsen.exists) {
          if (dataAbsen.child("masuk").exists && !dataAbsen.child("pulang").exists) {
            if (tz.hour == jamPulangStart[0] && tz.minute >= jamPulangStart[1]) {
              await dbController.updates(
                "absensi/${months.elementAt(tz.month - 1)}/${tz.day}/pegawai/$pegawaiId",
                {
                  "id": pegawaiId,
                  "pulang": time,
                },
              );
              successMessage("Absen Pulang Berhasil", "Anda absen pulang pada pukul $time.");
            } else if (tz.hour > jamPulangStart[0] && tz.hour < jamPulangEnd[0]) {
              await dbController.updates(
                "absensi/${months.elementAt(tz.month - 1)}/${tz.day}/pegawai/$pegawaiId",
                {
                  "id": pegawaiId,
                  "pulang": time,
                },
              );
              successMessage("Absen Pulang Berhasil", "Anda absen pulang pada pukul $time.");
            } else if (tz.hour == jamPulangEnd[0] && tz.minute <= jamPulangEnd[1]) {
              await dbController.updates(
                "absensi/${months.elementAt(tz.month - 1)}/${tz.day}/pegawai/$pegawaiId",
                {
                  "id": pegawaiId,
                  "pulang": time,
                },
              );
              successMessage("Absen Pulang Berhasil", "Anda absen pulang pada pukul $time.");
            }
          }
        } else {
          if (tz.hour == jamHadirStart[0] && tz.minute >= jamHadirStart[1]) {
            await dbController.updates(
              "absensi/${months.elementAt(tz.month - 1)}/${tz.day}/pegawai/$pegawaiId",
              {
                "id": pegawaiId,
                "masuk": time,
                "status": "tepat",
              },
            );
            successMessage("Absen Masuk Berhasil", "Anda absen pada pukul $time dengan status tepat.");
          } else if (tz.hour > jamHadirStart[0] && tz.hour < jamHadirEnd[0]) {
            await dbController.updates(
              "absensi/${months.elementAt(tz.month - 1)}/${tz.day}/pegawai/$pegawaiId",
              {
                "id": pegawaiId,
                "masuk": time,
                "status": "tepat",
              },
            );
            successMessage("Absen Masuk Berhasil", "Anda absen pada pukul $time dengan status tepat.");
          } else if (tz.hour == jamHadirEnd[0] && tz.minute <= jamHadirEnd[1]) {
            await dbController.updates(
              "absensi/${months.elementAt(tz.month - 1)}/${tz.day}/pegawai/$pegawaiId",
              {
                "id": pegawaiId,
                "masuk": time,
                "status": "tepat",
              },
            );
            successMessage("Absen Masuk Berhasil", "Anda absen pada pukul $time dengan status tepat.");
          } else if (tz.hour == jamHadirEnd[0] && tz.minute > jamHadirEnd[1] && tz.minute > (jamHadirEnd[1] + 15)) {
            await dbController.updates(
              "absensi/${months.elementAt(tz.month - 1)}/${tz.day}/pegawai/$pegawaiId",
              {
                "id": pegawaiId,
                "masuk": time,
                "status": "telat",
              },
            );
            successMessage("Absen Masuk Berhasil", "Anda absen pada pukul $time dengan status telat.");
          }
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  void successMessage(String title, String message) {
    Get.showSnackbar(
      GetSnackBar(
        barBlur: .5,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color.fromRGBO(0, 150, 0, .5),
        duration: const Duration(milliseconds: 1000),
        titleText: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        messageText: Text(
          message,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
    );
  }
}
