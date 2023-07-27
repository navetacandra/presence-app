import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  ProfileView({Key? key}) : super(key: key);
  final selfC = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 2,
                    spreadRadius: 2,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 8,
                ),
                width: Get.width * .9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "PROFILE",
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Obx(
                      () => (selfC.profileDetail["photoURL"] as String).isEmpty
                          ? Container()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Get.width * .25),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: Colors.black87.withAlpha(20),
                                        offset: const Offset(2, 2),
                                        blurRadius: 4,
                                        spreadRadius: 4,
                                      )
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(Get.width * .25),
                                    child: Image.network(
                                      (selfC.profileDetail["photoURL"] as String),
                                      width: Get.width * .3,
                                      height: Get.width * .3,
                                    ),
                                  ),
                                )
                              ],
                            ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(
                          height: 40,
                          child: Text(
                            "Nama: ",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                          width: Get.width * .6,
                          child: TextField(
                            controller: selfC.nameContorller,
                            textAlign: TextAlign.start,
                            textAlignVertical: TextAlignVertical.center,
                            onChanged: (value) => selfC.nameText.value = value,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              isCollapsed: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              hintText: "Nama",
                            ),
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(
                          height: 40,
                          child: Text(
                            "Email: ",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                          width: Get.width * .6,
                          child: TextField(
                            controller: selfC.emailContorller,
                            textAlign: TextAlign.start,
                            textAlignVertical: TextAlignVertical.center,
                            readOnly: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              isCollapsed: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              hintText: "Email",
                            ),
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () => selfC.changePasswordForm(context),
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              height: 50,
                              width: Get.width * .75,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.red.shade700),
                              child: Center(
                                child: Text(
                                  "Ganti Password",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Obx(
                            () => InkWell(
                              onTap: () => (selfC.nameText.value == (selfC.profileDetail["name"] as String) || selfC.nameText.isEmpty) ? null : selfC.updateProfile(),
                              child: Container(
                                width: Get.width * .75,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: (selfC.nameText.value == (selfC.profileDetail["name"] as String) || selfC.nameText.isEmpty) ? Colors.yellow.shade700 : Colors.transparent,
                                    width: 2,
                                  ),
                                  color: (selfC.nameText.value == (selfC.profileDetail["name"] as String) || selfC.nameText.isEmpty) ? Colors.transparent : Colors.yellow.shade700,
                                ),
                                child: Center(
                                  child: Text(
                                    "Edit Profile",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: (selfC.nameText.value == (selfC.profileDetail["name"] as String) || selfC.nameText.isEmpty) ? Colors.yellow.shade700 : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
