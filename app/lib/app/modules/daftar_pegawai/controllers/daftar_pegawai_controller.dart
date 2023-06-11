// ignore_for_file: unnecessary_overrides
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence/app/controllers/db_controller.dart';
import 'package:presence/app/routes/app_pages.dart';

class DaftarPegawaiController extends GetxController {
  final dbC = Get.find<DbController>();
  RxString query = "".obs;
  RxList pegawai = [].obs;

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  List<Widget> buildWidgetList(String searchQuery) {
    List<Widget> widgetsList = pegawai.isNotEmpty ? [searchForm()] : [];

    for (var elem in pegawai) {
      if (elem["name"].contains(searchQuery) ||
          elem["email"].contains(searchQuery) ||
          elem["tel"].contains(searchQuery)) {
        widgetsList.add(
          pegawaiCard(
            id: elem["id"],
            name: elem["name"],
            email: elem["email"],
            tel: elem["tel"],
          ),
        );
      }
    }

    if (pegawai.isNotEmpty && widgetsList.length == 1) {
      widgetsList.add(
        Container(
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
        ),
      );
    }

    return widgetsList;
  }

  Container searchForm() {
    return Container(
      width: Get.width,
      height: 50,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(240, 255, 255, 255),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color.fromARGB(80, 0, 0, 0),
            blurRadius: 2,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: TextFormField(
        keyboardType: TextInputType.text,
        onChanged: (value) => query.value = value,
        decoration: InputDecoration(
          label: Text(
            "Search",
            style: GoogleFonts.poppins(color: Colors.black87),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.black),
        ),
      ),
    );
  }

  Container pegawaiCard({
    required String id,
    required String name,
    required String email,
    required String tel,
  }) {
    void confirDeletePegawai() {
      Get.dialog(
        AlertDialog(
          elevation: 3,
          content: Text(
            "Apakah anda yakin ingin menghapus data pegawai dengan nama $name",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                "Batal",
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color.fromARGB(255, 238, 83, 83)),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await dbC.remove("pegawai/$id").whenComplete(() {
                    Get.back();
                  });
                  Get.showSnackbar(
                    GetSnackBar(
                      duration: const Duration(seconds: 3),
                      titleText: Text(
                        "Berhasil Menghapus Pegawai",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 15, 15, 15),
                          fontSize: 12,
                        ),
                      ),
                      messageText: Text(
                        "Data pegawai $name telah dihapus",
                        style: GoogleFonts.poppins(
                          color: const Color.fromARGB(255, 15, 15, 15),
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: const Color.fromARGB(149, 28, 250, 146),
                    ),
                  );
                } catch (e) {
                  Get.back();
                  Get.showSnackbar(
                    GetSnackBar(
                      duration: const Duration(seconds: 3),
                      titleText: Text(
                        "Gagal Menghapus Pegawai",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 15, 15, 15),
                          fontSize: 12,
                        ),
                      ),
                      messageText: Text(
                        "Terjadi kesalahan saat menghapus pegawai",
                        style: GoogleFonts.poppins(
                          color: const Color.fromARGB(255, 15, 15, 15),
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: const Color.fromARGB(150, 255, 50, 50),
                    ),
                  );
                }
              },
              child: Text(
                "Yakin",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromARGB(255, 83, 83, 238),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: Get.width,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 250, 250, 250),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color.fromARGB(80, 0, 0, 0),
            blurRadius: 2,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: Get.width / 1.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  email,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  tel,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(
            width: Get.width / 4.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                InkWell(
                  onTap: () => Get.toNamed(
                    Routes.EDIT_PEGAWAI,
                    arguments: {"id": id},
                  ),
                  child: Image.asset(
                    "assets/pencil.png",
                    width: Get.width / 4.5 / 3,
                    height: Get.width / 4.5 / 3,
                  ),
                ),
                InkWell(
                  onTap: () => confirDeletePegawai(),
                  child: Image.asset(
                    "assets/trash.png",
                    width: Get.width / 4.5 / 3,
                    height: Get.width / 4.5 / 3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
