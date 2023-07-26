import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence/app/data/colors.dart';
import '../controllers/edit_siswa_controller.dart';

class EditSiswaView extends GetView<EditSiswaController> {
  EditSiswaView({Key? key}) : super(key: key);
  final selfC = Get.find<EditSiswaController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Siswa'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Get.width * .05,
              vertical: Get.height * .08,
            ),
            child: Form(
              key: selfC.formField,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Edit Siswa",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    validator: (nameValue) => selfC.siswaData["name"] == nameValue
                        ? null
                        : selfC.validateName(nameValue),
                    controller: selfC.nameController,
                    decoration: InputDecoration(
                      labelText: "Nama",
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.person),
                      errorStyle: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    validator: (emailValue) => selfC.siswaData["email"] == emailValue
                        ? null
                        : selfC.validateEmail(emailValue),
                    controller: selfC.emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email),
                      errorStyle: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => TextFormField(
                      keyboardType: TextInputType.phone,
                      controller: selfC.textFieldControllers[0],
                      validator: (numberValue) => selfC.siswaData["telSiswa"] == numberValue
                          ? null
                          : selfC.validationErrors[0].isNotEmpty
                              ? selfC.validationErrors[0]
                              : null,
                      decoration: InputDecoration(
                        labelText: "WhatsApp Siswa",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.phone),
                        errorStyle: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 15,
                        ),
                        errorText: selfC.siswaData["telSiswa"] == selfC.textFieldControllers[0].text
                            ? null
                            : selfC.validationErrors[0].isNotEmpty
                                ? selfC.validationErrors[0]
                                : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => TextFormField(
                      keyboardType: TextInputType.phone,
                      controller: selfC.textFieldControllers[1],
                      validator: (numberValue) => selfC.siswaData["telWaliKelas"] == numberValue
                          ? null
                          : selfC.validationErrors[1].isNotEmpty
                              ? selfC.validationErrors[1]
                              : null,
                      decoration: InputDecoration(
                        labelText: "WhatsApp Wali Kelas",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.phone),
                        errorStyle: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 15,
                        ),
                        errorText: selfC.siswaData["telWaliKelas"] == selfC.textFieldControllers[1].text
                            ? null
                            : selfC.validationErrors[1].isNotEmpty
                                ? selfC.validationErrors[1]
                                : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => TextFormField(
                      keyboardType: TextInputType.phone,
                      controller: selfC.textFieldControllers[2],
                      validator: (numberValue) => selfC.siswaData["telWaliMurid"] == numberValue
                          ? null
                          : selfC.validationErrors[2].isNotEmpty
                              ? selfC.validationErrors[2]
                              : null,
                      decoration: InputDecoration(
                        labelText: "WhatsApp Wali Murid",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.phone),
                        errorStyle: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 15,
                        ),
                        errorText: selfC.siswaData["telWaliMurid"] == selfC.textFieldControllers[2].text
                            ? null
                            : selfC.validationErrors[2].isNotEmpty
                                ? selfC.validationErrors[2]
                                : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
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
                                  "Update",
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
