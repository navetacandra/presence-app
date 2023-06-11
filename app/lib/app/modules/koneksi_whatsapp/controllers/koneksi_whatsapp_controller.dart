// ignore_for_file: unnecessary_overrides
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence/app/controllers/whatsapp_controller.dart';
import 'package:presence/app/data/random_data.dart';

class KoneksiWhatsappController extends GetxController {
  final _waController = Get.put<WhatsappController>(WhatsappController());
  RxMap isReady = {}.obs;
  RxBool isQueryLoading = false.obs;
  RxString qrcode = blankWhiteImage.obs;

  RxBool streamingIsReady = true.obs;
  RxBool streamingQrCode = false.obs;
  RxBool logoutLoading = false.obs;

  @override
  void onInit() async {
    super.onInit();
    streamIsReady();
    streamingQrCode();
  }

  @override
  void onClose() {
    super.onClose();
    streamingIsReady.value = false;
    streamingQrCode.value = false;
  }

  void streamIsReady() async {
    while (streamingIsReady.value) {
      isQueryLoading.value = true;
      final response = await _waController.getIsReady() ?? {};
      isReady.value = response;
      isQueryLoading.value = false;

      if (logoutLoading.isTrue) {
        logoutLoading.value = false;
      }

      if (response["isReady"] == null) {
        Get.snackbar(
          "Terjadi Kesalahan",
          "",
          backgroundColor: const Color.fromARGB(150, 255, 50, 50),
          colorText: const Color.fromARGB(255, 15, 15, 15),
          messageText: Text(
            "Tidak ada koneksi atau server WhatsApp terputus",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: const Color.fromARGB(255, 15, 15, 15),
            ),
          ),
        );
      }

      if (response["isReady"] ?? false) {
        streamingQrCode.value = false;
      } else {
        streamingQrCode.value = true;
        streamQrCode();
      }

      await Future.delayed(const Duration(seconds: 5));
    }
  }

  void streamQrCode() async {
    while (streamingQrCode.value) {
      final response = await _waController.getQrCode() ?? blankWhiteImage;
      qrcode.value = response;
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  void logoutSession() async {
    logoutLoading.value = true;
    await _waController.logoutSession();
  }
}
