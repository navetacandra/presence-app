import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence/app/controllers/auth_controller.dart';
import 'package:presence/app/controllers/db_controller.dart';
import 'package:presence/app/controllers/location_controller.dart';
import 'package:presence/app/data/colors.dart';
import 'app/routes/app_pages.dart';
import 'firebase_options.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  MyApp({
    super.key,
  });

  final locationController = Get.put(LocationController(), permanent: true);
  final authC = Get.put<AuthController>(AuthController(), permanent: true);
  final dbC = Get.put<DbController>(DbController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // future: Future.delayed(const Duration(seconds: 3)),
      future: Future.delayed(Duration.zero),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return StreamBuilder<User?>(
            stream: authC.streamCredential,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                return GetMaterialApp(
                  title: "Ma5Ter Absensi",
                  theme: ThemeData(
                    scaffoldBackgroundColor: mBackgroundColor,
                  ),
                  debugShowCheckedModeBanner: false,
                  initialRoute: snapshot.data != null ? Routes.HOME : Routes.SIGNIN,
                  // snapshot.data != null ? Routes.HOME : Routes.SIGNUP,
                  getPages: AppPages.routes,
                );
              }
              return Container();
            },
          );
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
              backgroundColor: Colors.white,
              body: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Ma5Ter Absensi",
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: Get.width / 10,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        "SMKN 5 Kab. Tangerang",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: Get.width / 18,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        );
      },
    );
  }
}
