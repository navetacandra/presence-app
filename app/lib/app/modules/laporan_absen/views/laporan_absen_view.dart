import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/colors.dart';
import '../controllers/laporan_absen_controller.dart';

class LaporanAbsenView extends GetView<LaporanAbsenController> {
  LaporanAbsenView({Key? key}) : super(key: key);
  final selfC = Get.find<LaporanAbsenController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Laporan'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 24,
          ),
          child: Obx(
            () {
              List<Widget> items = [];
              List<List<Map>> tgl1 = [];
              for (var i = 0; i < selfC.tgl.length; i += 6) {
                tgl1.add(
                  selfC.tgl.sublist(
                    i,
                    i + 6 > selfC.tgl.length ? selfC.tgl.length : i + 6,
                  ),
                );
              }

              for (var i = 0; i < tgl1.length; i++) {
                List<Widget> rows = [];
                for (var j = 0; j < tgl1[i].length; j++) {
                  rows.add(
                    InkWell(
                      // onTap: () => selfC.tgl[i][j]['active'] = !(tgl1[i][j]['active'] as bool),
                      onTap: () {
                        tgl1[i][j]['active'] = !(tgl1[i][j]['active'] as bool);
                        selfC.tgl[selfC.tgl.indexOf(tgl1[i][j])] = tgl1[i][j];
                      },
                      child: Obx(
                        () => Container(
                          width: Get.width / 7,
                          height: Get.width / 7,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: (selfC.tgl[selfC.tgl.indexOf(tgl1[i][j])]
                                    ['active'] as bool)
                                ? Colors.green
                                : Colors.red.shade700,
                          ),
                          child: Center(
                            child: Text(
                              tgl1[i][j]['key'],
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: Get.width * .075,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                items.add(
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: rows,
                    ),
                  ),
                );
              }
              return Column(
                children: <Widget>[
                  Obx(
                    () => DropdownButton<String>(
                      isExpanded: true,
                      items: selfC.months.map<DropdownMenuItem<String>>(
                        (String val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(
                              val.toUpperCase(),
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                      value: selfC.selectedMonth.value,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 30,
                        weight: 4,
                        color: Colors.black,
                      ),
                      onChanged: (value) {
                        selfC.clearTgl();
                        selfC.selectedMonth.value = value ?? "";
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ...items,
                  const SizedBox(
                    height: 30,
                  ),
                  InkWell(
                    onTap: () =>
                        selfC.isLoading.isTrue ? null : selfC.downloadReport(),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: mPrimaryGradientColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Obx(
                        () => selfC.isLoading.isFalse
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Download",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Icon(
                                    Icons.download_rounded,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                ],
                              )
                            : const Center(
                                child: Padding(
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
              );
            },
          ),
        ),
      ),
    );
  }
}
