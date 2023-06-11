import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence/app/data/colors.dart';
import '../controllers/tambah_pegawai_controller.dart';

class TambahPegawaiView extends GetView<TambahPegawaiController> {
  TambahPegawaiView({Key? key}) : super(key: key);
  final selfC = Get.find<TambahPegawaiController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pegawai'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: mPrimaryGradientColor),
        ),
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
                    "Tambah Pegawai",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 26, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: selfC.nameController,
                    keyboardType: TextInputType.text,
                    validator: (nameValue) => selfC.validateName(nameValue),
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
                    controller: selfC.emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (emailValue) => selfC.validateEmail(emailValue),
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
                      validator: (numberValue) =>
                          selfC.validationErrors[0].isNotEmpty
                              ? selfC.validationErrors[0]
                              : null,
                      decoration: InputDecoration(
                        labelText: "Telpon Pegawai",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.phone),
                        errorStyle: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 15,
                        ),
                        errorText: selfC.validationErrors[0].isNotEmpty
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
                      validator: (numberValue) =>
                          selfC.validationErrors[1].isNotEmpty
                              ? selfC.validationErrors[1]
                              : null,
                      decoration: InputDecoration(
                        labelText: "Telpon Atasan",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.phone),
                        errorStyle: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 15,
                        ),
                        errorText: selfC.validationErrors[1].isNotEmpty
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
                      validator: (numberValue) =>
                          selfC.validationErrors[2].isNotEmpty
                              ? selfC.validationErrors[2]
                              : null,
                      decoration: InputDecoration(
                        labelText: "Telpon Penanggung Jawab",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.phone),
                        errorStyle: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 15,
                        ),
                        errorText: selfC.validationErrors[2].isNotEmpty
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
                                  "Tambah",
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
