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
            child: Card(
              elevation: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 8,
                ),
                width: Get.width * .8,
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Nama: ",
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          width: Get.width * .8 * .6,
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Email: ",
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Container(
                          height: 30,
                          width: Get.width * .8 * .6,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () => selfC.changePasswordForm(context),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.red.shade600),
                            ),
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
                          Obx(
                            () => ElevatedButton(
                              onPressed: () => (selfC.nameText.value == (selfC.profileDetail["name"] as String) || selfC.nameText.isEmpty) ? null : selfC.updateProfile(),
                              style: ElevatedButton.styleFrom(
                                elevation: (selfC.nameText.value == (selfC.profileDetail["name"] as String) || selfC.nameText.isEmpty) ? 0 : 1,
                                backgroundColor: (selfC.nameText.value == (selfC.profileDetail["name"] as String) || selfC.nameText.isEmpty) ? Colors.white : Colors.yellow.shade700,
                                side: (selfC.nameText.value == (selfC.profileDetail["name"] as String) || selfC.nameText.isEmpty)
                                    ? BorderSide(width: 1, color: Colors.yellow.shade700)
                                    : const BorderSide(width: 0, color: Colors.transparent),
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
