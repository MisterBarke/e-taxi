import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kano/business/model/payment_method.dart';
import 'package:kano/ui/screens/order/cancelation.dart';
import 'package:kano/ui/screens/order/ride_screen.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

import '../../../business/controller/order_controller.dart';
import '../../widgets/utils_widgets.dart';
import 'package:kano/translation/translation_keys.dart' as _;

class DriverSearch extends StatefulWidget {
  final dynamic data;

  const DriverSearch({Key? key, this.data}) : super(key: key);

  @override
  State<DriverSearch> createState() => _DriverSearchState();
}

class _DriverSearchState extends State<DriverSearch> {
  final OrderController _orderController = Get.find();

  GoogleMapController? _controller;
  double currentZomValue = 16;
  var currentIndex = 0;

  late List<Widget> pages = [];
  var payment = PaymentMethod.getPaymentMethods()[0];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _orderController.cancelSearch();
        return false;
      },
      child: Scaffold(
        drawer: Container(
          width: Get.width,
          height: Get.height,
          color: Colors.white,
        ),
        body: Builder(
          builder: (context) => SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              fit: StackFit.loose,
              children: [
                SizedBox(
                  height: Get.height - 320,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _orderController.currentLocation.value,
                          zoom: 12.0,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          _controller = controller;
                        },
                        myLocationEnabled: false,
                        mapToolbarEnabled: false,
                        zoomControlsEnabled: false,
                      ),
                      Center(
                        child: RippleAnimation(
                          color: Colors.blue,
                          repeat: true,
                          ripplesCount: 1,
                          child: Image.asset(
                            "assets/images/start_pin.png",
                            width: 40,
                            height: 40,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          child: Container(
                            padding: const EdgeInsets.all(8),
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
                            child: const Icon(Icons.close, size: 17),
                          ),
                          onTap: () {
                            _orderController.cancelSearch();
                          },
                        ),
                        Flexible(
                          child: SizedBox(
                            width: double.maxFinite,
                            child: Text(
                              _.orderDetails.tr,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    height: 400,
                    width: Get.width,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30),
                        topLeft: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(25),
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 15),
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
                                        Radius.circular(
                                          10,
                                        ),
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
                                    SizedBox(
                                      height: 40,
                                      child: TextField(
                                        enabled: false,
                                        decoration: getAddressInputDecoration(
                                          _.chooseDeparture.tr,
                                          background: const Color(
                                            0XFFFFFFFF,
                                          ),
                                        ),
                                        controller: TextEditingController(
                                            text: _orderController
                                                        .currentOrder['depart']
                                                    ['address'] ??
                                                ''),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Divider(height: 1),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      height: 40,
                                      child: TextField(
                                        enabled: false,
                                        decoration: getAddressInputDecoration(
                                          _.chooseDestination.tr,
                                          background: const Color(
                                            0XFFFFFFFF,
                                          ),
                                        ),
                                        controller: TextEditingController(
                                            text: _orderController
                                                    .currentOrder['destination']
                                                ['address']),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            color: Colors.grey.withAlpha(30),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Details du voyage"),
                                  Text(
                                    "${_orderController.ridePrice.value.toStringAsFixed(2)} €",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    "${_orderController.currentOrder['rideEta'] ?? ''} - ",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    "${_orderController.rideDistance.value.toStringAsFixed(2)} KM",
                                    style: const TextStyle(color: Colors.grey),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                              color: Color(0xFFF4F4F4),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Row(
                            children: [
                              Image.asset(
                                  _orderController.currentOrder['payment']
                                              ['type'] ==
                                          'Cash'
                                      ? 'assets/images/ic_cash.png'
                                      : 'assets/images/ic_master.png',
                                  width: 40,
                                  height: 40),
                              const SizedBox(width: 15),
                              Flexible(
                                child: Text(_orderController
                                                .currentOrder['payment']
                                            ['method'] ==
                                        'Cash'
                                    ? 'Cash'
                                    : "*** ${_orderController.currentOrder['payment']['method']}"),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: DefaultButton(
                              text: "Annuler la recherche",
                              onPress: () {
                                _orderController.cancelSearch();
                              }),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
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
    _controller?.moveCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(minLat, minLong),
            northeast: LatLng(maxLat, maxLong)),
        8));
  }

  @override
  void initState() {
    super.initState();
  }
}
