import 'package:get/get.dart';

import '../controllers/tambah_siswa_controller.dart';

class TambahSiswaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TambahSiswaController>(
      () => TambahSiswaController(),
    );
  }
}
