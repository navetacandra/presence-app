import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence/app/controllers/db_controller.dart';
import 'package:presence/app/data/colors.dart';
import '../controllers/daftar_pegawai_controller.dart';

class DaftarPegawaiView extends GetView<DaftarPegawaiController> {
  DaftarPegawaiView({Key? key}) : super(key: key);
  final selfC = Get.find<DaftarPegawaiController>();
  final dbC = Get.find<DbController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pegawai'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: mPrimaryGradientColor),
        ),
      ),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: Get.width,
          padding: EdgeInsets.symmetric(
            horizontal: Get.width * .025,
            vertical: 20,
          ),
          child: SingleChildScrollView(
            child: StreamBuilder<DatabaseEvent>(
              stream: dbC.stream("pegawai"),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  final snap = snapshot.data!.snapshot;

                  if (snap.children.isEmpty) {
                    return Container(
                      margin: EdgeInsets.only(top: Get.height * .1),
                      child: Text(
                        "Hasil Tidak Ditemukan",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.fade,
                      ),
                    );
                  }

                  for (var ch in snap.children) {
                    selfC.pegawai.add(
                      {
                        "id": ch.child("id").value as String,
                        "name": ch.child("name").value as String,
                        "email": ch.child("email").value as String,
                        "tel": ch.child("telPegawai").value as String,
                      },
                    );
                  }
                  return Obx(
                    () => Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: selfC.buildWidgetList(selfC.query.value),
                    ),
                  );
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(
                      color: Colors.black87,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
