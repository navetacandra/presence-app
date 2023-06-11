import 'package:get/get.dart';

import '../controllers/edit_pegawai_controller.dart';

class EditPegawaiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditPegawaiController>(
      () => EditPegawaiController(),
    );
  }
}
