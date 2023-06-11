import 'package:get/get.dart';

import '../controllers/koneksi_whatsapp_controller.dart';

class KoneksiWhatsappBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KoneksiWhatsappController>(
      () => KoneksiWhatsappController(),
    );
  }
}
