// ignore_for_file: unnecessary_overrides
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:presence/app/controllers/auth_controller.dart';

class SignupController extends GetxController {
  final authC = Get.find<AuthController>();
  final formField = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final passConfirmationController = TextEditingController();
  RxBool showPass = false.obs;
  RxBool showPassConfirmation = false.obs;
  RxBool isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  String? validateName(String? name) {
    if (name!.isEmpty) return "Nama wajib di-isi!";
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

  String? validatePassword(String? passValue) {
    if (passValue!.isEmpty) return "Password wajib di-isi!";
    if (passValue.isNotEmpty && passValue.length < 6) {
      return "Password minimal berisi 6 karakter!";
    }
    return null;
  }

  String? validatePasswordConfirmation(String? passValue) {
    if (passValue!.isEmpty) return "Password wajib di-isi!";
    if (passValue != passController.text) return "Password tidak sesuai!";
    return null;
  }

  void validateForm() async {
    isLoading.value = true;
    if (formField.currentState!.validate()) {
      await authC.signUp(
        emailController.text,
        passController.text,
        nameController.text,
        callback: () {
          emailController.clear();
          passController.clear();
        },
      );
    }
    isLoading.value = false;
  }
}
