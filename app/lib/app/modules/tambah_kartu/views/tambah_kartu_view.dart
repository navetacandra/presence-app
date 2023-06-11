import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tambah_kartu_controller.dart';

class TambahKartuView extends GetView<TambahKartuController> {
  TambahKartuView({Key? key}) : super(key: key);
  final selfC = Get.put<TambahKartuController>(TambahKartuController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kartu'),
      ),
      body: SafeArea(
        child: Container(
          width: Get.width,
          height: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: Get.width * .025,
            vertical: 20,
          ),
          child: SingleChildScrollView(
            child: Obx(
              () => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: selfC.buildWidgetList(context: context) ,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
