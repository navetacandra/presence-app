import 'package:get/get.dart';
import '../controllers/daftar_siswa_controller.dart';

class DaftarSiswaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DaftarSiswaController>(
      () => DaftarSiswaController(),
    );
  }
}
