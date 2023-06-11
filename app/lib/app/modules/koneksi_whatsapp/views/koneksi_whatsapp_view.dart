import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/koneksi_whatsapp_controller.dart';

class KoneksiWhatsappView extends GetView<KoneksiWhatsappController> {
  KoneksiWhatsappView({Key? key}) : super(key: key);
  final selfC = Get.find<KoneksiWhatsappController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koneksi WhatsApp'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Obx(() {
            if (selfC.isReady.isNotEmpty && selfC.isReady["isReady"]) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 60,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: Get.width * .75,
                      margin: const EdgeInsets.only(bottom: 25),
                      child: Text(
                        "Terhubung Sebagai",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Get.width * .5 / 2),
                      child: Image.network(
                        selfC.isReady["user"]?["profilePict"] ??
                            "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
                        width: Get.width * .5,
                        height: Get.width * .5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      width: Get.width * .75,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Nama",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 19,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            selfC.isReady["user"]["name"] ?? "-",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 19,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: Get.width * .75,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Telpon",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 19,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "+${(selfC.isReady["user"]["id"] ?? "-").replaceFirst(
                                  RegExp(r"\:[0-9]"),
                                  "",
                                ).replaceFirst(
                                  RegExp(r"\@c\.us"),
                                  "",
                                )}",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 19,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    InkWell(
                      onTap: () => selfC.logoutLoading.isTrue ? null : selfC.logoutSession(),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: !selfC.logoutLoading.value
                              ? Text(
                                  "Sign Out",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : const Padding(
                                padding: EdgeInsets.all(5),
                                child: CircularProgressIndicator(
                                    color: Color(0XFFFFFFFF),
                                  ),
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: Get.width * .75,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        "Scan QR WhatsApp",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Image.memory(
                        const Base64Decoder().convert(selfC.qrcode.value),
                        width: 250,
                        height: 250,
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
        ),
      ),
    );
  }
}
