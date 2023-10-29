import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kano/business/controller/payment_controller.dart';
import 'package:kano/business/model/payment_method.dart';
import 'package:kano/business/service/order_service.dart';
import 'package:kano/constants.dart';
import 'package:kano/ui/screens/home.dart';

import '../../../business/controller/order_controller.dart';
import 'package:kano/translation/translation_keys.dart' as _;

import '../../widgets/utils_widgets.dart';
import '../menu/my_history.dart';
import 'driver_search.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({Key? key}) : super(key: key);

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  final OrderController _orderController = Get.find();
  final PaymentController _paymentController = Get.find();
  GoogleMapController? _controller;
  StreamSubscription? subscription;
  double currentZomValue = 16;
  var currentIndex = 0;
  PageController? _pageViewController;
  late List<Widget> pages = [];
  dynamic defaultPayment = {'last4': 'Cash'};

  var calulatingPrice = true;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final polySet = Set<Polyline>.of(_orderController.polylines.values);
        _setMapFitToTour(polySet);

        return Scaffold(
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
                  Column(
                    children: [
                      Expanded(
                        flex: currentIndex == 0 ? 5 : 5,
                        child: GoogleMap(
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(12.3917911, -1.4806899),
                            zoom: 12.0, //initial zoom level
                          ),
                          onMapCreated: (GoogleMapController controller) {
                            _controller = controller;
                          },
                          myLocationEnabled: false,
                          mapToolbarEnabled: false,
                          markers: _orderController.markers
                              .map((element) => element)
                              .toSet(),
                          polylines: polySet,
                          zoomControlsEnabled: false,
                        ),
                      ),
                      buildWidget(() {
                        return calulatingPrice
                            ? Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 10),
                                child: Center(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const [
                                    SpinKitThreeBounce(
                                      color: Colors.blue,
                                      size: 40,
                                    ),
                                    Text("Chargement ...")
                                  ],
                                )),
                              )
                            : Expanded(
                                flex: currentIndex == 0 ? 5 : 5,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(30),
                                      topLeft: Radius.circular(30),
                                    ),
                                  ),
                                  width: double.maxFinite,
                                  child: PageView.builder(
                                    itemBuilder: (_, index) {
                                      return pages[index];
                                    },
                                    itemCount: pages.length,
                                    controller: _pageViewController,
                                    onPageChanged: (i) {
                                      setState(() {
                                        currentIndex = i;
                                      });
                                    },
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                  ),
                                ),
                              );
                      })
                    ],
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                  child: const Icon(
                                      Icons.arrow_back_ios_new_outlined,
                                      size: 17),
                                ),
                                onTap: () {
                                  Get.back();
                                },
                              ),
                              Flexible(
                                child: SizedBox(
                                  width: double.maxFinite,
                                  child: Text(
                                    currentIndex == 0
                                        ? _.orderDetails.tr
                                        : _.paymentMethods,
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
        50));
  }

  Widget _buildOrderDetails() {
    return Obx(
      () => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 3,
                  blurRadius: 2,
                )
              ],
              borderRadius: const BorderRadius.all(Radius.circular(25)),
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
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: _orderController.stops.isEmpty
                          ? 35
                          : 35 + (_orderController.stops.length * 35),
                      width: 3,
                      decoration: const BoxDecoration(
                          color: Colors.black,
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
                        child: TextField(
                          enabled: false,
                          decoration: getAddressInputDecoration(
                              _.chooseDeparture.tr,
                              background: const Color(0XFFFAFAFA)),
                          controller: TextEditingController(
                              text: _orderController
                                      .departAddress.value.description ??
                                  ""),
                        ),
                      ),
                      const SizedBox(height: 10),
                      buildWidget(() {
                        List<Widget> list = [];
                        for (int i = 0;
                            i < _orderController.stops.length;
                            i++) {
                          list.add(
                            SizedBox(
                              height: 35,
                              child: TextField(
                                enabled: false,
                                decoration: getAddressInputDecoration(
                                    _.clickToChooseAddress.tr,
                                    background: const Color(0XFFFAFAFA)),
                                controller: TextEditingController(
                                    text:
                                        _orderController.stops[i].description),
                              ),
                            ),
                          );
                          if (i != _orderController.stops.length - 1) {
                            list.add(const SizedBox(height: 10));
                          }
                        }

                        return Column(
                          children: list,
                        );
                      }),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 35,
                        child: TextField(
                          enabled: false,
                          decoration: getAddressInputDecoration(
                              _.chooseDestination.tr,
                              background: const Color(0XFFFAFAFA)),
                          controller: TextEditingController(
                              text: _orderController
                                  .destinationAddress.value.description),
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 4,
                )
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                      defaultPayment['last4'] == 'Cash'
                          ? "assets/images/ic_cash.png"
                          : (defaultPayment['brand'] == 'Visa'
                              ? 'assets/images/ic_visa.png'
                              : 'assets/images/ic_master.png'),
                      width: 40,
                      height: 40),
                  const SizedBox(width: 15),
                  Flexible(
                    flex: 1,
                    child: Text(
                        defaultPayment['last4'] == 'Cash'
                            ? 'Cash'
                            : '*** ${defaultPayment['last4']}',
                        overflow: TextOverflow.ellipsis),
                  ),
                  SizedBox(width: Get.width - 260),
                  Row(
                    children: [
                      const Text("Changer"),
                      const SizedBox(width: 10),
                      GestureDetector(
                        child: const Icon(Icons.arrow_drop_down),
                        onTap: () {
                          _pageViewController?.animateToPage(1,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.fastLinearToSlowEaseIn);
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: Colors.grey.withAlpha(30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Details du voyage"),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "${_orderController.rideEta} - ",
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
          _orderController.dueAmount.value <= 0
              ? Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: InkWell(
                        child: Container(
                          height: 40,
                          decoration: const BoxDecoration(
                            color: colorBlue,
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Continuer",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                color: Colors.white,
                                width: 1,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                              ),
                              Text(
                                  "€${_orderController.ridePrice.value.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16))
                            ],
                          ),
                        ),
                        onTap: () {
                          _startCheckout();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      child: Container(
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.alarm, color: Colors.white),
                            Container(
                                color: Colors.white,
                                width: 1,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10)),
                            Text(
                              "€${_orderController.reservationPrice.value.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          ],
                        ),
                      ),
                      onTap: () {
                        DatePicker.showDateTimePicker(
                          context,
                          showTitleActions: true,
                          minTime: DateTime.now(),
                          onChanged: (date) {
                            print(
                                'change $date in time zone ${date.timeZoneOffset.inHours}');
                          },
                          onConfirm: (date) {
                            _startCheckout(isScheduled: true, at: date);
                          },
                          locale: LocaleType.fr,
                        );
                      },
                    )
                  ],
                )
              : InkWell(
                  child: Container(
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Payer mon credit de ",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        Text(
                          "€${_orderController.dueAmount}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    Get.to(() => HistoryPage());
                  },
                )
        ],
      ),
    );
  }

  @override
  void initState() {
    setState(() {
      pages = [
        Container(
          child: _buildOrderDetails(),
        ),
        Container(
          child: _buildPaymentChooser(),
        ),
        Container(
          child: _buildCheckout(),
        ),
        Container(
          child: _buildLoading(),
        ),
      ];
    });

    _pageViewController = PageController(initialPage: currentIndex);
    super.initState();
    _orderController.checkUserDueAmount();
    _orderController.getDataFromCalculatePrice().then((value) {
      if (value != null) {
        _orderController.setRideData(value);
        setState(() {
          calulatingPrice = false;
        });
      } else {
        Fluttertoast.showToast(
          msg: "Oups une erreur est survenu lors du calcul du prix du trajet",
        );
      }
    });
  }

  _buildPaymentChooser() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 20, 20, 0),
          child: Row(
            children: const [
              Text(
                "Mode de paiement",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Icon(Icons.add)
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Obx(() {
            final items = [
              {'last4': 'Cash'},
              ..._paymentController.paymentMethods
            ];

            return ListView.separated(
                itemBuilder: (context, index) {
                  final item = items[index];

                  return InkWell(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 3,
                              blurRadius: 2,
                            )
                          ],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: Row(
                        children: [
                          Image.asset(
                              item['last4'] == 'Cash'
                                  ? 'assets/images/ic_cash.png'
                                  : (item['brand'] == 'Visa'
                                      ? 'assets/images/ic_visa.png'
                                      : 'assets/images/ic_master.png'),
                              width: 40,
                              height: 40),
                          const SizedBox(width: 15),
                          Flexible(
                            child: Text(item['last4'] == 'Cash'
                                ? 'Cash'
                                : '*** ${item['last4']}'),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        defaultPayment = item;
                      });

                      _pageViewController?.animateToPage(0,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInBack);
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 15);
                },
                itemCount: items.length,
                padding: const EdgeInsets.all(20));
          }),
        ),
      ],
    );
  }

  _buildLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        SpinKitThreeBounce(
          color: Colors.blue,
          size: 40,
        ),
        SizedBox(height: 20),
        Text("Chargement ...", style: TextStyle(fontSize: 18)),
      ],
    );
  }

  _buildCheckout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Text("Coût de la course",
            style: TextStyle(color: Colors.black, fontSize: 30)),
        SizedBox(height: 10),
        Text("22 €",
            style: TextStyle(
                color: Colors.blue, fontSize: 25, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _startCheckout({bool isScheduled = false, DateTime? at}) {
    try {
      _pageViewController?.animateToPage(3,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastLinearToSlowEaseIn);

      _orderController
          .addOrders(defaultPayment, isScheduled: isScheduled, at: at)
          .then((value) {
        //if(!isScheduled){
        if (true == true) {
          Get.to(() {
            return const DriverSearch();
          });

          _pageViewController?.animateToPage(0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.linearToEaseOut);
        } else {
          _orderController.clear();
          Fluttertoast.showToast(
              msg: "Votre commande a été programmé avec succès !");
          Get.offAll(() => const AppHome());
        }
      });
    } catch (e) {
      //log("Erreur !");
      //print(e);
      Fluttertoast.showToast(msg: "Erreur !");
    }
  }
}
