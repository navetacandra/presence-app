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
                      controller: selfC.fhost,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        labelText: "Firebase Host",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.web),
                        errorStyle: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 15,
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Firebase Host wajib di-isi!" : null,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: selfC.fkey,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Firebase APIKEY",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.key),
                        errorStyle: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 15,
                        ),
                      ),
                      validator: (value) => value!.isEmpty
                          ? "Firebase APIKEY wajib di-isi!"
                          : null,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: selfC.fauthEmail,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Firebase Auth Email",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.email),
                        errorStyle: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 15,
                        ),
                      ),
                      validator: (value) => selfC.validateEmail(value),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Obx(
                      () => TextFormField(
                        controller: selfC.fauthPass,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: !selfC.showFauthPass.value,
                        decoration: InputDecoration(
                          labelText: "Firebase Auth Password",
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: InkWell(
                            onTap: () => selfC.showFauthPass.value =
                                !selfC.showFauthPass.value,
                            child: Icon(
                              selfC.showFauthPass.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                          errorStyle: GoogleFonts.poppins(
                            color: Colors.red,
                            fontSize: 15,
                          ),
                        ),
                        validator: (value) => value!.isEmpty
                            ? "Auth Password wajib di-isi!"
                            : value.length < 6
                                ? "Auth Password minimal berisi 6 karakter"
                                : null,
                      ),
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
