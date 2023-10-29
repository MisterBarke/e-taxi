import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class SignalerIncidentController extends GetxController {
  Rxn<XFile> image = Rxn();
  final index = 0.obs;
  final description = TextEditingController().obs;
  final isLoading = false.obs;
  final orderId = "".obs;
  final user = FirebaseAuth.instance.currentUser;
  final userName = "".obs;
  final driverName = "".obs;
  static const uuid = Uuid();
  pickImage() async {
    ImageSource imageSource;
    if (index.value == 1) {
      imageSource = ImageSource.gallery;
    } else {
      imageSource = ImageSource.camera;
    }
    try {
      final galleryImage = await ImagePicker().pickImage(source: imageSource);
      if (galleryImage != null) {
        image.value = XFile(galleryImage.path);
      }
    } on PlatformException catch (e) {
      Fluttertoast.showToast(msg: "${e.message}");
    }
  }

  uploadImageToFirebaseStorage() async {
    isLoading(true);
    final user = FirebaseAuth.instance.currentUser;
    final storageRef = FirebaseStorage.instance;
    final file = File(image.value!.path);
    final imageRef = storageRef.ref(
        "incidents/${"docsIncident"}_${uuid.v4()}.${image.value!.name.split('.').last}");
    try {
      await imageRef.putFile(file);
      final url = await imageRef.getDownloadURL();
      await updateImageToFirestore(url);
      Get.back();
      isLoading(false);
    } on FirebaseException catch (e) {
      isLoading(false);
      Fluttertoast.showToast(msg: "${e.message}");
    }
  }

  updateImageToFirestore(String url) async {
    final data = {
      "userId":user!.uid,
      "orderid": orderId.value,
      "link": url,
      "userName": userName.value,
      "driverName": driverName.value,
      "createdAt": DateTime.now(),
      "updatedAt": DateTime.now(),
      "description": description.value.text,
      "response": "",
      "status": 0
    };
    var collection = FirebaseFirestore.instance.collection('incidents');
    collection.doc(uuid.v4()).set(data).then((value) {
      Fluttertoast.showToast(msg: "Incident envoyé avec succès");
    }, onError: (e) => print(e));
  }

  deleteImage() {
    image.value = null;
  }
}
