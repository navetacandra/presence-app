import 'package:get/get.dart';

import '../controllers/tambah_kartu_proses_controller.dart';

class TambahKartuProsesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TambahKartuProsesController>(
      () => TambahKartuProsesController(),
    );
  }
}
