// ignore_for_file: unnecessary_overrides
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class DaftarPegawaiController extends GetxController {
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

  GestureDetector pegawaiCard({
    required String id,
    required String name,
    required String email,
    required String tel,
  }) {
    return GestureDetector(
      onTap: () => print(id),
      child: Container(
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
            Container(
              width: Get.width / 5,
              height: 10,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
