import 'dart:async';
import 'dart:developer';
import 'package:app_links/app_links.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kano/business/controller/driver_controller.dart';
import 'package:kano/business/controller/payment_controller.dart';
import 'package:kano/business/controller/ride_controller.dart';
import 'package:kano/translation/translation_keys.dart' as translation;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kano/business/controller/app_controller.dart';
import 'package:kano/business/controller/order_controller.dart';
import 'package:kano/ui/screens/address_picker.dart';
import 'package:kano/ui/screens/menu/my_history.dart';
import 'package:kano/ui/screens/notifications/notifications.dart';
import 'package:kano/ui/screens/order/order_details.dart';
import 'package:upgrader/upgrader.dart';

import '../../business/controller/auth_controller.dart';
import '../widgets/app_drawer.dart';
import '../widgets/utils_widgets.dart';

class AppHome extends StatefulWidget {
  const AppHome({Key? key}) : super(key: key);

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  final AuthController _authController = Get.put(AuthController());
  final OrderController _orderController = Get.put(OrderController());
  final RideController _rideController = Get.put(RideController());
  final AppController _appController = Get.put(AppController());
  final PaymentController _paymentController = Get.put(PaymentController());

  GoogleMapController? _controller;
  StreamSubscription? subscription;
  double currentZomValue = 20;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent, // navigation bar color
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark));

    return Obx(
      () {
        if (_orderController.currentLocation.value.latitude != 0) {
          _controller?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: _orderController.currentLocation.value,
                zoom: 10,
              ),
            ),
          );
        }

        List<Marker> markers = _orderController.driversMarkers.value;
        markers.add(Marker(
            markerId: const MarkerId("userLocation"),
            position: _orderController.currentLocation.value,
            infoWindow: const InfoWindow(title: "Votre position"),
            icon: BitmapDescriptor.defaultMarkerWithHue(10)));

        return UpgradeAlert(
          upgrader: Upgrader(),
          child: Scaffold(
            appBar: null,
            drawer: Container(
              width: Get.width,
              height: Get.height,
              color: Colors.white,
              child: AppDrawer(),
            ),
            body: Builder(
              builder: (context) => Container(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  fit: StackFit.loose,
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        //innital position in map
                        target: _orderController.currentLocation.value,
                        //initial position
                        zoom: 10.0, //initial zoom level
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _controller = controller;
                        initLocation();
                      },
                      myLocationEnabled: false,
                      mapToolbarEnabled: false,
                      markers: markers.toSet(),
                      zoomControlsEnabled: false,
                      compassEnabled: true,
                    ),
                    //drawermenu and notification menu widget
                    SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 10, top: 5),
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50))),
                            child: InkWell(
                              onTap: () {
                                Scaffold.of(context).openDrawer();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(100)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 3,
                                      blurRadius: 2,
                                    )
                                  ],
                                ),
                                child: Image.asset(
                                  "assets/images/ic_menu.png",
                                  height: 32,
                                  width: 32,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 10, top: 5),
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50))),
                            child: InkWell(
                              onTap: () {
                                Get.to(
                                  () => Notifications(),
                                  fullscreenDialog: true,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(100)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 3,
                                        blurRadius: 2,
                                      )
                                    ]),
                                child: Image.asset(
                                    "assets/images/notification.png",
                                    height: 32,
                                    width: 32),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //address chooser widget
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.14,
                      left: 10,
                      width: Get.width - 20,
                      child: _buildAddressChooser(),
                    ),
                    //usually address widget
                    Obx(
                      () {
                        return _orderController
                                        .destinationAddress.value.latLng ==
                                    null &&
                                _orderController.dueAmount.value > 0
                            ? Positioned(
                                bottom: 30,
                                right: 15,
                                left: 15,
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.16,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.red,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        "Vous avez un paiement en attente de ${_orderController.dueAmount.value}€. Merci de mettre à jour vos moyens de paiement et ressayer !",
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Get.to(() => HistoryPage());
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                            Colors.white,
                                          ),
                                        ),
                                        child: const Text(
                                          "Payer mon crédit",
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : _appController.address.isEmpty
                                ? Container()
                                : Positioned(
                                    bottom: 30,
                                    right: 5,
                                    left: 5,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const SizedBox(width: 30),
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                if (_appController.address[0]
                                                        ["location"] !=
                                                    null) {
                                                  Get.to(
                                                    () => const AddressPicker(),
                                                    arguments: {
                                                      "address": _appController
                                                              .address[0]
                                                          ["location"]
                                                    },
                                                  );
                                                } else {
                                                  Fluttertoast.showToast(
                                                      msg: "Aucune adresse");
                                                }
                                              },
                                              child: Container(
                                                height: 65,
                                                width: 65,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: _appController.address[0]
                                                    ["icon"] as Icon,
                                              ),
                                            ),
                                            Text(
                                              _appController.address[0]["name"],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(width: 30),
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                if (_appController.address[1]
                                                        ["location"] !=
                                                    null) {
                                                  Get.to(
                                                    () => const AddressPicker(),
                                                    arguments: {
                                                      "address": _appController
                                                              .address[1]
                                                          ["location"]
                                                    },
                                                  );
                                                } else {
                                                  Fluttertoast.showToast(
                                                      msg: "Aucune adresse");
                                                }
                                              },
                                              child: Container(
                                                height: 65,
                                                width: 65,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: _appController.address[1]
                                                    ["icon"] as Icon,
                                              ),
                                            ),
                                            Text(
                                              _appController.address[1]["name"],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(width: 30),
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                if (_appController.address[2]
                                                        ["location"] !=
                                                    null) {
                                                  Get.to(
                                                    () => const AddressPicker(),
                                                    arguments: {
                                                      "address": _appController
                                                              .address[2]
                                                          ["location"]
                                                    },
                                                  );
                                                } else {
                                                  Fluttertoast.showToast(
                                                      msg: "Aucune adresse");
                                                }
                                              },
                                              child: Container(
                                                height: 65,
                                                width: 65,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: _appController.address[2]
                                                    ["icon"] as Icon,
                                              ),
                                            ),
                                            Text(
                                              _appController.address[2]["name"],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(width: 30),
                                      ],
                                    ),
                                  );
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void initLocation() {}

  void _setMapFitToTour(Set<Polyline> p) async {
    if (p.isEmpty) return;
    if (p.first.points.isEmpty) return;

    double minLat = p.first.points.first.latitude;
    double minLong = p.first.points.first.longitude;
    double maxLat = p.first.points.first.latitude;
    double maxLong = p.first.points.first.longitude;

    for (var poly in p) {
      for (var point in poly.points) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLong) minLong = point.longitude;
        if (point.longitude > maxLong) maxLong = point.longitude;
      }
    }
    _controller?.moveCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(minLat, minLong),
            northeast: LatLng(maxLat, maxLong)),
        30));
  }

  _buildAddressChooser() {
    return Obx(
      () => Container(
        width: double.infinity,
        padding:
            const EdgeInsets.only(top: 15, left: 10, bottom: 10, right: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 2,
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 15),
                      height: 8,
                      width: 8,
                      decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 50,
                      width: 5,
                      decoration: const BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                    const Icon(Icons.arrow_drop_down)
                  ],
                ),
                const SizedBox(width: 10),
                Flexible(
                  flex: 1,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 35,
                        child: InkWell(
                          child: TextField(
                            enabled: false,
                            decoration: getAddressInputDecoration(
                                translation.chooseDeparture.tr,
                                background: Colors.white),
                            controller: TextEditingController(
                                text: _orderController
                                        .departAddress.value.description ??
                                    ""),
                          ),
                          onTap: () {
                            Get.to(() {
                              return AddressPicker();
                            });
                          },
                        ),
                      ),
                      buildWidget(() {
                        return _orderController.searchingLocation.isTrue
                            ? const LinearProgressIndicator()
                            : Container();
                      }),
                      const SizedBox(height: 5),
                      const Divider(),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Flexible(
                            child: SizedBox(
                              height: 35,
                              child: InkWell(
                                child: TextField(
                                  enabled: false,
                                  decoration: getAddressInputDecoration(
                                    translation.chooseDestination.tr,
                                    background: Colors.white,
                                  ),
                                  controller: TextEditingController(
                                    text: _orderController
                                        .destinationAddress.value.description,
                                  ),
                                ),
                                onTap: () {
                                  Get.to(() {
                                    return const AddressPicker();
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    _orderController.fetchDrivers();
    _orderController.checkUserDueAmount();
    _rideController.checkCurrentOrder();
    _appController.getUserAddress();

    final appLinks = AppLinks();

    appLinks.allUriLinkStream.listen((uri) {
      _rideController.follow(uri.toString().split("/").last);
    });

    super.initState();
  }
}
