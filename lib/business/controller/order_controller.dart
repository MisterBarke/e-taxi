import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_geocoding/google_geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kano/business/controller/auth_controller.dart';
import 'package:kano/business/model/address.dart';
import 'package:kano/business/service/google_service.dart';
import 'package:kano/business/service/kano_http.dart';
import 'package:kano/business/service/map_service.dart';
import 'package:kano/business/service/order_service.dart';
import 'package:kano/constants.dart';
import 'package:kano/ui/screens/order/ride_screen.dart';
import 'package:uuid/uuid.dart';

import '../../ui/screens/home.dart';
import '../../ui/screens/order/driver_search.dart';

class OrderController extends GetxController {
  final _authController = Get.put(AuthController());
  final isEditing = false.obs;
  final updateOnlyDestinationAddress = false.obs;
  final addressesSearchResult = <String>[].obs;
  PolylinePoints polylinePoints = PolylinePoints();
  var googleGeocoding = GoogleGeocoding(kGoogleApiKey);
  StreamSubscription? subscription;
  final currentAddress = "".obs;
  final currentLocation = const LatLng(0, 0).obs;

  final geocoding = false.obs;
  final departAddress = (Address()).obs;
  final destinationAddress = (Address()).obs;
  final stops = <Address>[].obs;
  final stopsControllers = <TextEditingController>[].obs;
  final usingMap = false.obs;
  final showBottomSheet = true.obs;

  final markers = <Marker>[].obs;
  final homeMarkers = <Marker>[].obs;
  final polylines = <PolylineId, Polyline>{}.obs;
  final firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  final searchingLocation = false.obs;
  final isLoading = false.obs;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? orderSubscription;
  final currentOrder = <String, dynamic>{}.obs;

  var drivers = <dynamic>[].obs;
  final driversMarkers = <Marker>[].obs;

  //due amount
  final dueAmount = 0.0.obs;

  // Ride whole distance
  final rideDistance = 0.0.obs;
  final ridePrice = 0.0.obs;
  final reservationPrice = 0.0.obs;
  final rideEta = "".obs;
  final rideTva = "".obs;
  final ridePriceDriver = "".obs;
  final rideCommission = "".obs;

  var tripDrawed = false.obs;

  var needConfirmation = false.obs;
  final box = GetStorage();

  OrderController() {
    startLocationListener();
  }

  searchAddress(String query) async {
    addressesSearchResult.value = await GoogleService.filterAddress(query);
  }

  addStop() {
    stopsControllers.add(TextEditingController(text: ""));
    stops.add(Address());
  }

  removeStop(int index) {
    stops.removeAt(index);
    usingMap.value = false;
    needConfirmation.value = false;
    buildMarkers();
  }

  void buildMarkers() {
    markers.clear();

    if (departAddress.value.latLng != null) {
      BitmapDescriptor.fromAssetImage(
              const ImageConfiguration(size: Size(300, 300)),
              'assets/images/start_pin.png')
          .then((d) {
        markers.add(
          Marker(
            markerId: const MarkerId("start"),
            position: departAddress.value.latLng!,
            infoWindow: InfoWindow(
              title: departAddress.value.description,
              snippet: 'Départ',
            ),
            icon: d,
          ),
        );
      });
    }

    if (destinationAddress.value.latLng != null) {
      BitmapDescriptor.fromAssetImage(
              const ImageConfiguration(size: Size(300, 300)),
              'assets/images/start_pin.png')
          .then((d) {
        markers.add(
          Marker(
            markerId: const MarkerId("end"),
            position: destinationAddress.value.latLng!,
            infoWindow: InfoWindow(
              title: destinationAddress.value.description!,
              snippet: 'Destination',
            ),
            icon: d,
          ),
        );
      });
    }

    int i = 0;
    for (var address in stops) {
      if (address.latLng != null) {
        BitmapDescriptor.fromAssetImage(
                const ImageConfiguration(size: Size(300, 300)),
                'assets/images/start_pin.png')
            .then((d) {
          markers.add(Marker(
            //add start location marker
            markerId: MarkerId("index_$i"),
            position: address.latLng!, //position of marker
            infoWindow: InfoWindow(
              //popup info
              title: address.description!,
              // snippet: 'Start Marker',
            ),
            icon: d, //Icon for Marker
          ));
          i++;
        });
      }
    }

    buildPolyline();
    tripDrawed.value = true;
  }

  buildPolyline() async {
    List<LatLng> coordinates = [];

    if (departAddress.value.latLng != null) {
      coordinates.add(departAddress.value.latLng!);
    }

    coordinates = [...coordinates, ...stops.map((element) => element.latLng!)];

    if (destinationAddress.value.latLng != null) {
      coordinates = [...coordinates, destinationAddress.value.latLng!];
    }

    if (coordinates.length < 2) return;

    polylines.value = await MapService.buildPolylines(coordinates: coordinates);
    MapService.calculateWholeDistance(coordinates)
        .then((distance) => rideDistance.value = distance);
  }

  startLocationListener() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    searchingLocation.value = true;
    subscription?.cancel();
    subscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((l) {
      final cur = LatLng(l.latitude, l.longitude);
      subscription?.cancel();
      currentLocation.value = cur;
      fetchCurrentAddress();
    });
  }

  fetchCurrentAddress() async {
    final result = await googleGeocoding.geocoding.getReverse(LatLon(
        currentLocation.value.latitude, currentLocation.value.longitude));

    //log("Revese result : ${result?.results?.length}");

    try {
      currentAddress.value = result?.results?.reversed.last.formattedAddress ??
          "${currentLocation.value.latitude},${currentLocation.value.longitude}";
    } catch (e) {
      currentAddress.value =
          "${currentLocation.value.latitude},${currentLocation.value.longitude}";
    }

    searchingLocation.value = false;
    departAddress.value = Address(
      description: currentAddress.value,
      latLng: currentLocation.value,
      name: currentAddress.value,
    );
    buildMarkers();
  }

  void stopSearchingLocation() {
    subscription?.cancel();
    searchingLocation.value = false;
  }

  bool areAllStopsFilled() {
    if (stops.isEmpty) return true;
    return stops[stops.length - 1].latLng != null;
  }

  Future<void> addOrders(dynamic payment,
      {bool isScheduled = false, DateTime? at}) async {
    final user = FirebaseAuth.instance.currentUser;
    final uuid = const Uuid().v1();
    Map<String, dynamic> data = _authController.getUser();
    Map<String, dynamic> orderData = {
      "id": uuid,
      "userId": user!.uid,
      "driverId": "",
      "at": at?.toIso8601String(),
      "scheduled": isScheduled,
      "rideEta": rideEta.value,
      "payment": {
        "type": payment['last4'] == 'Cash' ? 'Cash' : 'Card',
        "method": payment['last4'],
        "price": ridePrice.value.toString(),
        "priceDriver": ridePriceDriver.value,
        "commission": rideCommission.value,
        "tva": rideTva.value,
        "cardId": payment['id']
      },
      "destination": destinationAddress.value.map(),
      "depart": departAddress.value.map(),
      "position": {
        "lat": currentLocation.value.latitude,
        "long": currentLocation.value.longitude,
        "address": ""
      },
      "distance": rideDistance.value.toStringAsFixed(2),
      "userName": "${data["firstname"]} ${data["lastname"]}",
      "createdAt": DateTime.now().toIso8601String(),
      "status": isScheduled ? -3 : 0,
      "stops": [...stops.value.map((e) => e.map())]
    };

    currentOrder.value = orderData;

    return firestore
        .collection("orders")
        .doc(uuid)
        .set(orderData)
        .then((value) {
      return OrderService.notifyOrderToBackend(uuid).then((value) {
        if (value == null) {
          Fluttertoast.showToast(msg: "Erreur ...");
        } else {
          currentOrder.value = orderData;
          GetStorage().write("currentOrder", orderData).then((value) => null);
          subscribeToOrder(uuid);
          Fluttertoast.showToast(
              msg: "Votre commande à été enregistré avec succès !");
        }
      });
    });
  }

  Future<dynamic> getDataFromCalculatePrice() async {
    if (rideDistance.value == 0) {
      await buildPolyline();
    }
    return OrderService.calculatePrice({
      "depart": departAddress.value.map(),
      "destination": destinationAddress.value.map(),
      "position": {
        "long": currentLocation.value.longitude,
        "lat": currentLocation.value.latitude
      },
      "distance": rideDistance.value
    });
  }

  setRideData(dynamic response) {
    rideEta.value = response["eta"].toString();
    ridePriceDriver.value = response["priceDriver"].toString();
    rideTva.value = response["tva"].toString();
    rideCommission.value = response["commission"].toString();
    ridePrice.value = response["price"];
    reservationPrice.value = response["priceReservation"];
  }

  // TcnHMxAAqoWWkwy5vjVpAz04RFr2
  void subscribeToOrder(String uuid) {
    orderSubscription =
        firestore.collection("orders").doc(uuid).snapshots().listen((value) {
      currentOrder.value = value.data()!;
      if (value.get("status") == 1) {
        orderSubscription?.cancel();
        isEditing.value == true
            ? null
            : Fluttertoast.showToast(
                msg: "Votre commande vient d'être prise en charge !");
        Get.off(() => RideScreen(order: currentOrder));
      } else if (value.get("status") == -4) {
        clear();
        Fluttertoast.showToast(
            msg:
                "Votre commande programmé a été acceptée par un chauffeur avec succès !");
        Get.offAll(() => const AppHome());
      }
    });
    //check if ride request collection is empty

    firestore
        .collection("rideRequests")
        .where("id", isEqualTo: currentOrder["id"])
        .snapshots()
        .listen((event) async {
      if (event.docs.isEmpty) {
        var snap =
            await firestore.collection("orders").doc(currentOrder["id"]).get();
        if (snap.data()!["status"] == 0) {
          cancelSearch();
          Fluttertoast.showToast(msg: "Aucun chauffeur trouver");
        }
      }
    });
  }

  cancelOrder(Map<String, dynamic> data) async {
    return await http_post(
        "/api/rides/cancel/${currentOrder.value['id']}", data);
  }

  void clear() {
    polylines.value = <PolylineId, Polyline>{};
    markers.value = <Marker>[];
    homeMarkers.value = <Marker>[];
    departAddress.value = (Address());
    destinationAddress.value = (Address());
    stops.value = <Address>[];

    buildMarkers();
    box.remove("currentOrder");
  }

  fetchDrivers() {
    firestore
        .collection("drivers")
        .where("status", isEqualTo: 1)
        .snapshots()
        .listen((event) {
      log("============================================================");
      log("==================== ${event.docs.length} ==================");
      log("=============================================================");
      _buildDriversMarkers(event.docs);
    });
  }

  Future<void> _buildDriversMarkers(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    List<Marker> mkrs = [];

    for (var value in docs) {
      Map<String, dynamic> driver = value.data();
      dynamic currentPosition = driver['currentPosition'];

      if (currentPosition != null) {
        var lng = currentPosition["longitude"];
        var lat = currentPosition["latitude"];

        if (lng != null && lat != null && driver["id"] != null) {
          var marker = await MapService.buildMarker(
              startAddress: Address(latLng: LatLng(lat, lng)),
              id: driver["id"]);

          mkrs.add(marker);
        }
      }
    }

    // Fluttertoast.showToast(msg: "Markers numbers ${mkrs.length}");
    driversMarkers.value = mkrs;
  }

  updateCurrentRide() {
    final currentOrder = box.read("currentOrder");
    firestore.collection("orders").doc(currentOrder["id"]).update({
      "depart": {
        "address": departAddress.value.name,
        "lat":double.parse (departAddress.value.latLng!.latitude.toString()),
        "long": double.parse(departAddress.value.latLng!.longitude.toString()),
      },
      "distance": rideDistance.value.toStringAsFixed(2),
      "destination": {
        "address": destinationAddress.value.name,
        "lat": double.parse(destinationAddress.value.latLng!.latitude.toString()),
        "long": double.parse(destinationAddress.value.latLng!.longitude.toString()),
      },
    }).then((value) {});
    OrderService.refreshRide(currentOrder["id"]).then((value) {
      if (value["succes"] == true) {
        subscribeToOrder(currentOrder["id"]);
        Fluttertoast.showToast(msg: "Mise à jour effectué avec succès");
      } else {}
    });
    isEditing(false);
  }

  cancelSearch() {
    firestore
        .collection("orders")
        .doc(currentOrder['id'])
        .delete()
        .then((value) {
      firestore
          .collection("rideRequests")
          .where("id", isEqualTo: currentOrder['id'])
          .get()
          .then((value) {
        for (DocumentSnapshot d in value.docs) {
          d.reference.delete();
        }
        clear();
        Get.offAll(() => const AppHome());
      });
    });
  }

//fonction verifier si le user a un credit
  checkUserDueAmount() {
    firestore.collection("users").doc(user!.uid).snapshots().listen((event) {
      if (event.data()!["dueAmount"] != 0) {
        dueAmount.value = double.parse(event.data()!["dueAmount"].toString());
      } else {
        dueAmount.value = 0.0;
      }
    });
  }
}
