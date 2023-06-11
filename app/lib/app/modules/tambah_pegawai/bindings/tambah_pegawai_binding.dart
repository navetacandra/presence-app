import 'package:get/get.dart';

import '../controllers/tambah_pegawai_controller.dart';

class TambahPegawaiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TambahPegawaiController>(
      () => TambahPegawaiController(),
    );
  }
}
