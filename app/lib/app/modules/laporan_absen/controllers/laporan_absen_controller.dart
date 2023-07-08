// ignore_for_file: unnecessary_overrides
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class LaporanAbsenController extends GetxController {
  final apikey = "presence-app";
  late String _localPath;
  late bool _permissionReady;
  late TargetPlatform? platform;
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
  int currentMonth = (DateTime.now().toUtc().add(const Duration(hours: 7))).month - 1;
  RxBool isLoading = false.obs;
  RxList<Map> tgl = [{}].obs;
  RxString selectedMonth = "januari".obs;

  @override
  void onInit() {
    selectedMonth.value = months[currentMonth];
    if (Platform.isAndroid) {
      platform = TargetPlatform.android;
    } else {
      platform = TargetPlatform.iOS;
    }

    clearTgl();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void clearTgl() {
    tgl.clear();
    for (var i = 0; i < 31; i++) {
      tgl.add({"key": (i + 1).toString(), "active": false});
    }
  }

  Future<bool> _checkPermission() async {
    if (platform == TargetPlatform.android) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath())!;

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String?> _findLocalPath() async {
    if (platform == TargetPlatform.android) {
      return "/sdcard/download/";
    } else {
      var directory = await getApplicationDocumentsDirectory();
      return '${directory.path}${Platform.pathSeparator}Download';
    }
  }

  void downloadReport() async {
    isLoading.value = true;
    _permissionReady = await _checkPermission();
    if (_permissionReady) {
      await _prepareSaveDir();
      try {
        List tgls = tgl.where((val) => (val['active'] as bool) == true).toList().map((val) => val["key"]).toList();
        tgls.sort((a, b) => (a).compareTo(b));
        DateTime currentTime = DateTime.now().toUtc().add(const Duration(hours: 7));
        String filePath =
            "${_localPath}PresentData-${currentTime.day.toString()}-${currentTime.month.toString()}-${currentTime.year.toString()}-${currentTime.hour.toString()}${currentTime.minute.toString()}${currentTime.second.toString()}${currentTime.millisecond.toString()}.csv";

        await Dio().download(
          "https://ma5terabsensi--ma5terabsensi1.repl.co/export-csv?key=$apikey&month=$selectedMonth&tanggal=${tgls.join(',')}",
          filePath,
        );
        Get.snackbar(
          "File Berhasil di-Download!",
          "",
          backgroundColor: const Color.fromRGBO(0, 150, 0, .5),
          colorText: Colors.white,
          messageText: Text(
            filePath,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        );
      } catch (e) {
        Get.snackbar(
          "Terjadi kesalahan",
          "",
          backgroundColor: const Color.fromARGB(150, 255, 50, 50),
          colorText: const Color.fromARGB(255, 15, 15, 15),
          messageText: Text(
            "Terjadi kesalahan saat mendownload",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: const Color.fromARGB(255, 15, 15, 15),
            ),
          ),
        );
      } finally {
        isLoading.value = false;
      }
    }
  }
}
