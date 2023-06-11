import 'package:get/get.dart';

import '../controllers/kontrol_mode_controller.dart';

class KontrolModeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KontrolModeController>(
      () => KontrolModeController(),
    );
  }
}
