import 'package:get/get.dart';

import '../modules/daftar_pegawai/bindings/daftar_pegawai_binding.dart';
import '../modules/daftar_pegawai/views/daftar_pegawai_view.dart';
import '../modules/edit_pegawai/bindings/edit_pegawai_binding.dart';
import '../modules/edit_pegawai/views/edit_pegawai_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/jadwal_absen/bindings/jadwal_absen_binding.dart';
import '../modules/jadwal_absen/views/jadwal_absen_view.dart';
import '../modules/koneksi_esp/bindings/koneksi_esp_binding.dart';
import '../modules/koneksi_esp/views/koneksi_esp_view.dart';
import '../modules/koneksi_whatsapp/bindings/koneksi_whatsapp_binding.dart';
import '../modules/koneksi_whatsapp/views/koneksi_whatsapp_view.dart';
import '../modules/kontrol_mode/bindings/kontrol_mode_binding.dart';
import '../modules/kontrol_mode/views/kontrol_mode_view.dart';
import '../modules/signin/bindings/signin_binding.dart';
import '../modules/signin/views/signin_view.dart';
import '../modules/signup/bindings/signup_binding.dart';
import '../modules/signup/views/signup_view.dart';
import '../modules/tambah_kartu/bindings/tambah_kartu_binding.dart';
import '../modules/tambah_kartu/views/tambah_kartu_view.dart';
import '../modules/tambah_kartu_proses/bindings/tambah_kartu_proses_binding.dart';
import '../modules/tambah_kartu_proses/views/tambah_kartu_proses_view.dart';
import '../modules/tambah_pegawai/bindings/tambah_pegawai_binding.dart';
import '../modules/tambah_pegawai/views/tambah_pegawai_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // ignore: constant_identifier_names
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SIGNIN,
      page: () => SigninView(),
      binding: SigninBinding(),
    ),
    GetPage(
      name: _Paths.DAFTAR_PEGAWAI,
      page: () => DaftarPegawaiView(),
      binding: DaftarPegawaiBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: _Paths.TAMBAH_PEGAWAI,
      page: () => TambahPegawaiView(),
      binding: TambahPegawaiBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: _Paths.KONEKSI_WHATSAPP,
      page: () => KoneksiWhatsappView(),
      binding: KoneksiWhatsappBinding(),
    ),
    GetPage(
      name: _Paths.TAMBAH_KARTU,
      page: () => TambahKartuView(),
      binding: TambahKartuBinding(),
    ),
    GetPage(
      name: _Paths.TAMBAH_KARTU_PROSES,
      page: () => TambahKartuProsesView(),
      binding: TambahKartuProsesBinding(),
    ),
    GetPage(
      name: _Paths.SIGNUP,
      page: () => SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: _Paths.KONTROL_MODE,
      page: () => KontrolModeView(),
      binding: KontrolModeBinding(),
    ),
    GetPage(
      name: _Paths.JADWAL_ABSEN,
      page: () => JadwalAbsenView(),
      binding: JadwalAbsenBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_PEGAWAI,
      page: () => EditPegawaiView(),
      binding: EditPegawaiBinding(),
    ),
    GetPage(
      name: _Paths.KONEKSI_ESP,
      page: () => KoneksiEspView(),
      binding: KoneksiEspBinding(),
    ),
  ];
}
