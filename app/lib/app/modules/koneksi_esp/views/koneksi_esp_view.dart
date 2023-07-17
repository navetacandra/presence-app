import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/colors.dart';
import '../controllers/koneksi_esp_controller.dart';

class KoneksiEspView extends GetView<KoneksiEspController> {
  KoneksiEspView({Key? key}) : super(key: key);
  final selfC = Get.find<KoneksiEspController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koneksi ESP'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              Obx(
                () => Container(
                  child: selfC.networks.isNotEmpty
                      ? const SizedBox(
                          height: 30,
                        )
                      : Container(),
                ),
              ),
              Obx(
                () {
                  List<Widget> children = [];
                  for (var i = 0; i < selfC.networks.length; i++) {
                    String ssid = selfC.networks.elementAt(i)['ssid'] as String;
                    bool secure = selfC.networks.elementAt(i)['secure'] as bool;
                    children.add(
                      GestureDetector(
                        onTap: () => selfC.ssid.text = ssid,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 3,
                                offset: const Offset(
                                  0,
                                  3,
                                ), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                ssid,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              secure
                                  ? const Icon(Icons.lock_outline)
                                  : const Icon(Icons.lock_open),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: children,
                  );
                },
              ),
              const SizedBox(
                height: 30,
              ),
              Form(
                key: selfC.formField,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      controller: selfC.ssid,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "SSID",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.network_wifi),
                        errorStyle: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 15,
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "SSID wajib di-isi!" : null,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Obx(
                      () => TextFormField(
                        controller: selfC.pass,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: !selfC.showNetPass.value,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: InkWell(
                            onTap: () => selfC.showNetPass.value =
                                !selfC.showNetPass.value,
                            child: Icon(
                              selfC.showNetPass.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                          errorStyle: GoogleFonts.poppins(
                            color: Colors.red,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: selfC.apikey,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "APIKEY",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.key),
                        errorStyle: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 15,
                        ),
                      ),
                      validator: (value) => value!.isEmpty
                          ? "APIKEY wajib di-isi!"
                          : null,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    InkWell(
                      onTap: () =>
                          selfC.isLoading.isTrue ? null : selfC.validateForm(),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: mPrimaryGradientColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Obx(
                            () => selfC.isLoading.isFalse
                                ? Text(
                                    "Kirim",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                : const Padding(
                                    padding: EdgeInsets.all(5),
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFFFFFFF),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
