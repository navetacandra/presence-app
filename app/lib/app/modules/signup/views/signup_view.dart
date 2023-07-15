import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/signup_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence/app/data/colors.dart';

class SignupView extends GetView<SignupController> {
  SignupView({Key? key}) : super(key: key);
  final selfC = Get.find<SignupController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 30,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Get.width * .05,
              vertical: Get.height * .15 - 40,
            ),
            child: Form(
              key: selfC.formField,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ClipRRect(
                    child: Image.asset(
                      "assets/avatar.jpg",
                      width: Get.width * .5,
                      height: Get.width * .5,
                    ),
                  ),
                  const SizedBox(height: 50),
                  TextFormField(
                    controller: selfC.nameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "Nama",
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.person),
                      errorStyle: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 15,
                      ),
                    ),
                    validator: (value) => selfC.validateName(value),
                  ),
                  const SizedBox(height: 20),
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
                          onTap: () => selfC.showPass.value = !selfC.showPass.value,
                          child: Icon(
                            selfC.showPass.value ? Icons.visibility_off : Icons.visibility,
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
                  const SizedBox(height: 20),
                  Obx(
                    () => TextFormField(
                      controller: selfC.passConfirmationController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: !selfC.showPassConfirmation.value,
                      decoration: InputDecoration(
                        labelText: "Konfirmasi Password",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: InkWell(
                          onTap: () => selfC.showPassConfirmation.value = !selfC.showPassConfirmation.value,
                          child: Icon(
                            selfC.showPassConfirmation.value ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                        errorStyle: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 15,
                        ),
                      ),
                      validator: (value) => selfC.validatePasswordConfirmation(value),
                    ),
                  ),
                  const SizedBox(height: 60),
                  InkWell(
                    onTap: () => selfC.isLoading.isTrue ? null : selfC.validateForm(),
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
                                  "Sign Up",
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
