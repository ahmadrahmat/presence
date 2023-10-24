import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:presence/app/routes/app_pages.dart';

class PageIndexController extends GetxController {
  RxInt pageIndex = 0.obs;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void changePage(int i) async {
    // pageIndex.value = i;
    switch (i) {
      case 1:
        Map<String, dynamic> dataResponse = await determinePosition();
        if (dataResponse['error'] != true) {
          Position position = dataResponse['position'];

          List<Placemark> placemarks = await placemarkFromCoordinates(
              position.latitude, position.longitude);

          String address =
              "${placemarks[0].street}, ${placemarks[0].subLocality}, ${placemarks[0].locality}";

          await updatePosition(position, address);

          // cek jarak 2 koordinat
          double distance = Geolocator.distanceBetween(
              0.5558259, 123.0637945, position.latitude, position.longitude);

          // print(distance);

          // melakukan presensi
          await presensi(position, address, distance);

          // Get.snackbar('Berhasil', 'Berhasil melakukan presensi.');
        } else {
          Get.snackbar("Terjadi kesalahan", dataResponse['message']);
        }
        break;
      case 2:
        pageIndex.value = i;
        Get.offAllNamed(Routes.PROFILE);
        break;
      default:
        pageIndex.value = i;
        Get.offAllNamed(Routes.HOME);
    }
  }

  Future<void> presensi(
      Position position, String address, double distance) async {
    String uid = auth.currentUser!.uid;

    CollectionReference<Map<String, dynamic>> colPresence =
        firestore.collection("pegawai").doc(uid).collection("presence");

    QuerySnapshot<Map<String, dynamic>> snapPresence = await colPresence.get();

    DateTime now = DateTime.now();
    String todayDocID = DateFormat.yMd().format(now).replaceAll("/", "-");
    // print(todayDocID);

    String status = "Di luar area";

    if (distance <= 200) {
      status = "Di dalam area";
    }

    if (snapPresence.docs.isEmpty) {
      // belum pernah absen sama sekali & set absen masuk pertama kalinya
      await Get.defaultDialog(
          title: "Validasi Presensi",
          middleText: "Apakah kamu yakin ingin melakukan presensi masuk?",
          actions: [
            OutlinedButton(
                onPressed: () => Get.back(), child: const Text("CANCEL")),
            ElevatedButton(
                onPressed: () async {
                  await colPresence.doc(todayDocID).set({
                    "date": now.toIso8601String(),
                    "masuk": {
                      "date": now.toIso8601String(),
                      "lat": position.latitude,
                      "long": position.longitude,
                      "address": address,
                      "status": status,
                      "distance": distance,
                    }
                  });
                  Get.back();
                  Get.snackbar(
                      "Berhasil", "Berhasil melakukan presensi masuk.");
                },
                child: const Text("YES"))
          ]);
    } else {
      // sudah pernah absen -> cek hari ini udah absen masuk/keluar belum?
      DocumentSnapshot<Map<String, dynamic>> todayDoc =
          await colPresence.doc(todayDocID).get();

      if (todayDoc.exists == true) {
        // tinggal absen keluar atau sudah absen masuk dan keluar
        Map<String, dynamic>? dataPresenceToday = todayDoc.data();
        if (dataPresenceToday?['keluar'] != null) {
          // sudah absen masuk dan keluar
          Get.snackbar(
              "Informasi", "Kamu sudah melakukan absensi masuk dan keluar.");
        } else {
          // absen keluar
          await Get.defaultDialog(
              title: "Validasi Presensi",
              middleText: "Apakah kamu yakin ingin melakukan presensi keluar?",
              actions: [
                OutlinedButton(
                    onPressed: () => Get.back(), child: const Text("CANCEL")),
                ElevatedButton(
                    onPressed: () async {
                      await colPresence.doc(todayDocID).update({
                        "keluar": {
                          "date": now.toIso8601String(),
                          "lat": position.latitude,
                          "long": position.longitude,
                          "address": address,
                          "status": status,
                          "distance": distance,
                        }
                      });
                      Get.back();
                      Get.snackbar(
                          "Berhasil", "Berhasil melakukan presensi keluar.");
                    },
                    child: const Text("YES"))
              ]);
        }
      } else {
        // absen masuk
        await Get.defaultDialog(
            title: "Validasi Presensi",
            middleText: "Apakah kamu yakin ingin melakukan presensi masuk?",
            actions: [
              OutlinedButton(
                  onPressed: () => Get.back(), child: const Text("CANCEL")),
              ElevatedButton(
                  onPressed: () async {
                    await colPresence.doc(todayDocID).set({
                      "date": now.toIso8601String(),
                      "masuk": {
                        "date": now.toIso8601String(),
                        "lat": position.latitude,
                        "long": position.longitude,
                        "address": address,
                        "status": status,
                        "distance": distance,
                      }
                    });
                    Get.back();
                    Get.snackbar(
                        "Berhasil", "Berhasil melakukan presensi masuk.");
                  },
                  child: const Text("YES"))
            ]);
      }
    }
  }

  Future<void> updatePosition(Position position, String address) async {
    String uid = auth.currentUser!.uid;

    await firestore.collection("pegawai").doc(uid).update({
      "position": {
        "lat": position.latitude,
        "long": position.longitude,
      },
      "address": address
    });
  }

  Future<Map<String, dynamic>> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return {
        "message": "Layanan lokasi dinonaktifkan.",
        "error": true,
      };
      // return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return {
          "message": "Izin lokasi ditolak.",
          "error": true,
        };
        // return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return {
        "message":
            "Izin lokasi ditolak secara permanen, kami tidak dapat meminta izin.",
        "error": true,
      };
      // return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition();
    return {
      "position": position,
      "message": "Berhasil mendapatkan posisi device.",
      "error": false,
    };
  }
}
