// ignore_for_file: unnecessary_overrides
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class WhatsappController extends GetxController {
  final apikey = "presence";
  Uri _host({
    String? path = "/",
  }) =>
      Uri.parse("http://103.181.183.181:3000$path");

  @override
  void onInit() {
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

  Future<Map<String, dynamic>?> getIsReady() async {
    try {
      final response = await http.post(
        _host(),
        body: {
          "key": apikey,
        },
      ).timeout(const Duration(seconds: 30));
      if ([200, 400].contains(response.statusCode)) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  Future<String?> getQrCode() async {
    try {
      final response = await http.post(
        _host(path: "/qr"),
        body: {
          "key": apikey,
        },
      );
      if (response.statusCode == 200) {
        final parsedData = jsonDecode(response.body);
        final base64 = parsedData["qrcode"].toString();

        return base64.isEmpty ? null : base64.replaceFirst(RegExp(r'data:(.*);base64,'), "");
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<int?> checkIsOnWhatsApp(String? number) async {
    try {
      final response = await http.post(
        _host(path: "/onwhatsapp"),
        body: {
          "key": apikey,
          "number": number,
        },
      );
      return response.statusCode;
    } catch (e) {
      return 400;
    }
  }

  Future<void> logoutSession() async {
    try {
      final response = await http.post(
        _host(path: "/logout"),
        body: {
          "key": apikey,
        },
      );
      if (response.statusCode != 200) {
        Get.snackbar(
          "Sign Out Error",
          "",
          backgroundColor: const Color.fromARGB(150, 255, 50, 50),
          colorText: const Color(0XFF0f0f0f),
          messageText: Text(
            "WhatsApp error while signing out",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: const Color(0XFF0f0f0f),
            ),
          ),
        );
      }
    } catch (e) {
      Get.snackbar(
        "Sign Out Error",
        "",
        backgroundColor: const Color.fromARGB(150, 255, 50, 50),
        colorText: const Color(0XFF0f0f0f),
        messageText: Text(
          "WhatsApp error while signing out",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: const Color(0XFF0f0f0f),
          ),
        ),
      );
    }
  }
}
