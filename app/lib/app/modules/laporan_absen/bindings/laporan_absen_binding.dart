import 'package:get/get.dart';

import '../controllers/laporan_absen_controller.dart';

class LaporanAbsenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LaporanAbsenController>(
      () => LaporanAbsenController(),
    );
  }
}
