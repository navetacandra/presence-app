import 'package:get/get.dart';

import '../controllers/daftar_pegawai_controller.dart';

class DaftarPegawaiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DaftarPegawaiController>(
      () => DaftarPegawaiController(),
    );
  }
}
