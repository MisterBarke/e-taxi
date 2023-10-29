import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart' as places;
import 'package:kano/business/model/address.dart';
import 'package:kano/business/service/google_service.dart';
import 'package:kano/ui/screens/order/order_details.dart';
import 'package:kano/ui/screens/order/ride_screen.dart';

import '../../business/controller/order_controller.dart';
import '../widgets/utils_widgets.dart';
import 'package:kano/translation/translation_keys.dart' as _;

class AddressPicker extends StatefulWidget {
  const AddressPicker({Key? key}) : super(key: key);

  @override
  State<AddressPicker> createState() => _AddressPickerState();
}

class _AddressPickerState extends State<AddressPicker> {
  final  orderController = Get.put(OrderController());
  final departureTextController = TextEditingController();
  final destinationTextController = TextEditingController();
  final args = Get.arguments;

  GoogleMapController? _controller;
  StreamSubscription? subscription;
  double currentZomValue = 20;

  AlertDialog? alert;
  Address? selected;

  bool loadingAddress = false;
  List<places.AutocompletePrediction> placesResult = [];

  var initialSheetHeight = 1.0;
  var sheetExtentStarted = true;

  int currentField = -2;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent, // navigation bar color
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark));

    return Obx(
      () {
        final polySet = Set<Polyline>.of(orderController.polylines.values);
        if (orderController.usingMap.isFalse ||
            orderController.needConfirmation.isFalse) {
          _setMapFitToTour(polySet);
        }

        return Scaffold(
          body: Container(
            color: Colors.white,
            child: Column(
              children: [
                SafeArea(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        /*BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          spreadRadius: 3,
                          blurRadius: 2,
                        )*/
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: _buildAddressFields(),
                        ),
                        loadingAddress
                            ? const LinearProgressIndicator()
                            : Container()
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: const CameraPosition(
                            // innital position in map
                            target: LatLng(12.3917911, -1.4806899),
                            //initial position
                            zoom: 12.0, //initial zoom level
                          ),
                          onMapCreated: (GoogleMapController controller) {
                            _controller = controller;
                          },
                          markers: orderController.markers
                              .map((element) => element)
                              .toSet(),
                          myLocationEnabled: true,
                          mapToolbarEnabled: false,
                          polylines: polySet,
                          onCameraIdle: () async {
                            if (orderController.usingMap.isTrue) {
                              _getCurrentController().text = "Chargement ...";

                              setState(() {
                                loadingAddress = true;
                              });

                              LatLngBounds bounds =
                                  await _controller!.getVisibleRegion();
                              final lon = (bounds.northeast.longitude +
                                      bounds.southwest.longitude) /
                                  2;
                              final lat = (bounds.northeast.latitude +
                                      bounds.southwest.latitude) /
                                  2;
                              Address? address;
                              if (args == null) {
                                address = await GoogleService.decode(
                                    LatLng(lat, lon));
                              } else {
                                address = await GoogleService.decode(
                                  LatLng(
                                    args["address"]["lat"],
                                    args["address"]["long"],
                                  ),
                                );
                              }

                              if (address != null && args == null) {
                                orderController.needConfirmation.value = true;
                                _getCurrentController().text =
                                    address.description ?? "";
                              } else if (args != null) {
                                setState(() {
                                  currentField = -1;
                                });
                                _getCurrentController().text =
                                    args["address"]["address"] ?? "";
                                orderController.needConfirmation(false);
                                selected = address;
                                _updateFields();
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Adresse introuvable !");
                              }
                              selected = address;
                              setState(() {
                                loadingAddress = false;
                              });

                              orderController.showBottomSheet.value = false;
                            }
                          },
                        ),
                        buildWidget(() {
                          return Obx(() {
                            return orderController.showBottomSheet.isTrue
                                ? _buildDraggableSheet()
                                : const SizedBox(height: 0, width: 0);
                          });
                        }),
                        orderController.usingMap.isFalse
                            ? const SizedBox(height: 0, width: 0)
                            : orderController.usingMap.isTrue && args != null
                                ? const SizedBox(height: 0, width: 0)
                                : Center(
                                    child: Image.asset(
                                      "assets/images/start_pin.png",
                                      height: 40,
                                      width: 40,
                                    ),
                                  )
                      ],
                    ),
                  ),
                ),
                Obx(
                  () {
                    return orderController.departAddress.value.latLng != null &&
                            orderController.destinationAddress.value.latLng !=
                                null &&
                            orderController.tripDrawed.isTrue &&
                            orderController.needConfirmation.isFalse &&
                            orderController.areAllStopsFilled() &&
                            !orderController.isEditing.value
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            color: Colors.white,
                            child: DefaultButton(
                              text: "Continuer",
                              onPress: () {
                                Get.to(() {
                                  return const OrderDetails();
                                });
                              },
                            ),
                          )
                        : (orderController.needConfirmation.isTrue
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                color: Colors.white,
                                child: DefaultButton(
                                  text: "OK",
                                  onPress: () {
                                    _updateFields();
                                    orderController.needConfirmation.value =
                                        false;
                                  },
                                ),
                              )
                            : orderController.isEditing.value &&
                                    orderController
                                            .departAddress.value.latLng !=
                                        null &&
                                    orderController
                                            .destinationAddress.value.latLng !=
                                        null &&
                                    orderController.needConfirmation.isFalse &&
                                    orderController.usingMap.isFalse &&
                                    orderController.showBottomSheet.isFalse
                                ? Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    color: Colors.white,
                                    child: DefaultButton(
                                      text: "Mettre à jour",
                                      onPress: () {
                                        orderController.showBottomSheet.value =
                                            true;
                                        orderController.updateCurrentRide();
                                        Get.back();
                                      },
                                    ),
                                  )
                                : const SizedBox(height: 0, width: 0));
                  },
                ),
              ],
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
        50 // Jouer sur ce nombre pour ajuster le tracé sur la carte
        ));
  }

  Widget _buildAddressFields() {
    return Obx(() => Column(
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
                      margin: const EdgeInsets.only(top: 5),
                      height: 8,
                      width: 8,
                      decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: orderController.stops.isEmpty
                          ? 55
                          : 45 + (orderController.stops.length * 35),
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
                          readOnly:
                              orderController.updateOnlyDestinationAddress.value
                                  ? true
                                  : false,
                          autofocus: false,
                          controller: departureTextController,
                          decoration: getAddressInputDecoration(
                              _.chooseDeparture.tr,
                              background: const Color(0XFFFAFAFA)),
                          onTap: !orderController
                                  .updateOnlyDestinationAddress.value
                              ? () {
                                  setState(() {
                                    currentField = -2;
                                  });
                                  _showSearch();
                                  departureTextController.selection =
                                      TextSelection(
                                          baseOffset: 0,
                                          extentOffset: departureTextController
                                              .value.text.length);
                                }
                              : null,
                          onChanged: (value) {
                            GoogleService.searchGooglePlace(value)
                                .then((value) {
                              setState(() {
                                placesResult = value;
                              });
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      buildWidget(() {
                        List<Widget> list = [];
                        for (int i = 0; i < orderController.stops.length; i++) {
                          list.add(Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                flex: 1,
                                child: SizedBox(
                                  height: 35,
                                  child: TextField(
                                    decoration: getAddressInputDecoration(
                                        _.clickToChooseAddress.tr,
                                        background: const Color(0XFFFAFAFA)),
                                    controller:
                                        orderController.stopsControllers[i],
                                    onTap: () {
                                      setState(() {
                                        currentField = i;
                                      });
                                      _showSearch();
                                      orderController
                                              .stopsControllers[currentField]
                                              .selection =
                                          TextSelection(
                                              baseOffset: 0,
                                              extentOffset: orderController
                                                  .stopsControllers[
                                                      currentField]
                                                  .value
                                                  .text
                                                  .length);
                                    },
                                    onChanged: (value) {
                                      GoogleService.searchGooglePlace(value)
                                          .then((value) {
                                        setState(() {
                                          placesResult = value;
                                        });
                                      });
                                    },
                                  ),
                                ),
                              ),

                              SizedBox(width: 10),

                              // Boutton de suppression
                              InkWell(
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFFF0F0F0),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  child: const Icon(Icons.remove),
                                ),
                                onTap: () {
                                  orderController.removeStop(i);
                                },
                              )
                            ],
                          ));

                          if (i < orderController.stops.length - 1) {
                            list.add(const SizedBox(height: 10));
                          }
                        }

                        return Column(
                          children: list,
                        );
                      }),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Flexible(
                            child: SizedBox(
                              height: 35,
                              child: TextField(
                                autofocus: false,
                                decoration: getAddressInputDecoration(
                                    _.chooseDestination.tr,
                                    background: const Color(0XFFFAFAFA)),
                                controller: destinationTextController,
                                onChanged: (value) {
                                  GoogleService.searchGooglePlace(value)
                                      .then((value) {
                                    setState(() {
                                      placesResult = value;
                                    });
                                  });
                                },
                                onTap: () {
                                  setState(() {
                                    currentField = -1;
                                  });
                                  _showSearch();
                                  destinationTextController.selection =
                                      TextSelection(
                                          baseOffset: 0,
                                          extentOffset:
                                              destinationTextController
                                                  .value.text.length);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                  color: Color(0xFFF0F0F0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                              child: const Icon(Icons.add),
                            ),
                            onTap: () {
                              if (orderController.stops.isNotEmpty &&
                                  orderController
                                          .stops[
                                              orderController.stops.length - 1]
                                          .latLng ==
                                      null) {
                                return;
                              }

                              orderController.addStop();
                            },
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ],
        ));
  }

  _buildDraggableSheet() {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (DraggableScrollableNotification DSNotification) {
        if (DSNotification.extent > 0.3) {
          setState(() {
            sheetExtentStarted = true;
          });
        } else if (DSNotification.extent <= 0.25) {
          setState(() {
            sheetExtentStarted = false;
          });
        } else if (DSNotification.extent <= 0.2) {
          orderController.showBottomSheet.value = false;
          orderController.usingMap.value = true;
        }

        return true;
      },
      child: DraggableScrollableSheet(
          initialChildSize: 1,
          minChildSize: 0.3,
          maxChildSize: 1.0,
          snap: true,
          builder: (BuildContext context, scrollSheetController) {
            return Container(
                color: Colors.transparent,
                padding: EdgeInsets.only(
                    left: sheetExtentStarted ? 0 : 10,
                    right: sheetExtentStarted ? 0 : 10,
                    top: 2),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10))),
                  child: SingleChildScrollView(
                    controller: scrollSheetController,
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 5),
                            Container(
                              width: 50,
                              height: 5,
                              decoration: const BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(40))),
                            ),
                            const SizedBox(height: 5),
                            InkWell(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                color: const Color(0XFFFAFAFA),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Text(_.useMap.tr,
                                          style: const TextStyle(
                                              color: Colors.blue)),
                                    )
                                  ],
                                ),
                              ),
                              onTap: () {
                                SystemChannels.textInput
                                    .invokeMethod('TextInput.hide');
                                orderController.usingMap.value = true;
                                orderController.showBottomSheet.value = false;
                              },
                            )
                          ],
                        ),
                        ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final item = placesResult[index];

                              return InkWell(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(50))),
                                      child: const Icon(Icons.location_pin,
                                          color: Colors.white, size: 20),
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(15),
                                        decoration: const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    width: 1,
                                                    color: Color(0XFFF0F0F0))),
                                            color: Colors.white),
                                        child: Text(
                                            "${item.structuredFormatting?.mainText}"),
                                      ),
                                    )
                                  ],
                                ),
                                onTap: () {
                                  SystemChannels.textInput
                                      .invokeMethod('TextInput.hide');

                                  setState(() {
                                    loadingAddress = true;
                                  });
                                  GoogleService.geocode(item.description!)
                                      .then((value) {
                                    orderController.geocoding.value = false;

                                    setState(() {
                                      loadingAddress = true;
                                    });

                                    if (value != null) {
                                      selected = Address(
                                          description: item.description!,
                                          latLng:
                                              LatLng(value.lat!, value.lng!),
                                          name: item
                                              .structuredFormatting?.mainText);
                                      setState(() {
                                        loadingAddress = false;
                                      });
                                      _updateFields();
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: "Addresse invalide !");
                                    }
                                  });
                                },
                              );
                            },
                            itemCount: placesResult.length,
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            primary: true)
                      ],
                    ),
                  ),
                ));
          }),
    );
  }

  void _updateFields() {
    if (currentField == -2) {
      orderController.departAddress.value = selected!;
      departureTextController.text = selected!.name!;
    } else if (currentField == -1) {
      orderController.destinationAddress.value = selected!;
      destinationTextController.text = selected!.name!;
    } else {
      try {
        orderController.stops[currentField] = selected!;
        orderController.stopsControllers[currentField].text = selected!.name!;
      } on Exception catch (_) {}
    }

    orderController.usingMap.value = false;
    orderController.showBottomSheet.value = false;
    orderController.buildMarkers();
  }

  @override
  void initState() {
    if (args != null) {
      orderController.showBottomSheet(false);
      orderController.usingMap(true);
    }
    orderController.subscription?.cancel();
    departureTextController.text =
        orderController.departAddress.value.name ?? "";
    if (orderController.departAddress.value.latLng != null) {
      currentField = -1;
    }
    destinationTextController.text =
        orderController.destinationAddress.value.name ?? "";
    super.initState();
  }

  void _showSearch() {
    orderController.usingMap.value = false;
    orderController.showBottomSheet.value = true;
  }

  TextEditingController _getCurrentController() {
    switch (currentField) {
      case -1:
        return destinationTextController;
      case -2:
        return departureTextController;
      default:
        return orderController.stopsControllers[currentField];
    }
  }
}
