// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/detail_presensi_controller.dart';

// Map<String, dynamic> data = Get.arguments;

class DetailPresensiView extends GetView<DetailPresensiController> {
  const DetailPresensiView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print(Get.arguments);
    return Scaffold(
      appBar: AppBar(
        title: const Text('DETAIL PRESENSI'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey[200],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    DateFormat.yMMMMEEEEd()
                        .format(DateTime.parse(Get.arguments['date'])),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Masuk",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                    "Jam : ${DateFormat.jms().format(DateTime.parse(Get.arguments['masuk']!['date']))}"),
                Text(
                    "Posisi : ${Get.arguments['masuk']!['lat']}, ${Get.arguments['masuk']!['long']}"),
                Text("Status : ${Get.arguments['masuk']!['status']}"),
                Text(
                    "Jarak : ${Get.arguments['masuk']!['distance'].round()} meter"),
                Text("Alamat : ${Get.arguments['masuk']!['address']}"),
                SizedBox(height: 20),
                Text(
                  "Keluar",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(Get.arguments['keluar']?['date'] == null
                    ? "Jam : -"
                    : "Jam : ${DateFormat.jms().format(DateTime.parse(Get.arguments['keluar']!['date']))}"),
                Text(Get.arguments['keluar']?['lat'] == null &&
                        Get.arguments['keluar']?['long'] == null
                    ? "Posisi : -"
                    : "Posisi : ${Get.arguments['keluar']!['lat']}, ${Get.arguments['keluar']!['long']}"),
                Text(Get.arguments['keluar']?['status'] == null
                    ? "Status : -"
                    : "Status : ${Get.arguments['keluar']!['status']}"),
                Text(Get.arguments['keluar']?['distance'] == null
                    ? "Jarak : -"
                    : "Jarak : ${Get.arguments['keluar']!['distance'].round()} meter"),
                Text(Get.arguments['keluar']?['address'] == null
                    ? "Alamat : -"
                    : "Alamat : ${Get.arguments['keluar']!['address']}"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
