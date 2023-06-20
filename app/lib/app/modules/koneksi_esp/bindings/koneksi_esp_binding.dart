import 'package:get/get.dart';

import '../controllers/koneksi_esp_controller.dart';

class KoneksiEspBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KoneksiEspController>(
      () => KoneksiEspController(),
    );
  }
}
