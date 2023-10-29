import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kano/business/service/google_service.dart';

import '../../ui/onboarding.dart';
import '../model/address.dart';

class ProfileController extends GetxController {
  final addressesSearchResult = <String>[].obs;
  final user = {}.obs;
  final inputText = TextEditingController().obs;
  final isLoading = false.obs;
  final isUpdateLoading = false.obs;
  final updateField = "".obs;
  final updateAddressField = "".obs;
  Address? selected;
  var loadingAddress = false.obs;
  final currentUser = FirebaseAuth.instance.currentUser;
  final box = GetStorage();

  searchAddress(String query) async {
    addressesSearchResult.value = await GoogleService.filterAddress(query);
  }

  geocode(String? address) async {
    isUpdateLoading(true);
    final result = await GoogleService.geocode(address!);
    final data = {
      "address": address,
      "lat": result?.lat,
      "long": result?.lng,
    };
    _updateLocation(data);
    isUpdateLoading(false);
  }

  _updateLocation(dynamic data) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser!.uid)
        .update({updateAddressField.value: data}).then((value) {
      Fluttertoast.showToast(msg: 'Succès');
    }).catchError((error) {
      Fluttertoast.showToast(msg: error);
    });
  }

  getUser() async {
    isLoading(true);
    FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser!.uid)
        .snapshots()
        .listen((event) {
      final data = event.data() as Map<String, dynamic>;
      user.value = data;
    });
    isLoading(false);
  }

  updateUser() async {
    isUpdateLoading(true);
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser!.uid)
        .update({updateField.value: inputText.value.text}).then((value) {
      Fluttertoast.showToast(msg: 'Modification réussie');
    }).catchError((error) {
      Fluttertoast.showToast(msg: error);
    });
    isUpdateLoading(false);
  }

  signOut() {
    FirebaseAuth.instance.signOut();
    box.remove("user");
    Get.offAll(() => Onboarding());
  }
}
