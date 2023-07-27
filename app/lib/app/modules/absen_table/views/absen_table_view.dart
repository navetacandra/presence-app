import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/absen_table_controller.dart';

class AbsenTableView extends GetView<AbsenTableController> {
  AbsenTableView({Key? key}) : super(key: key);
  final selfC = Get.find<AbsenTableController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Absen'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Obx(
            () => DataTable(
              columns: <DataColumn>[
                DataColumn(
                  label: Text(
                    "Tanggal",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Status",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Masuk",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Pulang",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              headingRowColor: MaterialStateProperty.all(const Color.fromRGBO(255, 255, 255, 1)),
              rows: <DataRow>[
                ...selfC.dataAbsenList
                    .map(
                      (el) => DataRow(
                        cells: <DataCell>[
                          DataCell(
                            Text(
                              el["tanggal"] ?? "-",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          DataCell(
                            Text(
                              el["status"] ?? "-",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          DataCell(
                            Text(
                              el["masuk"] ?? "-",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          DataCell(
                            Text(
                              el["pulang"] ?? "-",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                        color: MaterialStateProperty.all(
                          int.parse(el["tanggal"] ?? "0") % 2 == 0 ? Color.fromRGBO(242, 242, 242, 1) : Color.fromRGBO(255, 255, 255, 1),
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
