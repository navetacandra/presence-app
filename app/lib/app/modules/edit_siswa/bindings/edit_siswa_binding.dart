import 'package:get/get.dart';

import '../controllers/edit_siswa_controller.dart';

class EditSiswaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditSiswaController>(
      () => EditSiswaController(),
    );
  }
}
