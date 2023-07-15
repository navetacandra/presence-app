import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence/app/controllers/auth_controller.dart';
import 'package:presence/app/controllers/db_controller.dart';
import 'package:presence/app/data/colors.dart';
import 'package:presence/app/routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);
  final selfC = Get.find<HomeController>();
  final authC = Get.find<AuthController>();
  final dbC = Get.find<DbController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Container(
                height: Get.height * .25,
                decoration: const BoxDecoration(
                  gradient: mPrimaryGradientColor,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: Get.width * .05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Greeting Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: (Get.width - Get.width * .1) / 2,
                          margin: EdgeInsets.symmetric(
                            vertical: Get.height * .025,
                          ),
                          child: Obx(
                            () => Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Hai,",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  // overflow: TextOverflow.ellipsis,
                                ),
                                TextButton(
                                  onPressed: () => Get.toNamed(Routes.PROFILE),
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                      bottom: .25,
                                    ),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      selfC.name.value,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Sign Out Button
                        Container(
                          width: (Get.width - Get.width * .1) / 2,
                          alignment: Alignment.topRight,
                          child: InkWell(
                            onTap: () => authC.signOut(),
                            child: const Icon(
                              Icons.logout,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                    // End Greeting Section

                    // Detail Info Card
                    Container(
                      width: double.infinity,
                      height: Get.height * .25,
                      margin: const EdgeInsets.only(bottom: 40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            blurRadius: 5,
                            color: Color.fromARGB(50, 0, 0, 0),
                            spreadRadius: 1,
                            offset: Offset(5, 5),
                          )
                        ],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            SizedBox(
                              width: Get.width * .4,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Image.asset(
                                        'assets/users.png',
                                        width: 50,
                                        height: 50,
                                      ),
                                      Container(
                                        width: Get.width * .2,
                                        alignment: Alignment.topRight,
                                        child: Text(
                                          "Pegawai Terdaftar",
                                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                                          textAlign: TextAlign.end,
                                          softWrap: true,
                                          overflow: TextOverflow.clip,
                                        ),
                                      )
                                    ],
                                  ),
                                  StreamBuilder<DatabaseEvent>(
                                    stream: dbC.stream("pegawai"),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.active && snapshot.data!.snapshot.exists) {}
                                      return Container(
                                        margin: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          snapshot.connectionState == ConnectionState.active
                                              ? snapshot.data!.snapshot.exists
                                                  ? "${snapshot.data!.snapshot.children.length}"
                                                  : "0"
                                              : "-",
                                          style: GoogleFonts.poppins(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: Get.width * .4,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Image.asset(
                                        'assets/users-check.png',
                                        width: 50,
                                        height: 50,
                                      ),
                                      Container(
                                        width: Get.width * .2,
                                        alignment: Alignment.topRight,
                                        child: Text(
                                          "Pegawai Hadir",
                                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                                          textAlign: TextAlign.end,
                                          softWrap: true,
                                          overflow: TextOverflow.clip,
                                        ),
                                      )
                                    ],
                                  ),
                                  StreamBuilder<DatabaseEvent>(
                                    stream: dbC.stream("absensi/${selfC.month}/${selfC.date}/pegawai"),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.active && snapshot.data!.snapshot.exists) {}
                                      return Container(
                                        margin: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          snapshot.connectionState == ConnectionState.active
                                              ? snapshot.data!.snapshot.exists
                                                  ? "${snapshot.data!.snapshot.children.length}"
                                                  : "0"
                                              : "-",
                                          style: GoogleFonts.poppins(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // End Detail Info Card

                    // Menu Section
                    Obx(
                      () => Column(
                        children: selfC.currentMenu.isNotEmpty
                            // ignore: unnecessary_cast
                            ? <Widget>[
                                ...selfC.currentMenu
                                    .map(
                                      (menuList) => Container(
                                        margin: const EdgeInsets.only(bottom: 20),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            ...menuList
                                                .map(
                                                  (menu) => menuItem(
                                                    image: menu["image"] ?? "assets/avatar.jpg",
                                                    label: menu["label"] ?? "",
                                                    navigation: menu["navigation"] ?? "",
                                                  ),
                                                )
                                                .toList(),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ]
                            : [],
                      ),
                    ),
                    // End Menu Section
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  SizedBox menuItem({required String image, required String label, String? navigation = Routes.HOME}) {
    return SizedBox(
      width: Get.width / 5,
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: () => Get.toNamed(navigation as String),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 5,
              ),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 245, 245, 245),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const <BoxShadow>[BoxShadow(color: Color.fromARGB(50, 0, 0, 0), blurRadius: 2, offset: Offset(1, 2))],
              ),
              child: Image.asset(
                image,
                width: Get.width / 7,
              ),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w400, height: 1.15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
