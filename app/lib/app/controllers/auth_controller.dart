// ignore_for_file: unnecessary_overrides
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence/app/controllers/db_controller.dart';
import 'package:presence/app/routes/app_pages.dart';

class AuthController extends GetxController {
  final mAuth = FirebaseAuth.instance;
  final mDb = Get.put<DbController>(DbController());

  Stream<User?> get streamCredential => mAuth.authStateChanges();

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

  Future<UserCredential?> signUp(
    String email,
    String password,
    String? name, {
    Function? callback,
  }) async {
    try {
      UserCredential user = await mAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // ignore: unnecessary_null_comparison
      if (user != null) {
        await mAuth.currentUser?.updateDisplayName(name);
        setUserDefaultData(uid: user.user!.uid, email: email, name: name ?? "", passwrod: password);
        callback!();
        Get.offAllNamed(Routes.HOME);
        return user;
      } else {
        showErrorSnackBar(message: "Pendaftaran Gagal!");
        return null;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        showErrorSnackBar(message: "Email Sudah Terdaftar!");
      }
      if (e.code == "too-many-requests") {
        showErrorSnackBar(message: "Terjadi Kesalahan, Coba Lagi Nanti!");
      }
      return null;
    }
  }

  Future<UserCredential?> signIn(
    String email,
    String password, {
    Function? callback,
  }) async {
    try {
      final user = await mAuth.signInWithEmailAndPassword(email: email, password: password);
      // ignore: unnecessary_null_comparison
      if (user != null) {
        setUserDefaultData(uid: user.user!.uid, email: email, name: mAuth.currentUser?.displayName ?? "", passwrod: password);
        callback!();
        Get.offAllNamed(Routes.HOME);
        return user;
      } else {
        showErrorSnackBar(message: "Login Gagal!");
        return null;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        showErrorSnackBar(message: "Email Belum Terdaftar!");
      }
      if (e.code == "wrong-password") {
        showErrorSnackBar(message: "Password Salah!");
      }
      if (e.code == "too-many-requests") {
        showErrorSnackBar(message: "Terjadi Kesalahan, Coba Lagi Nanti!");
      }
      return null;
    }
  }

  void signOut() async {
    await Get.offAllNamed(Routes.SIGNIN);
    await mAuth.signOut();
  }

  void setUserDefaultData({
    required String uid,
    required String email,
    required String passwrod,
    required String name,
  }) async {
    try {
      DataSnapshot dataQuery = await mDb.gets("users/$uid");
      if (dataQuery.children.isEmpty) {
        mDb.updates(
          "users/$uid",
          {
            "uid": uid,
            "email": email,
            "name": name,
            "role": 3,
            "photoURL": "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
            "password": nestBTOA(5, passwrod),
          },
        );
      }
    } catch (e) {
      showErrorSnackBar(message: "Terjadi Kesalahan Sistem.");
    }
  }

  SnackbarController showErrorSnackBar({required String message}) {
    return Get.showSnackbar(
      GetSnackBar(
        backgroundColor: const Color.fromRGBO(255, 0, 0, .8),
        duration: const Duration(milliseconds: 1500),
        snackPosition: SnackPosition.BOTTOM,
        snackStyle: SnackStyle.FLOATING,
        messageText: Text(
          message,
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

  String nestBTOA(int nest, String inp) {
    String str = inp;
    for (var i = 0; i < nest; i++) {
      str = base64.encode(utf8.encode(str));
    }
    return str;
  }

  String nestATOB(int nest, String inp) {
    String str = inp;
    for (var i = 0; i < nest; i++) {
      str = utf8.decode(base64.decode(str));
    }
    return str;
  }
}
