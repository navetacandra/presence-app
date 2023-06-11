// ignore_for_file: unnecessary_overrides
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';

class DbController extends GetxController {
  final mDb = FirebaseDatabase.instance;

  Stream<DatabaseEvent> stream(String ref) => mDb.ref(ref).onValue;
  Future<DataSnapshot> gets (String ref) async => await mDb.ref(ref).get();
  Future<void> updates (String ref, Map<String, Object?> data) => mDb.ref(ref).update(data);
  Future<void> remove (String ref) => mDb.ref(ref).remove();

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
}
