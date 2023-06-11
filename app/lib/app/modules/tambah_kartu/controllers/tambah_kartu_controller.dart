// ignore_for_file: unnecessary_overrides
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence/app/controllers/db_controller.dart';
import 'package:presence/app/routes/app_pages.dart';

class TambahKartuController extends GetxController {
  final dbC = Get.find<DbController>();
  RxList cardList = [].obs;
  RxBool canUseSelect = false.obs;

  @override
  void onInit() {
    super.onInit();

    dbC.stream("cards").listen((DatabaseEvent e) {
      DataSnapshot snapshot = e.snapshot;
      cardList.value = [];
      for (var ch in snapshot.children) {
        cardList.add(ch.key);
      }
    });

    dbC.stream("pegawai").listen(
      (DatabaseEvent e) {
        DataSnapshot snapshot = e.snapshot;
        int noCard = 0;
        for (var ch in snapshot.children) {
          if (!ch.child("card").exists || ch.child("card").value == "") {
            noCard = noCard + 1;
          }
        }
        if (noCard > 0) {
          canUseSelect.value = true;
        } else {
          canUseSelect.value = false;
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

  List<Widget> buildWidgetList({
    required BuildContext context,
  }) {
    final widgetList = cardList.isNotEmpty
        ? <Widget>[]
        : [
            Container(
              margin: EdgeInsets.only(top: Get.height * .1),
              child: Text(
                "Tidak Ada Kartu Baru",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.fade,
              ),
            ),
          ];

    for (var elem in cardList) {
      widgetList.add(cardDetailsCard(id: elem, context: context));
    }

    return widgetList;
  }

  GestureDetector cardDetailsCard({
    required String id,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          elevation: 3,
          content: Text(
            "Pilih cara menambahkan kartu dengan id $id ke data pegawai",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                Get.toNamed(
                  Routes.TAMBAH_KARTU_PROSES,
                  arguments: {"method": "new", "id": id},
                );
              },
              child: Text(
                "Tambah Pegawai",
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color.fromARGB(255, 83, 83, 238)),
              ),
            ),
            Obx(
              () => TextButton(
                onPressed: canUseSelect.isTrue
                    ? () {
                        Get.back();
                        Get.toNamed(
                          Routes.TAMBAH_KARTU_PROSES,
                          arguments: {"method": "select", "id": id},
                        );
                      }
                    : null,
                child: Text(
                  "Pilih Pegawai",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: canUseSelect.isTrue
                        ? const Color.fromARGB(255, 83, 83, 238)
                        : const Color.fromARGB(255, 110, 110, 131),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      child: Container(
        height: 80,
        width: Get.width,
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 250, 250, 250),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color.fromARGB(80, 0, 0, 0),
              blurRadius: 4,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              id,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
