import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence/app/controllers/db_controller.dart';
import '../controllers/kontrol_mode_controller.dart';

class KontrolModeView extends GetView<KontrolModeController> {
  KontrolModeView({Key? key}) : super(key: key);
  final dbC = Get.find<DbController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ganti Mode'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () => dbC.updates("", {"mode": false}),
              child: Text(
                "Registrasi Kartu",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Transform.rotate(
              angle: 3.14 / 2,
              child: SizedBox(
                width: 125,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: StreamBuilder<DatabaseEvent>(
                    stream: dbC.stream("mode"),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        return Switch(
                          activeColor: const Color.fromRGBO(130, 220, 65, 1),
                          value: snapshot.data!.snapshot.value as bool,
                          onChanged: (value) =>
                              dbC.updates("", {"mode": value}),
                        );
                      }
                      return const CircularProgressIndicator(
                        color: Colors.black87,
                      );
                    },
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () => dbC.updates("", {"mode": true}),
              child: Text(
                "Presensi",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
