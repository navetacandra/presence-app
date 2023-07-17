// ignore_for_file: unnecessary_overrides
import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:presence/app/routes/app_pages.dart';

class KoneksiEspController extends GetxController {
  final formField = GlobalKey<FormState>();
  final netInfo = NetworkInfo();
  RxString gateway = "".obs;
  RxBool showNetPass = false.obs;
  RxBool showFauthPass = false.obs;
  RxBool isEsp = false.obs;
  RxBool isLoading = false.obs;
  RxList networks = [].obs;

  TextEditingController ssid = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController apikey = TextEditingController();

  bool messageShown = false;
  int messageCounter = 0;
  bool setted = false;
  bool stream = false;

  @override
  void onInit() async {
    super.onInit();
    stream = true;
    streamGatewayESP();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    stream = false;
  }

  String? validateEmail(String? emailValue) {
    if (emailValue!.isEmpty) return "Auth Email wajib di-isi!";
    if (!EmailValidator.validate(emailValue)) return "Auth Email tidak valid!";
    return null;
  }

  void streamGatewayESP() async {
    while (stream) {
      if (messageCounter > 2) {
        messageShown = false;
        messageCounter = 0;
      }
      if (messageShown) {
        messageCounter++;
      }

      gateway.value = await netInfo.getWifiGatewayIP() ?? "";
      if (gateway.value == "192.168.255.0") {
        try {
          http.Response resIsESP = await http.get(
            Uri.parse(
              "http://192.168.250.250/is-esp",
            ),
          );
          isEsp.value = jsonDecode(resIsESP.body)['isEsp'] as bool;
          if (isEsp.isTrue) {
            try {
              http.Response resNetworks = await http.get(
                Uri.parse(
                  "http://192.168.250.250/network-list",
                ),
              );
              http.Response resFileState = await http.get(
                Uri.parse(
                  "http://192.168.250.250/file-state",
                ),
              );

              networks.value = jsonDecode(resNetworks.body)['networks'] as List;

              if (!setted) {
                ssid.text = jsonDecode(resFileState.body)['ssid'] ?? "";
                pass.text = jsonDecode(resFileState.body)['password'] ?? "";
                apikey.text = jsonDecode(resFileState.body)['apikey'] ?? "";
                setted = true;
              }
            } catch (e) {
              if (!messageShown) {
                Get.snackbar(
                  "Terjadi Kesalahan",
                  "",
                  backgroundColor: const Color.fromARGB(150, 255, 50, 50),
                  colorText: const Color.fromARGB(255, 15, 15, 15),
                  messageText: Text(
                    "Perangkat gagal terkoneksi dengan server",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: const Color.fromARGB(255, 15, 15, 15),
                    ),
                  ),
                );
                messageShown = true;
              }
            }
          } else {
            if (!messageShown) {
              Get.snackbar(
                "Terjadi Kesalahan",
                "",
                backgroundColor: const Color.fromARGB(150, 255, 50, 50),
                colorText: const Color.fromARGB(255, 15, 15, 15),
                messageText: Text(
                  "Perangkat tidak terhubung dengan WiFi \"ESP WIFI MANAGER\"",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: const Color.fromARGB(255, 15, 15, 15),
                  ),
                ),
              );
              messageShown = true;
            }
          }
        } catch (e) {
          if (!messageShown) {
            Get.snackbar(
              "Terjadi Kesalahan",
              "",
              backgroundColor: const Color.fromARGB(150, 255, 50, 50),
              colorText: const Color.fromARGB(255, 15, 15, 15),
              messageText: Text(
                "Perangkat gagal terkoneksi dengan server",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 15, 15, 15),
                ),
              ),
            );
            messageShown = true;
          }
        }
      } else {
        isEsp.value = false;
        if (!messageShown) {
          Get.snackbar(
            "Terjadi Kesalahan",
            "",
            backgroundColor: const Color.fromARGB(150, 255, 50, 50),
            colorText: const Color.fromARGB(255, 15, 15, 15),
            messageText: Text(
              "Perangkat tidak terhubung dengan WiFi \"ESP WIFI MANAGER\"",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: const Color.fromARGB(255, 15, 15, 15),
              ),
            ),
          );
          messageShown = true;
        }
      }

      await Future.delayed(const Duration(seconds: 5));
    }
  }

  void validateForm() async {
    isLoading.value = true;
    if (formField.currentState!.validate()) {
      try {
        http.Response submitData = await http.get(Uri.parse("http://192.168.250.250/connect?ssid=${ssid.text}&password=${pass.text}&apikey=${apikey.text}"));
        if (jsonDecode(submitData.body)['status'] == 'sent') {
          Get.snackbar(
            "Data Terkirim",
            "",
            backgroundColor: const Color.fromRGBO(0, 150, 0, .5),
            duration: const Duration(milliseconds: 1000),
            colorText: const Color.fromARGB(255, 255, 255, 255),
            messageText: Text(
              "Data berhasil dikirim ke server",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          );
          await Future.delayed(const Duration(milliseconds: 1200));
          Get.offAllNamed(Routes.HOME);
        }
      } catch (e) {
        Get.snackbar(
          "Terjadi Kesalahan",
          "",
          backgroundColor: const Color.fromARGB(150, 255, 50, 50),
          duration: const Duration(milliseconds: 1000),
          colorText: const Color.fromARGB(255, 15, 15, 15),
          messageText: Text(
            "Perangkat gagal terkoneksi dengan server",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: const Color.fromARGB(255, 15, 15, 15),
            ),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 1200));
      }
    }
    isLoading.value = false;
  }
}
