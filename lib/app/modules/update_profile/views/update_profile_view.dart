// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/update_profile_controller.dart';

class UpdateProfileView extends GetView<UpdateProfileController> {
  // final Map<String, dynamic> user = Get.arguments;
  const UpdateProfileView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // print(Get.arguments['name']);
    controller.nipC.text = Get.arguments['nip'];
    controller.nameC.text = Get.arguments['name'];
    controller.emailC.text = Get.arguments['email'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('UPDATE PROFILE'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            readOnly: true,
            autocorrect: false,
            controller: controller.nipC,
            decoration: InputDecoration(
              labelText: "NIP",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            readOnly: true,
            autocorrect: false,
            controller: controller.emailC,
            decoration: InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            autocorrect: false,
            controller: controller.nameC,
            decoration: InputDecoration(
              labelText: "Name",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 25),
          Text(
            "Profile",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetBuilder<UpdateProfileController>(
                builder: (c) {
                  if (c.image != null) {
                    return ClipOval(
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Image.file(
                          File(c.image!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  } else {
                    if (Get.arguments['profile'] != null) {
                      return Column(
                        children: [
                          ClipOval(
                            child: SizedBox(
                              height: 100,
                              width: 100,
                              child: Image.network(
                                Get.arguments['profile'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          TextButton(
                              onPressed: () {
                                controller.deleteProfile(Get.arguments['uid']);
                              },
                              child: Text("Delete"))
                        ],
                      );
                    } else {
                      return Text("no image");
                    }
                  }
                },
              ),
              TextButton(
                  onPressed: () {
                    controller.pickImage();
                  },
                  child: Text("Choose"))
            ],
          ),
          SizedBox(height: 30),
          Obx(
            () => ElevatedButton(
                onPressed: () async {
                  if (controller.isLoading.isFalse) {
                    await controller.updateProfile(Get.arguments['uid']);
                  }
                },
                child: Text(controller.isLoading.isFalse
                    ? "UPDATE PROFILE"
                    : "LOADING...")),
          )
        ],
      ),
    );
  }
}
