import 'package:get/get.dart';

import '../controllers/jadwal_absen_controller.dart';

class JadwalAbsenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JadwalAbsenController>(
      () => JadwalAbsenController(),
    );
  }
}
