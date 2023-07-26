// ignore_for_file: unnecessary_overrides
import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence/app/controllers/db_controller.dart';
import 'package:presence/app/controllers/whatsapp_controller.dart';
import 'package:presence/app/routes/app_pages.dart';
import 'package:uuid/uuid.dart';

class TambahKartuProsesController extends GetxController {
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
  final RxString _method = "".obs;
  final RxString _cardId = "".obs;
  RxList siswa = [].obs;
  final selectedSiswa = <String, String>{}.obs;

  String get method => _method.value;
  String get cardId => _cardId.value;

  @override
  void onInit() {
    super.onInit();
    _method.value = Get.arguments["method"];
    _cardId.value = Get.arguments["id"];

    dbC.stream("siswa").listen(
      (DatabaseEvent e) {
        DataSnapshot snapshot = e.snapshot;
        for (var ch in snapshot.children) {
          if (!ch.child("card").exists || ch.child("card").value == "") {
            siswa.add(
              {
                "id": ch.child("id").value as String,
                "name": ch.child("name").value as String,
                "email": ch.child("email").value as String,
                "telSiswa": ch.child("telSiswa").value as String,
                "telWaliKelas": ch.child("telWaliKelas").value as String,
                "telWM": ch.child("telWaliMurid").value as String,
              },
            );
          }
        }
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

  List<DropdownMenuItem> buildMenu(List pgws) {
    return pgws
        .where((pgw) => pgw["card"] == null)
        .map(
          (element) => DropdownMenuItem(
            value: element,
            child: Text(element["name"] ?? "-"),
          ),
        )
        .toList();
  }

  void changeSelection(dynamic value) {
    selectedSiswa.value = value;
    nameController.text = value["name"];
    emailController.text = value["email"];
    textFieldControllers[0].text = value["telSiswa"];
    textFieldControllers[1].text = value["telWaliKelas"];
    textFieldControllers[2].text = value["telWM"];
  }

  String? validateName(String? nameValue) {
    if (nameValue!.isEmpty) return "Nama wajib di-isi!";
    return null;
  }

  String? validateEmail(String? emailValue) {
    if (emailValue!.isEmpty) return "Email wajib di-isi!";
    if (!EmailValidator.validate(emailValue)) return "Email tidak valid!";
    if (EmailValidator.validate(emailValue) && !emailValue.endsWith("@gmail.com")) {
      return "Email harus beralamat gmail.com!";
    }
    return null;
  }

  Future<void> validatePhone() async {
    for (var i = 0; i < textFieldControllers.length; i++) {
      String number = textFieldControllers[i].text;
      if (number.isEmpty) {
        validationErrors[i] = "${textFieldName[i]} wajib di-isi!";
      } else if (number.isNotEmpty && !numberRegex.hasMatch(number)) {
        validationErrors[i] = "${textFieldName[i]} tidak valid";
      } else if (number.isNotEmpty && number.length < 10) {
        validationErrors[i] = "${textFieldName[i]} minimal berisi 10 karakter!";
      } else if (number.length > 13) {
        validationErrors[i] = "${textFieldName[i]} maksimal berisi 13 karakter!";
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
    if (method == "new") {
      await validatePhone();
    }
    if (formField.currentState!.validate()) {
      if (method == "new") {
        String id = const Uuid().v4().replaceAll(RegExp(r'-'), "");
        try {
          await dbC.updates(
            "siswa/$id",
            {
              "id": id,
              "card": cardId,
              "name": nameController.text,
              "email": emailController.text,
              "telSiswa": textFieldControllers[0].text,
              "telWaliKelas": textFieldControllers[1].text,
              "telWaliMurid": textFieldControllers[2].text,
            },
          );
          nameController.clear();
          emailController.clear();
          for (var i = 0; i < textFieldControllers.length; i++) {
            textFieldControllers[i].clear();
          }
          Get.showSnackbar(
            GetSnackBar(
              backgroundColor: const Color.fromRGBO(0, 150, 0, .5),
              duration: const Duration(milliseconds: 1500),
              snackPosition: SnackPosition.BOTTOM,
              snackStyle: SnackStyle.FLOATING,
              messageText: Text(
                "Berhasil menambahkan siswa!",
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
          await dbC.remove("cards/$cardId");
          Get.offAllNamed(Routes.HOME);
        } catch (e) {
          Get.showSnackbar(
            GetSnackBar(
              backgroundColor: const Color.fromRGBO(255, 0, 0, .8),
              duration: const Duration(milliseconds: 1500),
              snackPosition: SnackPosition.BOTTOM,
              snackStyle: SnackStyle.FLOATING,
              messageText: Text(
                "Gagal menambahkan siswa!",
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
      } else {
        try {
          // ignore: invalid_use_of_protected_member
          if (selectedSiswa.value["id"] == null) {
            Get.showSnackbar(
              GetSnackBar(
                backgroundColor: const Color.fromRGBO(255, 0, 0, .8),
                duration: const Duration(milliseconds: 1500),
                snackPosition: SnackPosition.BOTTOM,
                snackStyle: SnackStyle.FLOATING,
                messageText: Text(
                  "Siswa belum dipilih!",
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
          } else {
            await dbC.updates(
              // ignore: invalid_use_of_protected_member
              "siswa/${selectedSiswa.value["id"]}",
              {
                "card": cardId,
              },
            );
            nameController.clear();
            emailController.clear();
            for (var i = 0; i < textFieldControllers.length; i++) {
              textFieldControllers[i].clear();
            }
            Get.showSnackbar(
              GetSnackBar(
                backgroundColor: const Color.fromRGBO(0, 150, 0, .5),
                duration: const Duration(milliseconds: 1500),
                snackPosition: SnackPosition.BOTTOM,
                snackStyle: SnackStyle.FLOATING,
                messageText: Text(
                  "Berhasil mengubah siswa!",
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
            await dbC.remove("cards/$cardId");
            Get.offAllNamed(Routes.HOME);
          }
        } catch (e) {
          Get.showSnackbar(
            GetSnackBar(
              backgroundColor: const Color.fromRGBO(255, 0, 0, .8),
              duration: const Duration(milliseconds: 1500),
              snackPosition: SnackPosition.BOTTOM,
              snackStyle: SnackStyle.FLOATING,
              messageText: Text(
                "Gagal mengubah siswa!",
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
    }
    isLoading.value = false;
  }
}
