// ignore_for_file: unnecessary_overrides
import 'package:get/get.dart';

class HomeController extends GetxController {
  RxString date = ''.obs;
  RxString month = ''.obs;
  
  @override
  void onInit() async {
    super.onInit();
    while (true) {
      DateTime tz = DateTime.now().toUtc().subtract(const Duration(hours: -7));
      date.value = tz.day.toString();
      month.value = [
        'januari',
        'februari',
        'maret',
        'april',
        'mei',
        'juni',
        'juli',
        'agustus',
        'september',
        'oktober',
        'november',
        'desember'
      ].elementAt(tz.month - 1);
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
