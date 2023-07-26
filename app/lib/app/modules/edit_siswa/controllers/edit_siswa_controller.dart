// ignore_for_file: unnecessary_overrides
import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence/app/controllers/db_controller.dart';
import 'package:presence/app/controllers/whatsapp_controller.dart';

class EditSiswaController extends GetxController {
  final dbC = Get.find<DbController>();
  final waController = Get.put<WhatsappController>(WhatsappController());
  final formField = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  RegExp numberRegex = RegExp(r"[0-9]");

  List<TextEditingController> textFieldControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  List<String> textFieldName = [
    "WhatsApp siswa",
    "WhatsApp wali kelas",
    "WhatsApp wali murid",
  ];
  RxList validationErrors = ["", "", ""].obs;
  RxBool isLoading = false.obs;
  final RxString _id = "".obs;
  RxMap siswaData = {}.obs;

  String get id => _id.value;

  @override
  void onInit() async {
    _id.value = Get.arguments["id"];
    DataSnapshot dataSiswa = await dbC.gets("siswa/$id");
    if (!dataSiswa.exists) {
      Get.back();
      Get.showSnackbar(
        GetSnackBar(
          duration: const Duration(seconds: 3),
          titleText: Text(
            "Siswa Tidak Ditemukan",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 15, 15, 15),
              fontSize: 12,
            ),
          ),
          messageText: Text(
            "Terjadi kesalahan saat mengedit siswa",
            style: GoogleFonts.poppins(
              color: const Color.fromARGB(255, 15, 15, 15),
              fontSize: 12,
            ),
          ),
          backgroundColor: const Color.fromARGB(150, 255, 50, 50),
        ),
      );
    } else {
      siswaData.value = {
        "name": dataSiswa.child("name").value,
        "email": dataSiswa.child("email").value,
        "telSiswa": dataSiswa.child("telSiswa").value,
        "telWaliKelas": dataSiswa.child("telWaliKelas").value,
        "telWaliMurid": dataSiswa.child("telWaliMurid").value,
      };
      nameController.value =
          TextEditingValue(text: siswaData["name"] as String);
      emailController.value =
          TextEditingValue(text: siswaData["email"] as String);
      textFieldControllers[0].value =
          TextEditingValue(text: siswaData["telSiswa"] as String);
      textFieldControllers[1].value =
          TextEditingValue(text: siswaData["telWaliKelas"] as String);
      textFieldControllers[2].value =
          TextEditingValue(text: siswaData["telWaliMurid"] as String);
    }
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

  String? validateName(String? nameValue) {
    if (nameValue!.isEmpty) return "Nama wajib di-isi!";
    return null;
  }

  String? validateEmail(String? emailValue) {
    if (emailValue!.isEmpty) return "Email wajib di-isi!";
    if (!EmailValidator.validate(emailValue)) return "Email tidak valid!";
    if (EmailValidator.validate(emailValue) &&
        !emailValue.endsWith("@gmail.com")) {
      return "Email harus beralamat gmail.com!";
    }
    return null;
  }

  Future<void> validatePhone() async {
    for (var i = 0; i < textFieldControllers.length; i++) {
      String number = textFieldControllers[i].text;
      if (i == 0 && number == siswaData["telSiswa"]) {
        validationErrors[i] = "";
      }
      if (i == 1 && number == siswaData["telWaliKelas"]) {
        validationErrors[i] = "";
      }
      if (i == 2 && number == siswaData["telWaliMurid"]) {
        validationErrors[i] = "";
      }
      if (number.isEmpty) {
        validationErrors[i] = "${textFieldName[i]} wajib di-isi!";
      } else if (number.isNotEmpty && !numberRegex.hasMatch(number)) {
        validationErrors[i] = "${textFieldName[i]} tidak valid";
      } else if (number.isNotEmpty && number.length < 10) {
        validationErrors[i] = "${textFieldName[i]} minimal berisi 10 karakter!";
      } else if (number.length > 13) {
        validationErrors[i] =
            "${textFieldName[i]} maksimal berisi 13 karakter!";
      } else {
        final resp = await waController.checkIsOnWhatsApp(number);

        if (resp == 400) {
          validationErrors[i] = "WhatsApp belum terkoneksi!";
        }
        if (resp == 404) {
          validationErrors[i] = "${textFieldName[i]} tidak terdaftar!";
        }
        if (resp == 500) {
          validationErrors[i] = "Terjadi kesalahan saat pengecakan!";
        }
        if (resp == 200) {
          validationErrors[i] = "";
        }
      }
    }
  }

  void validateForm() async {
    isLoading.value = true;
    await validatePhone();
    if (formField.currentState!.validate()) {
      try {
        await dbC.updates("siswa/$id", {
          "name": nameController.text,
          "email": emailController.text,
          "telSiswa": textFieldControllers[0].text,
          "telWaliKelas": textFieldControllers[1].text,
          "telWaliMurid": textFieldControllers[2].text,
        });
        Get.back();
        Get.showSnackbar(
          GetSnackBar(
            backgroundColor: const Color.fromRGBO(0, 150, 0, .5),
            duration: const Duration(milliseconds: 1500),
            snackPosition: SnackPosition.BOTTOM,
            messageText: Text(
              "Berhasil mengedit siswa!",
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: Get.width * .05,
                fontWeight: FontWeight.w400,
              ),
            ),
            borderRadius: Get.width * .025,
          ),
        );
      } catch (e) {
        Get.showSnackbar(
          GetSnackBar(
            backgroundColor: const Color.fromRGBO(255, 0, 0, .8),
            duration: const Duration(milliseconds: 1500),
            snackPosition: SnackPosition.BOTTOM,
            messageText: Text(
              "Gagal mengedit siswa!",
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: Get.width * .05,
                fontWeight: FontWeight.w400,
              ),
            ),
            borderRadius: Get.width * .025,
          ),
        );
      }
    }

    isLoading.value = false;
  }
}
