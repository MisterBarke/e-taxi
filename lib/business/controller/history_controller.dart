import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kano/business/service/map_service.dart';
import 'package:kano/constants.dart';

class HistoryController extends GetxController {
  final selected = 1.obs;
  final orders = [].obs;
  final detail = {}.obs;
  final driver = {}.obs;
  final markers = <Marker>[].obs;
  final isLoading = false.obs;
  final isLoadingDetails = false.obs;
  final isLoadingDriver = false.obs;
  final orderId = ''.obs;
  final user = FirebaseAuth.instance.currentUser;
  final polylines = <PolylineId, Polyline>{}.obs;

  getOrders() async {
    isLoading.value = true;
    FirebaseFirestore.instance
        .collection("orders")
        .orderBy(selected.value == 2 ? "at" : "acceptedAt",
            descending: selected.value == 2 ? false : true)
        .where("userId", isEqualTo: user!.uid)
        .where(
          "status",
          whereIn: selected.value == 2 ? [-4] : [-2, -1, 1, 2, 3, 4],
        )
        .snapshots()
        .listen((querySnapshot) {
      orders.value = [];
      for (var docSnapshot in querySnapshot.docs) {
        final data = docSnapshot.data();
        orders.add(data);
      }

      isLoading.value = false;
    });
  }

  getDetails() async {
    isLoadingDetails.value = true;
    FirebaseFirestore.instance
        .collection("orders")
        .doc(orderId.value)
        .snapshots()
        .listen((querySnapshot) async {
      final data = querySnapshot.data() as Map<String, dynamic>;
      detail.value = data;
      buildMarker();
      if (selected.value == 1) {
        await _getDriver();
      }
      isLoadingDetails.value = false;
    });
  }

  buildMarker() async {
    markers.clear();
    await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(300, 300)),
            'assets/images/start_pin.png')
        .then((d) {
      markers.add(
        Marker(
          markerId: const MarkerId("Départ"),
          position: LatLng(detail["depart"]["lat"], detail["depart"]["long"]),
          infoWindow: InfoWindow(
            title: detail["depart"]["address"],
            snippet: 'Départ',
          ),
          icon: d,
        ),
      );
    });
    await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(300, 300)),
            'assets/images/start_pin.png')
        .then((d) {
      markers.add(
        Marker(
          markerId: const MarkerId("Destination"),
          position: LatLng(
              detail["destination"]["lat"], detail["destination"]["long"]),
          infoWindow: InfoWindow(
            title: detail["destination"]["address"],
            snippet: 'Destination',
          ),
          icon: d,
        ),
      );
    });
    buildPolyline();
  }

  _getDriver() {
    isLoadingDriver(true);
    FirebaseFirestore.instance
        .collection("drivers")
        .doc(detail["driverId"])
        .snapshots()
        .listen((querySnapshot) {
      final data = querySnapshot.data() as Map<String, dynamic>;
      driver.value = data;
      isLoadingDriver(false);
    });
  }

  buildPolyline() async {
    polylines.value = await MapService.buildPolylines(
      coordinates: [
        LatLng(detail["depart"]["lat"], detail["depart"]["long"]),
        LatLng(detail["destination"]["lat"], detail["destination"]["long"]),
      ],
    );
  }

  cancelScheduledOrder({required String orderId}) {
    FirebaseFirestore.instance
        .collection("orders")
        .doc(orderId)
        .update({"status": -1}).then((value) {
      Fluttertoast.showToast(msg: "Course programmé annulée avec succès");
      Get.back();
    });
  }
}
