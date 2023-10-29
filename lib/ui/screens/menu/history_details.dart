import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kano/business/controller/history_controller.dart';
import 'package:kano/ui/screens/support/signaler_incident.dart';
import 'package:kano/ui/widgets/utils_widgets.dart';

import 'cards_list.dart';

class HistoryDetails extends StatelessWidget {
  HistoryDetails({super.key});

  final historyController = Get.put(HistoryController());

  @override
  Widget build(BuildContext context) {
    historyController.getDetails();
    return Scaffold(
      body: Obx(
        () {
          final polySet = Set<Polyline>.of(historyController.polylines.values);
          _setMapFitToTour(polySet);
          return historyController.isLoadingDetails.isTrue ||
                  historyController.isLoadingDriver.isTrue
              ? const Center(
                  child: CircularProgressIndicator.adaptive(),
                )
              : Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Container(
                            color: Colors.grey,
                            child: GoogleMap(
                              mapType: MapType.normal,
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                  historyController.detail["depart"]["lat"],
                                  historyController.detail["depart"]["long"],
                                ),
                                zoom: 9,
                              ),
                              onMapCreated: (GoogleMapController controller) {},
                              polylines: polySet,
                              markers: historyController.markers
                                  .map((element) => element)
                                  .toSet(),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Container(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SafeArea(
                      child: Padding(
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
                            const Flexible(
                              child: SizedBox(
                                width: double.maxFinite,
                                child: Text(
                                  "Details de la course",
                                  style: TextStyle(
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
                      left: 0,
                      right: 0,
                      bottom: 0,
                      top: MediaQuery.of(context).size.height * 0.4,
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            margin: EdgeInsets.zero,
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
                                  const BorderRadius.all(Radius.circular(15)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: historyController.selected.value ==
                                              1
                                          ? Text(
                                              formatDate(historyController
                                                  .detail["acceptedAt"]),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : Text(
                                              DateFormat("dd-MM-yyyy, HH:mm")
                                                  .format(DateTime.parse(
                                                      historyController
                                                          .detail["at"]))
                                                  .toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                    Flexible(
                                      child: getStatusTextWidget(
                                        historyController.detail["status"],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 30, thickness: 1),
                                Row(
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
                                                  Radius.circular(50))),
                                        ),
                                        const SizedBox(height: 5),
                                        Container(
                                          height: 35,
                                          width: 3,
                                          decoration: const BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
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
                                              decoration:
                                                  getAddressInputDecoration(
                                                hintMaxLines: 2,
                                                historyController
                                                        .detail["depart"]
                                                    ["address"],
                                                background:
                                                    const Color(0XFFFAFAFA),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          const SizedBox(height: 10),
                                          SizedBox(
                                            height: 35,
                                            child: TextField(
                                              enabled: false,
                                              decoration:
                                                  getAddressInputDecoration(
                                                historyController
                                                        .detail["destination"]
                                                    ["address"],
                                                hintMaxLines: 2,
                                                background:
                                                    const Color(0XFFFAFAFA),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "Details de la course",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Card(
                            elevation: 3,
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(10),
                              title: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Date de départ :"),
                                      historyController.detail["pickedAt"] !=
                                              null
                                          ? Text(
                                              dateFormat(
                                                historyController
                                                    .detail["pickedAt"],
                                                format: "dd/MM/yyyy, HH:mm",
                                              ),
                                              style: const TextStyle(
                                                  color: Colors.grey),
                                            )
                                          : const Text("--"),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Date d'arrivée :"),
                                      historyController.detail["endedAt"] !=
                                              null
                                          ? Text(
                                              dateFormat(
                                                historyController
                                                    .detail["endedAt"],
                                                format: "dd/MM/yyyy, HH:mm",
                                              ),
                                              style: const TextStyle(
                                                  color: Colors.grey),
                                            )
                                          : const Text("--"),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Distance parcourue :"),
                                      Text(
                                        historyController.detail["distance"] +
                                            " Km",
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          historyController.selected.value == 1
                              ? const SizedBox(height: 15)
                              : const SizedBox(height: 0),
                          historyController.selected.value == 1
                              ? const Text(
                                  "Chauffeur",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )
                              : const Text(""),
                          historyController.selected.value == 1
                              ? const SizedBox(height: 10)
                              : const SizedBox(height: 0),
                          historyController.selected.value == 1
                              ? Card(
                                  margin: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 3,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.fromLTRB(
                                      10,
                                      10,
                                      10,
                                      10,
                                    ),
                                    leading: CachedNetworkImage(
                                      imageUrl: historyController
                                          .driver["docsPhoto"]["link"],
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        height: 65,
                                        width: 65,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                    title: Text(
                                      "${historyController.detail["driver"]["lastName"]} ${historyController.detail["driver"]["firstName"]}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          historyController.driver[
                                                      "docsCarteGrise"] !=
                                                  null
                                              ? Text(
                                                  historyController.driver[
                                                          "docsCarteGrise"]
                                                      ["marqueVehicule"],
                                                  style: const TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                )
                                              : const Text(
                                                  "--",
                                                  style: TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                          const SizedBox(height: 3),
                                          historyController.detail["status"] ==
                                                  4
                                              ? Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                      size: 13,
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                        "${historyController.detail["note"]}"),
                                                  ],
                                                )
                                              : Container(),
                                        ],
                                      ),
                                    ),
                                    trailing: const Icon(
                                        Icons.arrow_forward_ios_rounded),
                                  ),
                                )
                              : Container(),
                          historyController.selected.value == 1
                              ? const SizedBox(height: 15)
                              : const SizedBox(height: 0),
                          const Text(
                            "Paiement",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Card(
                            margin: EdgeInsets.zero,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      "****${historyController.detail["payment"]["method"]}"),
                                  Text(
                                    "${historyController.detail["payment"]["price"]} €",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          historyController.detail["status"] >= 1 ||
                                  historyController.detail["status"] == -2
                              ? const SizedBox(height: 20)
                              : Container(),
                          //Payer le crédit
                          historyController.detail["status"] == 3
                              ? SizedBox(
                                  height: 45,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          const MaterialStatePropertyAll(
                                              Colors.red),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      Get.to(
                                        () => CardsList(),
                                        fullscreenDialog: true,
                                        arguments: {
                                          "orderId":
                                              historyController.detail["id"],
                                        },
                                      );
                                    },
                                    child: const Text(
                                      "Payer le crédit",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                          //annuler && signaler incident
                          historyController.detail["status"] >= 1 &&
                                  historyController.detail["status"] != 3
                              ? SizedBox(
                                  height: 45,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          const MaterialStatePropertyAll(
                                              Colors.grey),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      Get.to(
                                        () => SignalerIncident(),
                                        arguments: {
                                          "orderId":
                                              historyController.detail["id"],
                                          "userName": historyController
                                              .detail["userName"],
                                          "driverName":
                                              "${historyController.detail["driver"]["lastName"]} ${historyController.detail["driver"]["firstName"]}",
                                        },
                                      );
                                    },
                                    child: const Text(
                                      "Signaler un incident",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                )
                              : historyController.detail["status"] == -4
                                  ? SizedBox(
                                      height: 45,
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              const MaterialStatePropertyAll(
                                                  Colors.red),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          historyController
                                              .cancelScheduledOrder(
                                                  orderId: historyController
                                                      .detail["id"]);
                                        },
                                        child: const Text(
                                          "Annuler",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                        ],
                      ),
                    )
                  ],
                );
        },
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
  }
}
