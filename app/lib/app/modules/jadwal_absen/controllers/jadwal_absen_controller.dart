// ignore_for_file: unnecessary_overrides
import 'package:get/get.dart';
import 'package:presence/app/controllers/db_controller.dart';

class JadwalAbsenController extends GetxController {
  final dbC = Get.find<DbController>();
  List month = [
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
    'desember',
  ];

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  bool compareJamHadirStart(String curr, String jamEnd) {
    int currHour = int.parse(curr.split(":")[0]);
    int currMinute = int.parse(curr.split(":")[1]);
    int jamEndHour = int.parse(jamEnd.split(":")[0]);
    int jamEndMinute = int.parse(jamEnd.split(":")[1]);

    if (currHour == jamEndHour && currMinute >= jamEndMinute) return true;
    if (currHour > jamEndHour) return true;
    return false;
  }

  bool compareJamHadirEnd(String curr, String jamHdrStart, String jamPlgStart) {
    int currHour = int.parse(curr.split(":")[0]);
    int currMinute = int.parse(curr.split(":")[1]);
    int jamHdrStartHour = int.parse(jamHdrStart.split(":")[0]);
    int jamHdrStartMinute = int.parse(jamHdrStart.split(":")[1]);
    int jamPlgStartHour = int.parse(jamPlgStart.split(":")[0]);
    int jamPlgStartMinute = int.parse(jamPlgStart.split(":")[1]);

    if (currHour < jamHdrStartHour) return true;
    if (currHour > jamPlgStartHour) return true;
    if (currHour == jamHdrStartHour && currMinute <= jamHdrStartMinute) return true;
    if (currHour == jamPlgStartHour && currMinute + 15 >= jamPlgStartMinute) return true;
    return false;
  }

  bool compareJamPulangStart(String curr, String jamHdrEnd, String jamPlgEnd) {
    int currHour = int.parse(curr.split(":")[0]);
    int currMinute = int.parse(curr.split(":")[1]);
    int jamHdrEndHour = int.parse(jamHdrEnd.split(":")[0]);
    int jamHdrEndMinute = int.parse(jamHdrEnd.split(":")[1]);
    int jamPlgEndHour = int.parse(jamPlgEnd.split(":")[0]);
    int jamPlgEndMinute = int.parse(jamPlgEnd.split(":")[1]);

    if (currHour < jamHdrEndHour) return true;
    if (currHour > jamPlgEndHour) return true;
    if (currHour == jamHdrEndHour && currMinute <= jamHdrEndMinute + 15) return true;
    if (currHour == jamPlgEndHour && currMinute >= jamPlgEndMinute) return true;
    return false;
  }

  bool compareJamPulangend(String curr, String jamPlgStart) {
    int currHour = int.parse(curr.split(":")[0]);
    int currMinute = int.parse(curr.split(":")[1]);
    int jamPlgStartHour = int.parse(jamPlgStart.split(":")[0]);
    int jamPlgStartMinute = int.parse(jamPlgStart.split(":")[1]);

    if (currHour < jamPlgStartHour) return true;
    if (currHour == jamPlgStartHour && currMinute <= jamPlgStartMinute) return true;
    return false;
  }
}
