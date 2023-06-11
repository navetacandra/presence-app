import 'package:get/get.dart';

import '../controllers/tambah_kartu_controller.dart';

class TambahKartuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TambahKartuController>(
      () => TambahKartuController(),
    );
  }
}
