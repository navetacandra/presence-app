// ignore_for_file: unnecessary_overrides

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence/app/controllers/auth_controller.dart';
import 'package:presence/app/controllers/db_controller.dart';

import '../../../data/colors.dart';

class ProfileController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final authController = Get.find<AuthController>();
  final dbController = Get.find<DbController>();
  RxString nameText = "".obs;
  TextEditingController nameContorller = TextEditingController();
  TextEditingController emailContorller = TextEditingController();
  RxMap<String, Object> profileDetail = {
    "uid": "",
    "name": "",
    "email": "",
    "password": "",
    "photoURL": "",
    "role": 1,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    authController.streamCredential.listen(
      (User? user) {
        if (user != null) {
          dbController.stream("users/${user.uid}").listen(
            (DatabaseEvent ev) {
              DataSnapshot snap = ev.snapshot;
              if (snap.exists) {
                // ignore: unnecessary_cast
                profileDetail.value = {
                  "uid": snap.child("uid").value as String,
                  "name": snap.child("name").value as String,
                  "email": snap.child("email").value as String,
                  "password": snap.child("password").value as String,
                  "photoURL": snap.child("photoURL").value as String,
                  "role": snap.child("role").value as int,
                } as Map<String, Object>;
                nameContorller.text = profileDetail["name"] as String;
                emailContorller.text = profileDetail["email"] as String;
                nameText.value = profileDetail["name"] as String;
              }
            },
          );
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

  void changePasswordForm(BuildContext context) {
    RxString oldPass = "".obs;
    RxString newPass = "".obs;
    RxBool showOldPass = false.obs;
    RxBool showNewPass = false.obs;
    RxBool isLoading = false.obs;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        elevation: 3,
        content: SizedBox(
          height: 350,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Ganti Password",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                    height: 50,
                    child: Obx(
                      () => TextFormField(
                        obscureText: showOldPass.isFalse,
                        style: GoogleFonts.poppins(),
                        onChanged: (value) => oldPass.value = value,
                        decoration: InputDecoration(
                          labelText: "Password Lama",
                          border: const OutlineInputBorder(),
                          suffixIcon: InkWell(
                            onTap: () =>
                                showOldPass.value = showOldPass.isFalse,
                            child: Icon(
                              showOldPass.isTrue
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    height: 50,
                    child: Obx(
                      () => TextFormField(
                        obscureText: showNewPass.isFalse,
                        style: GoogleFonts.poppins(),
                        onChanged: (value) => newPass.value = value,
                        decoration: InputDecoration(
                          labelText: "Password Baru",
                          border: const OutlineInputBorder(),
                          suffixIcon: InkWell(
                            onTap: () =>
                                showNewPass.value = showNewPass.isFalse,
                            child: Icon(
                              showNewPass.isTrue
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Obx(
                    () => InkWell(
                      onTap: () => ((oldPass.value.length >= 6 &&
                                  newPass.value.length >= 6) &&
                              (oldPass.value ==
                                  authController.nestATOB(
                                      5, profileDetail["password"] as String)))
                          ? changePassword(
                              isLoading,
                              oldPass.value,
                              newPass.value,
                            )
                          : null,
                      child: Container(
                        height: 50,
                        decoration: ((oldPass.value.length >= 6 &&
                                    newPass.value.length >= 6) &&
                                (oldPass.value ==
                                    authController.nestATOB(5,
                                        profileDetail["password"] as String)))
                            ? BoxDecoration(
                                gradient: mPrimaryGradientColor,
                                borderRadius: BorderRadius.circular(10),
                              )
                            : BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: Colors.blue, width: 2),
                              ),
                        child: Center(
                          child: isLoading.isFalse
                              ? Obx(
                                  () => Text(
                                    "Ganti Password",
                                    style: GoogleFonts.poppins(
                                      color: ((oldPass.value.length >= 6 &&
                                                  newPass.value.length >= 6) &&
                                              (oldPass.value ==
                                                  authController.nestATOB(
                                                      5,
                                                      profileDetail["password"]
                                                          as String)))
                                          ? Colors.white
                                          : Colors.blue,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : const Padding(
                                  padding: EdgeInsets.all(5),
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void changePassword(
    RxBool isLoad,
    String oldPassword,
    String newPassword,
  ) async {
    isLoad.value = true;
    try {
      AuthCredential credential = EmailAuthProvider.credential(
          email: profileDetail["email"] as String, password: oldPassword);
      await authController.mAuth.currentUser!
          .reauthenticateWithCredential(credential);
      await authController.mAuth.currentUser!.updatePassword(newPassword);
      await dbController.updates(
        "users/${authController.mAuth.currentUser!.uid}",
        {
          "password": authController.nestBTOA(5, newPassword),
        },
      );
      Get.back(closeOverlays: true);
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print(e);
    }
    isLoad.value = false;
  }

  void updateProfile() async {
    if ((profileDetail["uid"] as String).isNotEmpty) {
      final pgwData = await dbController.mDb
          .ref("siswa")
          .orderByChild("email")
          .equalTo(profileDetail["email"])
          .get();
      await dbController
          .updates("users/${profileDetail["uid"]}", {"name": nameText.value});
      if (pgwData.exists) {
        final pgwId = pgwData.children.first.child("id").value as String;
        await dbController.updates("siswa/$pgwId", {"name": nameText.value});
      }
    }
  }
}
