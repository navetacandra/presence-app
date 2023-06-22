import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence/app/data/colors.dart';

import '../controllers/signin_controller.dart';

class SigninView extends GetView<SigninController> {
  SigninView({Key? key}) : super(key: key);
  final selfC = Get.find<SigninController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Get.width * .05,
              vertical: Get.height * .15,
            ),
            child: Form(
              key: selfC.formField,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ClipRRect(
                    child: Image.asset(
                      "assets/app-logo.png",
                      width: Get.width * .5,
                      height: Get.width * .5,
                    ),
                  ),
                  const SizedBox(height: 50),
                  TextFormField(
                    controller: selfC.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email),
                      errorStyle: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 15,
                      ),
                    ),
                    validator: (value) => selfC.validateEmail(value),
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => TextFormField(
                      controller: selfC.passController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: !selfC.showPass.value,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: InkWell(
                          onTap: () =>
                              selfC.showPass.value = !selfC.showPass.value,
                          child: Icon(
                            selfC.showPass.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                        errorStyle: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 15,
                        ),
                      ),
                      validator: (value) => selfC.validatePassword(value),
                    ),
                  ),
                  const SizedBox(height: 60),
                  InkWell(
                    onTap: () =>
                        selfC.isLoading.isTrue ? null : selfC.validateForm(),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: mPrimaryGradientColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Obx(
                          () => selfC.isLoading.isFalse
                              ? Text(
                                  "Sign In",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
