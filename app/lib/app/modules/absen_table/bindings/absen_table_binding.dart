import 'package:get/get.dart';

import '../controllers/absen_table_controller.dart';

class AbsenTableBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AbsenTableController>(
      () => AbsenTableController(),
    );
  }
}
