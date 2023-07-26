import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence/app/data/colors.dart';
import '../controllers/tambah_kartu_proses_controller.dart';

class TambahKartuProsesView extends GetView<TambahKartuProsesController> {
  TambahKartuProsesView({Key? key}) : super(key: key);
  final selfC =
      Get.put<TambahKartuProsesController>(TambahKartuProsesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kartu'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: tambahKartuForm(),
        ),
      ),
    );
  }

  Padding tambahKartuForm() {
    return Padding(
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
              "${selfC.method == "new" ? "Tambah" : "Pilih"} Siswa",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 30),
            selfC.method == "select"
                ? Obx(
                    () {
                      return Container(
                        width: Get.width - (Get.width * .05),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black,
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                        child: DropdownButton(
                          items: selfC.buildMenu(selfC.siswa),
                          value: selfC.selectedSiswa["id"] != null
                              // ignore: invalid_use_of_protected_member
                              ? selfC.selectedSiswa.value
                              : null,
                          hint: Text(
                            "Pilih data siswa disini",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                            ),
                          ),
                          onChanged: (val) => selfC.changeSelection(val),
                          isExpanded: true,
                        ),
                      );
                    },
                  )
                : Container(),
            selfC.method == "select" ? const SizedBox(height: 20) : Container(),
            TextFormField(
              keyboardType: TextInputType.text,
              validator: (nameValue) => selfC.method == "select"
                  ? null
                  : selfC.validateName(nameValue),
              readOnly: selfC.method == "select",
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
              validator: (emailValue) => selfC.method == "select"
                  ? null
                  : selfC.validateEmail(emailValue),
              readOnly: selfC.method == "select",
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
                validator: (numberValue) => selfC.method == "select"
                    ? null
                    : selfC.validationErrors[0].isNotEmpty
                        ? selfC.validationErrors[0]
                        : null,
                readOnly: selfC.method == "select",
                decoration: InputDecoration(
                  labelText: "WhatsApp Siswa",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone),
                  errorStyle: GoogleFonts.poppins(
                    color: Colors.red,
                    fontSize: 15,
                  ),
                  errorText: selfC.method == "select"
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
                validator: (numberValue) => selfC.method == "select"
                    ? null
                    : selfC.validationErrors[1].isNotEmpty
                        ? selfC.validationErrors[1]
                        : null,
                readOnly: selfC.method == "select",
                decoration: InputDecoration(
                  labelText: "WhatsApp Wali Kelas",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone),
                  errorStyle: GoogleFonts.poppins(
                    color: Colors.red,
                    fontSize: 15,
                  ),
                  errorText: selfC.method == "select"
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
                validator: (numberValue) => selfC.method == "select"
                    ? null
                    : selfC.validationErrors[2].isNotEmpty
                        ? selfC.validationErrors[2]
                        : null,
                readOnly: selfC.method == "select",
                decoration: InputDecoration(
                  labelText: "WhatsApp Wali Murid",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone),
                  errorStyle: GoogleFonts.poppins(
                    color: Colors.red,
                    fontSize: 15,
                  ),
                  errorText: selfC.method == "select"
                      ? null
                      : selfC.validationErrors[2].isNotEmpty
                          ? selfC.validationErrors[2]
                          : null,
                ),
              ),
            ),
            const SizedBox(height: 40),
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
                            selfC.method == "new" ? "Tambah" : "Update",
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
    );
  }
}
