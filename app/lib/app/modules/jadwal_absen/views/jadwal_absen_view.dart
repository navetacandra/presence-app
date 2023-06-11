import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/jadwal_absen_controller.dart';

class JadwalAbsenView extends GetView<JadwalAbsenController> {
  JadwalAbsenView({Key? key}) : super(key: key);
  final selfC = Get.find<JadwalAbsenController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Absen'),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(Get.width * .02, 0, Get.width * .02, 0),
        child: Obx(
          () => ListView(
            children: selfC.activeList.isNotEmpty &&
                    (selfC.absenDetail['jam_hadir_start'] ?? "").contains(':')
                ? <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // --- Jam Hadir --- //
                          Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            child: Builder(
                              builder: (context) {
                                RxBool isQueryLoad = false.obs;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Obx(
                                      () => Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            "Jam Hadir",
                                            style: GoogleFonts.poppins(
                                              color: Colors.black,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          isQueryLoad.isFalse
                                              ? Container()
                                              : Container(
                                                  width: 22,
                                                  height: 22,
                                                  margin: const EdgeInsets.only(
                                                    left: 8,
                                                  ),
                                                  child:
                                                      const CircularProgressIndicator(
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            isQueryLoad.value = true;
                                            var stp = await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay(
                                                hour: int.parse(
                                                  selfC.absenDetail[
                                                          'jam_hadir_start']!
                                                      .split(':')[0],
                                                ),
                                                minute: int.parse(
                                                  selfC.absenDetail[
                                                          'jam_hadir_start']!
                                                      .split(':')[1],
                                                ),
                                              ),
                                              builder: (context, child) {
                                                return MediaQuery(
                                                  data: MediaQuery.of(context)
                                                      .copyWith(
                                                    alwaysUse24HourFormat: true,
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );

                                            // ignore: unnecessary_null_comparison
                                            if (stp != null) {
                                              var hour = stp.hour
                                                          .toString()
                                                          .length <
                                                      2
                                                  ? "0${stp.hour.toString()}"
                                                  : stp.hour.toString();
                                              var minute = stp.minute
                                                          .toString()
                                                          .length <
                                                      2
                                                  ? "0${stp.minute.toString()}"
                                                  : stp.minute.toString();

                                              if (selfC.absenDetail[
                                                      'jam_hadir_start'] !=
                                                  "$hour:$minute") {
                                                await selfC.dbC.updates(
                                                  'absen_detail',
                                                  {
                                                    'jam_hadir_start':
                                                        "$hour:$minute",
                                                  },
                                                );
                                              }
                                            }
                                            isQueryLoad.value = false;
                                          },
                                          child: Container(
                                            width: 110,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.blue.shade300,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                "${selfC.absenDetail['jam_hadir_start']?.split(':')[0] ?? '-'}  :  ${selfC.absenDetail['jam_hadir_start']?.split(':')[1] ?? '-'}",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "-",
                                          style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontSize: 24,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            isQueryLoad.value = true;
                                            var stp = await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay(
                                                hour: int.parse(
                                                  selfC.absenDetail[
                                                          'jam_hadir_end']!
                                                      .split(':')[0],
                                                ),
                                                minute: int.parse(
                                                  selfC.absenDetail[
                                                          'jam_hadir_end']!
                                                      .split(':')[1],
                                                ),
                                              ),
                                              builder: (context, child) {
                                                return MediaQuery(
                                                  data: MediaQuery.of(context)
                                                      .copyWith(
                                                    alwaysUse24HourFormat: true,
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );

                                            // ignore: unnecessary_null_comparison
                                            if (stp != null) {
                                              var hour = stp.hour
                                                          .toString()
                                                          .length <
                                                      2
                                                  ? "0${stp.hour.toString()}"
                                                  : stp.hour.toString();
                                              var minute = stp.minute
                                                          .toString()
                                                          .length <
                                                      2
                                                  ? "0${stp.minute.toString()}"
                                                  : stp.minute.toString();

                                              if (selfC.absenDetail[
                                                      'jam_hadir_end'] !=
                                                  "$hour:$minute") {
                                                await selfC.dbC.updates(
                                                  'absen_detail',
                                                  {
                                                    'jam_hadir_end':
                                                        "$hour:$minute",
                                                  },
                                                );
                                              }
                                            }
                                            isQueryLoad.value = false;
                                          },
                                          child: Container(
                                            width: 110,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.blue.shade300,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                "${selfC.absenDetail['jam_hadir_end']?.split(':')[0] ?? '-'}  :  ${selfC.absenDetail['jam_hadir_end']?.split(':')[1] ?? '-'}",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),

                          // --- Jam Pulang --- //
                          Container(
                            margin: const EdgeInsets.only(bottom: 5, top: 5),
                            child: Builder(
                              builder: (context) {
                                RxBool isQueryLoad = false.obs;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Obx(
                                      () => Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            "Jam Pulang",
                                            style: GoogleFonts.poppins(
                                              color: Colors.black,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          isQueryLoad.isFalse
                                              ? Container()
                                              : Container(
                                                  width: 22,
                                                  height: 22,
                                                  margin: const EdgeInsets.only(
                                                    left: 8,
                                                  ),
                                                  child:
                                                      const CircularProgressIndicator(
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            isQueryLoad.value = true;
                                            var stp = await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay(
                                                hour: int.parse(
                                                  selfC.absenDetail[
                                                          'jam_pulang_start']!
                                                      .split(':')[0],
                                                ),
                                                minute: int.parse(
                                                  selfC.absenDetail[
                                                          'jam_pulang_start']!
                                                      .split(':')[1],
                                                ),
                                              ),
                                              builder: (context, child) {
                                                return MediaQuery(
                                                  data: MediaQuery.of(context)
                                                      .copyWith(
                                                    alwaysUse24HourFormat: true,
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );

                                            // ignore: unnecessary_null_comparison
                                            if (stp != null) {
                                              var hour = stp.hour
                                                          .toString()
                                                          .length <
                                                      2
                                                  ? "0${stp.hour.toString()}"
                                                  : stp.hour.toString();
                                              var minute = stp.minute
                                                          .toString()
                                                          .length <
                                                      2
                                                  ? "0${stp.minute.toString()}"
                                                  : stp.minute.toString();

                                              if (selfC.absenDetail[
                                                      'jam_pulang_start'] !=
                                                  "$hour:$minute") {
                                                await selfC.dbC.updates(
                                                  'absen_detail',
                                                  {
                                                    'jam_pulang_start':
                                                        "$hour:$minute",
                                                  },
                                                );
                                              }
                                            }
                                            isQueryLoad.value = false;
                                          },
                                          child: Container(
                                            width: 110,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.blue.shade300,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                "${selfC.absenDetail['jam_pulang_start']?.split(':')[0] ?? '-'}  :  ${selfC.absenDetail['jam_pulang_start']?.split(':')[1] ?? '-'}",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "-",
                                          style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontSize: 24,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            isQueryLoad.value = true;
                                            var stp = await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay(
                                                hour: int.parse(
                                                  selfC.absenDetail[
                                                          'jam_pulang_end']!
                                                      .split(':')[0],
                                                ),
                                                minute: int.parse(
                                                  selfC.absenDetail[
                                                          'jam_pulang_end']!
                                                      .split(':')[1],
                                                ),
                                              ),
                                              builder: (context, child) {
                                                return MediaQuery(
                                                  data: MediaQuery.of(context)
                                                      .copyWith(
                                                    alwaysUse24HourFormat: true,
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );

                                            // ignore: unnecessary_null_comparison
                                            if (stp != null) {
                                              var hour = stp.hour
                                                          .toString()
                                                          .length <
                                                      2
                                                  ? "0${stp.hour.toString()}"
                                                  : stp.hour.toString();
                                              var minute = stp.minute
                                                          .toString()
                                                          .length <
                                                      2
                                                  ? "0${stp.minute.toString()}"
                                                  : stp.minute.toString();

                                              if (selfC.absenDetail[
                                                      'jam_pulang_end'] !=
                                                  "$hour:$minute") {
                                                await selfC.dbC.updates(
                                                  'absen_detail',
                                                  {
                                                    'jam_pulang_end':
                                                        "$hour:$minute",
                                                  },
                                                );
                                              }
                                            }
                                            isQueryLoad.value = false;
                                          },
                                          child: Container(
                                            width: 110,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.blue.shade300,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                "${selfC.absenDetail['jam_pulang_end']?.split(':')[0] ?? '-'}  :  ${selfC.absenDetail['jam_pulang_end']?.split(':')[1] ?? '-'}",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...selfC.buildWidgets(),
                  ]
                : [
                    const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.black87,
                        ),
                      ),
                    )
                  ],
          ),
        ),
      ),
    );
  }
}
