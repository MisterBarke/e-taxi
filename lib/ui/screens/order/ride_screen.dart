import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kano/business/controller/ride_controller.dart';
import 'package:kano/ui/screens/address_picker.dart';
import 'package:kano/ui/screens/order/cancelation.dart';
import 'package:kano/ui/widgets/utils_widgets.dart';
import 'package:share_plus/share_plus.dart';

import '../../../business/controller/order_controller.dart';
import '../../widgets/app_drawer.dart';
import 'on_trip.dart';
import 'package:kano/translation/translation_keys.dart' as _;

class RideScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  String mode = "owner";

  RideScreen({Key? key, required this.order, this.mode = "owner"})
      : super(key: key);

  @override
  State<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> {
  final _orderController = Get.put(OrderController());
  final _rideController = Get.put(RideController());

  GoogleMapController? _controller;
  double currentZomValue = 16;
  var currentIndex = 0;

  late final PageController _pageViewController;

  late List<Widget> pages = [];

  bool driverArrived = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        // navigation bar color
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        drawer: Container(
          height: Get.height,
          width: Get.width,
          color: Colors.white,
          child: AppDrawer(),
        ),
        body: Obx(
          () {
            final polySet = Set<Polyline>.of(_rideController.polylines.values);
            _setMapFitToTour(polySet);
            return Builder(
              builder: (context) => Stack(
                fit: StackFit.loose,
                children: [
                  SizedBox(
                    height: Get.height * 0.78,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _orderController.currentLocation.value,
                        zoom: 12.0, //initial zoom level
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _controller = controller;
                      },
                      myLocationEnabled: false,
                      mapToolbarEnabled: false,
                      zoomControlsEnabled: false,
                      markers: _rideController.rideMarkers.toSet(),
                      polylines: polySet,
                      onCameraIdle: () {},
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
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
                                onTap: () {
                                  Scaffold.of(context).openDrawer();
                                },
                              ),
                              Flexible(
                                child: SizedBox(
                                  width: double.maxFinite,
                                  child: Text(
                                    _rideController.currentOrder["status"] == 1
                                        ? "${_rideController.mode.value == 'owner' ? 'Votre' : 'Le'} chauffeur arrive"
                                        : "Trajet en cours",
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildDraggableSheet(),
                  Positioned(
                    bottom: 0,
                    child: Column(
                      children: [
                        Container(
                          width: Get.width,
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                _rideController.mode.value == 'owner'
                                    ? MainAxisAlignment.spaceAround
                                    : MainAxisAlignment.spaceAround,
                            children: [
                              InkWell(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 4,
                                          blurRadius: 10,
                                        ),
                                      ],
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(100))),
                                  child: Image.asset(
                                    "assets/images/ic_call.png",
                                    height: 30,
                                    width: 30,
                                  ),
                                ),
                                onTap: () {
                                  _rideController.callDriver();
                                },
                              ),
                              InkWell(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 4,
                                          blurRadius: 10,
                                        ),
                                      ],
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(100))),
                                  child: Image.asset(
                                    "assets/images/ic_chat.png",
                                    height: 30,
                                    width: 30,
                                  ),
                                ),
                                onTap: () {
                                  _rideController.sendSms();
                                },
                              ),
                              if (_rideController.mode.value == 'follower')
                                InkWell(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            spreadRadius: 4,
                                            blurRadius: 10,
                                          ),
                                        ],
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(100))),
                                    child: Image.asset(
                                      "assets/images/ic_close.png",
                                      height: 30,
                                      width: 30,
                                    ),
                                  ),
                                  onTap: () {
                                    Get.back();
                                  },
                                ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    _rideController.handleOrder(order: widget.order, mode: widget.mode);
    super.initState();
  }

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
    _controller?.moveCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(minLat, minLong),
            northeast: LatLng(maxLat, maxLong)),
        60,
      ),
    );
  }

  _buildDraggableSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.25,
      maxChildSize: widget.mode == "follower"
          ? 0.5
          : widget.order["status"] == 1
              ? 0.77
              : 0.7,
      snap: true,
      builder: (BuildContext context, scrollSheetController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollSheetController,
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Center(child: buildDragger()),
                const SizedBox(height: 10),
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 50,
                          width: 50,
                          child: _rideController.driverData["driver"] != null &&
                                  _rideController.driverData["driver"]
                                          ["docsPhoto"] !=
                                      null
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      _rideController.driverData["driver"]
                                          ?["docsPhoto"]?["link"]),
                                )
                              : Image.asset(
                                  "assets/images/default_avatar.png",
                                  width: 130,
                                  height: 130,
                                ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.order["driver"]["firstName"]} ${widget.order["driver"]["lastName"]}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "${_rideController.currentOrder["payment"]?["price"] ?? 0} €",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                ),
                                child: Text(
                                  _rideController.driverData["driver"]
                                          ?["docsCarteGrise"]?["numeropiece"] ??
                                      '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _rideController.driverData["driver"]
                                            ?["docsCarteGrise"]
                                        ?["marqueVehicule"] ??
                                    '',
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Obx(
                  () {
                    final distance = formatDistance(
                        travelDistance: _rideController
                            .currentOrder["rideDetails"]?["toTravelDistance"]);
                    var text =
                        "${_rideController.mode.value == 'owner' ? 'Votre' : 'Le'} "
                        "chauffeur est à $distance ,"
                        " arrive dans ${_rideController.currentOrder["rideDetails"]?["eta"] ?? 0} ";
                    if (_rideController.currentOrder["status"] == 2) {
                      text = "La destination est à $distance ,"
                          " dans ${_rideController.currentOrder["rideDetails"]?["eta"] ?? 0}";
                    }
                    return Container(
                      // padding: EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: Text(
                        text,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
                Obx(
                  () {
                    return Column(
                      children: [
                        Container(
                          height: widget.mode == "follower"
                              ? MediaQuery.of(context).size.height * 0.35
                              : MediaQuery.of(context).size.height * 0.55,
                          width: Get.width,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(15),
                              topLeft: Radius.circular(15),
                            ),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.fromLTRB(5, 8, 8, 0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(top: 15),
                                          height: 8,
                                          width: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(50),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Container(
                                          height: 50,
                                          width: 5,
                                          decoration: const BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.arrow_drop_down)
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      flex: 1,
                                      child: Column(
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 40,
                                                child: TextField(
                                                  enabled: false,
                                                  decoration:
                                                      getAddressInputDecoration(
                                                    _.chooseDeparture.tr,
                                                    background: const Color(
                                                      0XFFFFFFFF,
                                                    ),
                                                  ),
                                                  controller:
                                                      TextEditingController(
                                                          text: widget.order[
                                                                  "depart"]
                                                              ?["address"]),
                                                ),
                                              ),
                                              _rideController.currentOrder[
                                                              "status"] ==
                                                          1 &&
                                                      _rideController
                                                              .mode.value ==
                                                          'owner'
                                                  ? TextButton(
                                                      onPressed: () {
                                                        _orderController
                                                            .isEditing(true);
                                                        Get.to(() =>
                                                            const AddressPicker());
                                                      },
                                                      style: ButtonStyle(
                                                        padding:
                                                            MaterialStateProperty.all(
                                                                const EdgeInsets
                                                                    .all(5)),
                                                      ),
                                                      child: const Text(
                                                        "Changer le lieu de prise.",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          const Divider(height: 1),
                                          const SizedBox(height: 5),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 40,
                                                child: TextField(
                                                  enabled: false,
                                                  decoration:
                                                      getAddressInputDecoration(
                                                          _.chooseDestination
                                                              .tr,
                                                          background:
                                                              const Color(
                                                                  0XFFFFFFFF)),
                                                  controller:
                                                      TextEditingController(
                                                          text: widget.order[
                                                                  "destination"]
                                                              ?["address"]),
                                                ),
                                              ),
                                              _rideController.mode.value ==
                                                          'owner' &&
                                                      widget.order["status"] <=
                                                          2
                                                  ? TextButton(
                                                      onPressed: () {
                                                        _orderController
                                                            .isEditing(true);
                                                        Get.to(() =>
                                                            AddressPicker());
                                                      },
                                                      style: ButtonStyle(
                                                        padding:
                                                            MaterialStateProperty
                                                                .all(
                                                          const EdgeInsets.all(
                                                              5),
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        "Changer la destination",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    )
                                                  : Container(),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF4F4F4),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                child: Row(
                                  children: [
                                    widget.order["payment"]?["method"] == "Cash"
                                        ? Image.asset(
                                            "assets/images/ic_cash.png",
                                            width: 40,
                                            height: 40,
                                          )
                                        : Image.asset(
                                            "assets/images/ic_card.png",
                                            width: 30,
                                            height: 30,
                                          ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: widget.order["payment"]
                                                  ?["method"] ==
                                              "Cash"
                                          ? const Text("Cash")
                                          : Text(
                                              "****${widget.order["payment"]?["method"]}"),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              (_rideController.mode.value == 'owner'
                                  ? SizedBox(
                                      height: 40,
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          _handleShare();
                                        },
                                        style: const ButtonStyle(
                                          elevation:
                                              MaterialStatePropertyAll(1),
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                            Color(0xFFF4F4F4),
                                          ),
                                        ),
                                        icon: const Icon(Icons.share,
                                            color: Colors.black),
                                        label: const Text(
                                          "Partager ma position",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    )
                                  : Container()),
                              const SizedBox(height: 10),
                              (_rideController.mode.value == 'owner'
                                  ? SizedBox(
                                      height: 40,
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Get.to(() => Cancelation());
                                        },
                                        style: const ButtonStyle(
                                          elevation:
                                              MaterialStatePropertyAll(1),
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                            Colors.red,
                                          ),
                                        ),
                                        child: const Text(
                                          "Annuler",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container()),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  _showDriverArrived() {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(0),
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30))),
        child: Row(
          children: [
            Container(
              height: 10,
              width: 10,
              decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
            ),
            const SizedBox(width: 10),
            const Text("Votre taxi est arrivé !")
          ],
        ),
      ),
      onTap: () {},
    );
  }

  void _handleShare() {
    Share.share(
        "https://kano.dickode.net/listen-to/${_rideController.currentOrder['id']}");
  }

  String formatDistance({double travelDistance = 0.0}) {
    String? distance;
    if (travelDistance > 50 && travelDistance < 1000) {
      distance = "$travelDistance m";
    } else if (travelDistance > 1000) {
      var toTravelDistance = travelDistance / 1000;
      distance = "${toTravelDistance.toStringAsFixed(1)} km";
    } else {
      distance = "moins de 50 m";
    }
    return distance;
  }
}
