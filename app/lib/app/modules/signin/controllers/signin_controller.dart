// ignore_for_file: unnecessary_overrides
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:presence/app/controllers/auth_controller.dart';

class SigninController extends GetxController {
  final authC = Get.find<AuthController>();
  final formField = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  RxBool showPass = false.obs;
  RxBool isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
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

  String? validatePassword(String? passValue) {
    if (passValue!.isEmpty) return "Password wajib di-isi!";
    if (passValue.isNotEmpty && passValue.length < 6) {
      return "Password minimal berisi 6 karakter!";
    }
    return null;
  }

  void validateForm() async {
    isLoading.value = true;
    if (formField.currentState!.validate()) {
      await authC.signIn(
        emailController.text,
        passController.text,
        callback: () {
          emailController.clear();
          passController.clear();
        },
      );
    }
    isLoading.value = false;
  }
}
