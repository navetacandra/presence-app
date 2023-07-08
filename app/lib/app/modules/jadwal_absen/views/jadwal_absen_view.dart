import 'package:firebase_database/firebase_database.dart';
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
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<DatabaseEvent>(
                stream: selfC.dbC.stream('schedule'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    String jamHadirStart = snapshot.data!.snapshot.child('jam_hadir_start').value as String;
                    String jamHadirEnd = snapshot.data!.snapshot.child('jam_hadir_end').value as String;
                    String jamPulangStart = snapshot.data!.snapshot.child('jam_pulang_start').value as String;
                    String jamPulangEnd = snapshot.data!.snapshot.child('jam_pulang_end').value as String;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20, top: 20),
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
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                                  child: const CircularProgressIndicator(
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            isQueryLoad.value = true;
                                            var stp = await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay(
                                                hour: int.parse(
                                                  jamHadirStart.split(':')[0],
                                                ),
                                                minute: int.parse(
                                                  jamHadirStart.split(':')[1],
                                                ),
                                              ),
                                              builder: (context, child) {
                                                return MediaQuery(
                                                  data: MediaQuery.of(context).copyWith(
                                                    alwaysUse24HourFormat: true,
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );

                                            // ignore: unnecessary_null_comparison
                                            // ----
                                            // if show time picker value is not null
                                            if (stp != null) {
                                              // compare time picker value with previous data
                                              if (stp.hour >= int.parse(jamHadirEnd.split(':')[0]) ||
                                                  (stp.hour == int.parse(jamHadirEnd.split(':')[0]) && stp.minute >= int.parse(jamHadirEnd.split(':')[1]))) {
                                                Get.snackbar(
                                                  "Terjadi Kesalahan",
                                                  "",
                                                  backgroundColor: const Color.fromARGB(150, 255, 50, 50),
                                                  colorText: const Color.fromARGB(255, 15, 15, 15),
                                                  messageText: Text(
                                                    "Jam Hadir Mulai Tidak Boleh Sama/Lebih dari Jam Hadir Akhir",
                                                    style: GoogleFonts.poppins(
                                                      fontWeight: FontWeight.w500,
                                                      color: const Color.fromARGB(255, 15, 15, 15),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                // convert time picker value to string
                                                var hour = stp.hour.toString().length < 2 ? "0${stp.hour.toString()}" : stp.hour.toString();
                                                var minute = stp.minute.toString().length < 2 ? "0${stp.minute.toString()}" : stp.minute.toString();

                                                // update value if data didn't same with previous data
                                                if (jamHadirStart != "$hour:$minute") {
                                                  await selfC.dbC.updates(
                                                    'schedule',
                                                    {
                                                      'jam_hadir_start': "$hour:$minute",
                                                    },
                                                  );
                                                }
                                              }
                                            }
                                            isQueryLoad.value = false;
                                          },
                                          child: Container(
                                            width: 110,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: Colors.blue.shade300,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                "${jamHadirStart.split(':')[0]}  :  ${jamHadirStart.split(':')[1]}",
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
                                                  jamHadirEnd.split(':')[0],
                                                ),
                                                minute: int.parse(
                                                  jamHadirEnd.split(':')[1],
                                                ),
                                              ),
                                              builder: (context, child) {
                                                return MediaQuery(
                                                  data: MediaQuery.of(context).copyWith(
                                                    alwaysUse24HourFormat: true,
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );

                                            // ignore: unnecessary_null_comparison
                                            // ---
                                            // if show time picker not null
                                            if (stp != null) {
                                              // Compare show time picker value with previous data
                                              if (stp.hour <= int.parse(jamHadirStart.split(':')[0]) ||
                                                  (stp.hour == int.parse(jamHadirStart.split(':')[0]) && stp.minute <= int.parse(jamHadirStart.split(':')[1]))) {
                                                Get.snackbar(
                                                  "Terjadi Kesalahan",
                                                  "",
                                                  backgroundColor: const Color.fromARGB(150, 255, 50, 50),
                                                  colorText: const Color.fromARGB(255, 15, 15, 15),
                                                  messageText: Text(
                                                    "Jam Hadir Akhir Tidak Boleh Sama/Kurang dari Jam Hadir Mulai",
                                                    style: GoogleFonts.poppins(
                                                      fontWeight: FontWeight.w500,
                                                      color: const Color.fromARGB(255, 15, 15, 15),
                                                    ),
                                                  ),
                                                );
                                                // Compare show time picker value with previous data
                                              }
                                              // Compare show time picker value with previous data
                                              else if (stp.hour >= int.parse(jamPulangStart.split(':')[0]) ||
                                                  (stp.hour == int.parse(jamPulangStart.split(':')[0]) && stp.minute >= int.parse(jamPulangStart.split(':')[1]))) {
                                                Get.snackbar(
                                                  "Terjadi Kesalahan",
                                                  "",
                                                  backgroundColor: const Color.fromARGB(150, 255, 50, 50),
                                                  colorText: const Color.fromARGB(255, 15, 15, 15),
                                                  messageText: Text(
                                                    "Jam Hadir Akhir Tidak Boleh Sama/Lebih dari Jam Pulang",
                                                    style: GoogleFonts.poppins(
                                                      fontWeight: FontWeight.w500,
                                                      color: const Color.fromARGB(255, 15, 15, 15),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                // Convert time picker value to string
                                                var hour = stp.hour.toString().length < 2 ? "0${stp.hour.toString()}" : stp.hour.toString();
                                                var minute = stp.minute.toString().length < 2 ? "0${stp.minute.toString()}" : stp.minute.toString();

                                                // update value if data didn't same with previous data
                                                if (jamHadirEnd != "$hour:$minute") {
                                                  await selfC.dbC.updates(
                                                    'schedule',
                                                    {
                                                      'jam_hadir_end': "$hour:$minute",
                                                    },
                                                  );
                                                }
                                              }
                                            }
                                            isQueryLoad.value = false;
                                          },
                                          child: Container(
                                            width: 110,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: Colors.blue.shade300,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                "${jamHadirEnd.split(':')[0]}  :  ${jamHadirEnd.split(':')[1]}",
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
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                                  child: const CircularProgressIndicator(
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // --- Jam Pulang Hadir --- //
                                        InkWell(
                                          onTap: () async {
                                            isQueryLoad.value = true;
                                            var stp = await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay(
                                                hour: int.parse(
                                                  jamPulangStart.split(':')[0],
                                                ),
                                                minute: int.parse(
                                                  jamPulangStart.split(':')[1],
                                                ),
                                              ),
                                              builder: (context, child) {
                                                return MediaQuery(
                                                  data: MediaQuery.of(context).copyWith(
                                                    alwaysUse24HourFormat: true,
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );

                                            // ignore: unnecessary_null_comparison
                                            // ---
                                            // if show time picker value not null
                                            if (stp != null) {
                                              // Compare show time picker value with previous data
                                              if (stp.hour <= int.parse(jamHadirEnd.split(":")[0]) ||
                                                  (stp.hour == int.parse(jamHadirEnd.split(":")[0]) && stp.minute <= int.parse(jamHadirEnd.split(":")[1]))) {
                                                Get.snackbar(
                                                  "Terjadi Kesalahan",
                                                  "",
                                                  backgroundColor: const Color.fromARGB(150, 255, 50, 50),
                                                  colorText: const Color.fromARGB(255, 15, 15, 15),
                                                  messageText: Text(
                                                    "Jam Pulang Mulai Tidak Boleh Sama/Kurang dari Jam Hadir Akhir",
                                                    style: GoogleFonts.poppins(
                                                      fontWeight: FontWeight.w500,
                                                      color: const Color.fromARGB(255, 15, 15, 15),
                                                    ),
                                                  ),
                                                );
                                                // Compare show time picker value with previous data
                                              }
                                              // Compare show time picker value with previous data
                                              else if (stp.hour >= int.parse(jamPulangEnd.split(":")[0]) ||
                                                  (stp.hour == int.parse(jamPulangEnd.split(":")[0]) && stp.minute >= int.parse(jamPulangEnd.split(":")[1]))) {
                                                Get.snackbar(
                                                  "Terjadi Kesalahan",
                                                  "",
                                                  backgroundColor: const Color.fromARGB(150, 255, 50, 50),
                                                  colorText: const Color.fromARGB(255, 15, 15, 15),
                                                  messageText: Text(
                                                    "Jam Pulang Mulai Tidak Boleh Sama/Lebih dari Jam Pulang Akhir",
                                                    style: GoogleFonts.poppins(
                                                      fontWeight: FontWeight.w500,
                                                      color: const Color.fromARGB(255, 15, 15, 15),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                // Convert time picker value to string
                                                var hour = stp.hour.toString().length < 2 ? "0${stp.hour.toString()}" : stp.hour.toString();
                                                var minute = stp.minute.toString().length < 2 ? "0${stp.minute.toString()}" : stp.minute.toString();

                                                // update value if data didn't same with previous data
                                                if (jamPulangStart != "$hour:$minute") {
                                                  await selfC.dbC.updates(
                                                    'schedule',
                                                    {
                                                      'jam_pulang_start': "$hour:$minute",
                                                    },
                                                  );
                                                }
                                              }
                                            }
                                            isQueryLoad.value = false;
                                          },
                                          child: Container(
                                            width: 110,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: Colors.blue.shade300,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                "${jamPulangStart.split(':')[0]}  :  ${jamPulangStart.split(':')[1]}",
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

                                        // --- Jam Pulang End --- //
                                        InkWell(
                                          onTap: () async {
                                            isQueryLoad.value = true;
                                            var stp = await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay(
                                                hour: int.parse(
                                                  jamPulangEnd.split(':')[0],
                                                ),
                                                minute: int.parse(
                                                  jamPulangEnd.split(':')[1],
                                                ),
                                              ),
                                              builder: (context, child) {
                                                return MediaQuery(
                                                  data: MediaQuery.of(context).copyWith(
                                                    alwaysUse24HourFormat: true,
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );

                                            // ignore: unnecessary_null_comparison
                                            // ---
                                            // if show time picker value not null
                                            if (stp != null) {
                                              // Compare time picker value with previous data
                                              if (stp.hour <= int.parse(jamPulangStart.split(":")[0]) ||
                                                  (stp.hour == int.parse(jamPulangStart.split(":")[0]) && stp.minute <= int.parse(jamPulangStart.split(":")[1]))) {
                                                Get.snackbar(
                                                  "Terjadi Kesalahan",
                                                  "",
                                                  backgroundColor: const Color.fromARGB(150, 255, 50, 50),
                                                  colorText: const Color.fromARGB(255, 15, 15, 15),
                                                  messageText: Text(
                                                    "Jam Pulang Akhir Tidak Boleh Sama/Kurang dari Jam Pulang Mulai",
                                                    style: GoogleFonts.poppins(
                                                      fontWeight: FontWeight.w500,
                                                      color: const Color.fromARGB(255, 15, 15, 15),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                // Convert time picker value to string
                                                var hour = stp.hour.toString().length < 2 ? "0${stp.hour.toString()}" : stp.hour.toString();
                                                var minute = stp.minute.toString().length < 2 ? "0${stp.minute.toString()}" : stp.minute.toString();

                                                // Update value if data didn't sasme with previous data
                                                if (jamPulangEnd != "$hour:$minute") {
                                                  await selfC.dbC.updates(
                                                    'schedule',
                                                    {
                                                      'jam_pulang_end': "$hour:$minute",
                                                    },
                                                  );
                                                }
                                              }
                                            }
                                            isQueryLoad.value = false;
                                          },
                                          child: Container(
                                            width: 110,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: Colors.blue.shade300,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                "${jamPulangEnd.split(':')[0]}  :  ${jamPulangEnd.split(':')[1]}",
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
                    );
                  }
                  return Container();
                },
              ),
              StreamBuilder<DatabaseEvent>(
                  stream: selfC.dbC.stream('absensi'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      DataSnapshot snap = snapshot.data!.snapshot;
                      List<Widget> colItems = [];
                      List<List<List<Map>>> all = [];

                      for (var i = 0; i < 12; i++) {
                        all.add([]);
                      }
                      for (var ch in snap.children) {
                        List<Map> tgl0 = [];
                        List<List<Map>> tgl1 = [];
                        for (var i = 0; i < 31; i++) {
                          tgl0.add(
                            {
                              "key": "${i + 1}",
                              "active": snap.child(ch.key as String).child("${i + 1}").child("details").child("active").value as bool,
                            },
                          );
                        }
                        for (var i = 0; i < tgl0.length; i += 6) {
                          tgl1.add(tgl0.sublist(i, i + 6 > tgl0.length ? tgl0.length : i + 6));
                        }

                        all[selfC.month.indexOf(ch.key)] = tgl1;
                      }

                      for (var i = 0; i < all.length; i++) {
                        var rows = <Widget>[];
                        for (var j = 0; j < all[i].length; j++) {
                          var row = <Widget>[];
                          for (var el in all[i][j]) {
                            row.add(
                              Builder(builder: (context) {
                                RxBool isLoad = false.obs;
                                return InkWell(
                                  onTap: () async {
                                    isLoad.value = true;
                                    await selfC.dbC.updates(
                                      "absensi/${selfC.month[i]}/${el['key']}/details",
                                      {
                                        "active": !(el["active"] as bool),
                                      },
                                    ).whenComplete(
                                      () => isLoad.value = false,
                                    );
                                  },
                                  child: Container(
                                    width: Get.width / 7,
                                    height: Get.width / 7,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: (el['active'] as bool) ? Colors.green : Colors.red.shade700,
                                    ),
                                    child: Center(
                                      child: isLoad.isFalse
                                          ? Text(
                                              el['key'] ?? "-",
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: Get.width * .075,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )
                                          : SizedBox(
                                              width: Get.width * .06,
                                              height: Get.width * .06,
                                              child: const CircularProgressIndicator(
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                );
                              }),
                            );
                          }
                          rows.add(
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: row,
                              ),
                            ),
                          );
                        }
                        colItems.add(
                          Container(
                            margin: const EdgeInsets.only(bottom: 25),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selfC.month[i].toString().toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: Get.width * .065,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                ...rows
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: colItems,
                      );
                    }

                    return Container();
                  }),
              // ...selfC.buildWidgets(),
            ],
          ),
        ),
      ),
    );
  }
}
