import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kano/business/controller/order_controller.dart';
import 'package:kano/business/model/address.dart';
import 'package:kano/business/service/map_service.dart';
import 'package:kano/ui/screens/order/driver_search.dart';
import 'package:kano/ui/screens/order/receip.dart';
import 'package:kano/ui/screens/order/ride_screen.dart';
import 'package:kano/ui/widgets/bounce_in_bottom_sheet.dart';
import 'package:kano/utils/util.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../ui/screens/home.dart';

class RideController extends GetxController {
  final OrderController _orderController = Get.find();
  final rideNote = 4.0.obs;

  // Addresses
  final rideStartAddress = (Address()).obs;
  final rideEndAddress = (Address()).obs;
  final box = GetStorage();

  // Markers and polylines
  final rideMarkers = <Marker>[].obs;
  final polylines = <PolylineId, Polyline>{}.obs;
  final mode = "owner".obs;

  // Firebase data
  final firestore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? orderSubscription;

  // Current order
  final currentOrder = <String, dynamic>{}.obs;
  final order = <String, dynamic>{}.obs;
  final followedOrder = <String, dynamic>{}.obs;

  // Others controller data
  final initializing = false.obs;
  final driverData = <String, dynamic>{"defined": false, "driver": null}.obs;
  final user = FirebaseAuth.instance.currentUser;
  var oldStatus;
  bool notified = false;

  buildMarkers() async {
    log("Inside buildMarkers method");
    if (rideStartAddress.value.latLng == null ||
        rideEndAddress.value.latLng == null) return;

    log("Building markers ...");
    rideMarkers.clear();

    rideMarkers.value = await MapService.buildStartEndMarkers(
        startAddress: rideStartAddress.value, endAddress: rideEndAddress.value);

    log("Markers lenght ${rideMarkers.length}");

    // Build polylines based on markers number
    polylines.value = await MapService.buildPolylines(
        coordinates: rideMarkers.map((element) => element.position).toList());

    log("Building markers done !");
  }

  _update() {
    // Handled order
    if (currentOrder["status"] == 1) {
      _orderController.updateOnlyDestinationAddress(false);
      // Start address is driver position
      rideStartAddress.value = Address(
          latLng: LatLng(currentOrder['driverPosition']['latitude'],
              currentOrder['driverPosition']['longitude']));

      // End address is customer position
      rideEndAddress.value = Address(
          latLng: LatLng(
              currentOrder["depart"]["lat"], currentOrder["depart"]["long"]));

      buildMarkers();
    }

    if (currentOrder["status"] == 2) {
      _orderController.updateOnlyDestinationAddress(true);
      if (oldStatus != 2) {
        showModalBottomSheet(
          context: Get.context!,
          builder: (BuildContext context) {
            return const BounceInBottomSheet(
                message: "Votre course vient juste de commencé !");
          },
        );
      }

      rideStartAddress.value = Address(
          latLng: LatLng(currentOrder['driverPosition']['latitude'],
              currentOrder['driverPosition']['longitude']));

      // End address is customer position
      rideEndAddress.value = Address(
          latLng: LatLng(currentOrder["destination"]["lat"],
              currentOrder["destination"]["long"]));

      buildMarkers();
    }
  }

  checkCurrentOrder() {
    firestore.collection("users").doc(user!.uid).get().then((event) {
      final data = event.data();
      if (data?["pendingRide"] != null) {
        box.write("currentOrder", {"id": data?["pendingRide"]});
        var currentOrder = box.read("currentOrder");
        firestore
            .collection("orders")
            .doc(currentOrder["id"])
            .snapshots()
            .listen((event) {
          final data = event.data() as Map<String, dynamic>;
          if (data["status"] == 1 ||
              data["status"] == 2 ||
              data['status'] == 0) {
            _orderController.currentOrder.value = data;
            _orderController.subscribeToOrder(data["id"]);
            _orderController.rideDistance.value =
                double.parse(data["distance"]);
            _orderController.ridePrice.value =
                double.parse(data["payment"]["price"].toString());
            if (data['status'] == 0) {
              Future.delayed(const Duration(seconds: 2), () {
                Get.to(() => const DriverSearch());
              });
            } else {
              Future.delayed(const Duration(seconds: 2), () {
                Get.to(() => RideScreen(order: data));
              });
            }
          } else {
            // Fluttertoast.showToast(msg: "Aucune commande en cours !");
            box.remove("currentOrder");
          }
        });
        //check if ride request collection is empty
        firestore
            .collection("rideRequests")
            .where("id", isEqualTo: currentOrder["id"])
            .where("status", isEqualTo: 0)
            .snapshots()
            .listen((event) async {
          if (event.docs.isEmpty) {
            var snap = await firestore
                .collection("orders")
                .doc(currentOrder["id"])
                .get();
            if (snap.data()!["status"] == 0) {
              _orderController.cancelSearch();
              Fluttertoast.showToast(msg: "Aucun chauffeur trouver");
            }
          }
        });
      }
    });
  }

  handleOrder({required Map<String, dynamic> order, mode = "owner"}) async {
    this.mode.value = mode;
    initializing.value = true;
    notified = false;

    orderSubscription = firestore
        .collection("orders")
        .doc(order["id"])
        .snapshots()
        .listen((value) {
      oldStatus = currentOrder["status"] ?? -100;
      initializing.value = false;
      currentOrder.value = value.data()!;
      _update();
      if (currentOrder['status'] == 1 &&
          currentOrder['rideDetails']['toTravelDistance'] <= 100 &&
          !notified) {
        notified = true;
        FlutterRingtonePlayer.play(
          fromAsset: "assets/audio/announcement.mp3",
          ios: IosSounds.glass,
          looping: false,
          // Android only - API >= 28
          volume: 0.1,
          // Android only - API >= 28
          asAlarm: false, // Android only - all APIs
        );

        showSnackBar(mode == 'follower'
            ? 'Driver arrivé !'
            : 'Votre driver est arrivé !');
      }
      box.write("currentOrder", currentOrder);

      if (currentOrder['status'] == 4) {
        orderSubscription?.cancel();
        if (mode == 'owner') {
          Get.off(() => Receipt());
        } else {
          Future.delayed(const Duration(seconds: 1), () {
            showSnackBar("Course terminée !");
          });
          Get.offAll(() {
            return const AppHome();
          });
        }
      }
      if (currentOrder['status'] == 3) {
        Future.delayed(const Duration(seconds: 1), () {
          showSnackBar("Le paiement a échoué !");
        });
      }
      if (currentOrder['status'] == -1 || currentOrder['status'] == -2) {
        orderSubscription?.cancel();
        Future.delayed(const Duration(seconds: 1), () {
          showSnackBar("Course annulé !");
        });
        Get.offAll(() {
          return const AppHome();
        });
      }
    });

    final driver =
        (await firestore.collection("drivers").doc(order["driverId"]).get())
            .data();
    if (driver != null) {
      driverData.value = {"defined": true, "driver": driver};
    }
  }

  sendSms() {
    if (driverData['defined']) {
      Uri sms = Uri.parse("sms:${driverData['driver']['phone']}");
      launchUrl(sms);
    }
  }

  callDriver() {
    if (driverData['defined']) {
      Uri sms = Uri.parse("tel:${driverData['driver']['phone']}");
      launchUrl(sms);
    }
  }

  void handleNote() {
    firestore
        .collection("orders")
        .doc(currentOrder['id'])
        .update({"note": rideNote.value});
    box.remove("currentOrder");
    Get.offAll(() {
      return const AppHome();
    });
  }

  void follow(String orderUUID) {
    firestore.collection("orders").doc(orderUUID).get().then((value) {
      final data = value.data();
      if (data != null) {
        _orderController.currentOrder.value = data;
        Get.to(() => RideScreen(order: data, mode: "follower"));
      } else {
        Fluttertoast.showToast(msg: "Commande introuvable !");
      }
    });
  }
}
