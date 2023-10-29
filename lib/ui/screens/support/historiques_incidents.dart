import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../business/controller/historiques_incidents_controller.dart';
import '../../widgets/utils_widgets.dart';

class HistoriquesIncidents extends StatelessWidget {
  HistoriquesIncidents({super.key});

  final historiquesIncidentsController =
      Get.put(HistoriquesIncidentsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Obx(
      () {
        return historiquesIncidentsController.isLoading.isTrue
            ? const Center(
                child: CircularProgressIndicator.adaptive(),
              )
            : Column(
                children: [
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
                                "Historiques incidents",
                                style: TextStyle(
                                  color: Colors.black,
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
                  historiquesIncidentsController.incidents.isEmpty
                      ? Center(
                          child: Text(
                            "Aucun incident signalé",
                            style:
                                TextStyle(color: Colors.grey.withOpacity(0.5)),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(15),
                            itemCount:
                                historiquesIncidentsController.incidents.length,
                            itemBuilder: (context, index) {
                              return Card(
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(10),
                                  leading: CachedNetworkImage(
                                    imageUrl: historiquesIncidentsController
                                        .incidents[index]["link"],
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
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          historiquesIncidentsController
                                              .incidents[index]["driverName"],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          dateFormat(
                                              historiquesIncidentsController
                                                      .incidents[index]
                                                  ["createdAt"],
                                              format: 'dd/MM/yyyy, HH:mm'),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Column(
                                      children: [
                                        Text(
                                          historiquesIncidentsController
                                              .incidents[index]["description"],
                                          textAlign: TextAlign.justify,
                                        ),
                                        const SizedBox(height: 10),
                                        historiquesIncidentsController
                                                        .incidents[index]
                                                    ["status"] ==
                                                1
                                            ? const Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: Text(
                                                  "Traité",
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              )
                                            : const Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: Text(
                                                  "Non traité",
                                                  style: TextStyle(
                                                    color: Colors.orange,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                ],
              );
      },
    ));
  }
}
