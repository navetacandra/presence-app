// ignore_for_file: unnecessary_overrides
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence/app/controllers/db_controller.dart';

class JadwalAbsenController extends GetxController {
  final dbC = Get.find<DbController>();
  List month = [
    'januari',
    'februari',
    'maret',
    'april',
    'mei',
    'juni',
    'juli',
    'agustus',
    'september',
    'oktober',
    'november',
    'desember',
  ];
  RxList<List<List<Map>>> activeList = [
    [
      [{}]
    ]
  ].obs;
  RxMap<String, String?> absenDetail = {"": ""}.obs;

  @override
  void onInit() async {
    super.onInit();
    dbC.stream('absen_detail').listen((event) {
      DataSnapshot snap = event.snapshot;
      for (var ch in snap.children) {
        absenDetail[ch.key as String] = ch.value.toString();
      }
    });
    dbC.stream('absensi').listen(
      (event) {
        DataSnapshot snapht = event.snapshot;
        for (var i = 0; i < 12; i++) {
          activeList.add([]);
        }

        for (var ch in snapht.children) {
          List<Map> all0 = [];
          List<List<Map>> all = [];
          for (var i = 0; i < 31; i++) {
            all0.add(
              {
                "key": "${i + 1}",
                "active": snapht
                    .child(ch.key as String)
                    .child("${i + 1}")
                    .child("active")
                    .value as bool,
              },
            );
          }
          for (var i = 0; i < all0.length; i += 6) {
            all.add(all0.sublist(i, i + 6 > all0.length ? all0.length : i + 6));
          }

          activeList[month.indexOf(ch.key)] = all;
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

  List<Widget> buildWidgets() {
    var widgets = <Widget>[];

    activeList.asMap().forEach((idx, elem) {
      if (elem.isNotEmpty) {
        var widget = Container(
          margin: const EdgeInsets.only(bottom: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                month[idx].toString().toUpperCase(),
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: Get.width * .065,
                  fontWeight: FontWeight.w500,
                ),
              ),
              ...elem
                  .map(
                    (el) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: el.map(
                          (e) {
                            RxBool isQueryLoad = false.obs;
                            return InkWell(
                              onTap: () {
                                var key = e["key"] ?? "";
                                isQueryLoad.value = true;
                                dbC.updates(
                                  'absensi/${month[idx].toString()}/$key',
                                  {
                                    "active": !(e['active'] as bool),
                                  },
                                ).whenComplete(
                                  () => isQueryLoad.value = false,
                                );
                              },
                              child: Container(
                                width: Get.width / 7,
                                height: Get.width / 7,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: e['active'] ?? false
                                      ? Colors.green
                                      : Colors.red.shade700,
                                ),
                                child: Obx(
                                  () => Center(
                                    child: isQueryLoad.isFalse
                                        ? Text(
                                            e['key'] ?? "",
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: Get.width * .075,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        : const CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
        );
        widgets.add(widget);
      }
    });

    return widgets;
  }
}
