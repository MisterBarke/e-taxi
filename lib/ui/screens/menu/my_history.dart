import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kano/business/controller/history_controller.dart';
import 'package:kano/ui/screens/menu/history_details.dart';
import 'package:kano/ui/widgets/utils_widgets.dart';

class HistoryPage extends StatelessWidget {
  HistoryPage({Key? key}) : super(key: key);
  final historyController = Get.put(HistoryController());

  @override
  Widget build(BuildContext context) {
    historyController.getOrders();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(
          () {
            return Column(
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
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(100)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 3,
                                  blurRadius: 2,
                                )
                              ]),
                          child: const Icon(Icons.arrow_back_ios_new_outlined,
                              size: 17),
                        ),
                        onTap: () {
                          Get.back();
                        },
                      ),
                      const Flexible(
                        child: SizedBox(
                          width: double.maxFinite,
                          child: Text("Mes courses",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                              textAlign: TextAlign.center),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          historyController.selected(1);
                          historyController.getOrders();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: 30,
                          decoration: BoxDecoration(
                            color: historyController.selected.value == 1
                                ? Colors.grey.withOpacity(0.7)
                                : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "Effectuée",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          historyController.selected(2);
                          historyController.getOrders();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: 30,
                          decoration: BoxDecoration(
                            color: historyController.selected.value == 2
                                ? Colors.grey.withOpacity(0.7)
                                : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "A venir",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                historyController.isLoading.value
                    ? const Center(child: CircularProgressIndicator.adaptive())
                    : historyController.orders.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Center(
                              child: historyController.selected.value == 1
                                  ? const Text(
                                      'Aucune course effectué',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey),
                                    )
                                  : const Text(
                                      'Aucune course à venir',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                              itemCount: historyController.orders.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    historyController.orderId(
                                        historyController.orders[index]['id']);

                                    Get.to(
                                      () => HistoryDetails(),
                                      fullscreenDialog: true,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    margin: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 3,
                                          blurRadius: 2,
                                        )
                                      ],
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15)),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: historyController
                                                          .selected.value ==
                                                      1
                                                  ? Text(
                                                      formatDate(
                                                          historyController
                                                                  .orders[index]
                                                              ["acceptedAt"]),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )
                                                  : Text(
                                                      DateFormat(
                                                              "dd-MM-yyyy, HH:mm")
                                                          .format(DateTime.parse(
                                                              historyController
                                                                      .orders[
                                                                  index]["at"]))
                                                          .toString(),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                            ),
                                            Flexible(
                                              child: getStatusTextWidget(
                                                historyController.orders[index]
                                                    ["status"],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 30, thickness: 1),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    historyController.orders[
                                                                    index]
                                                                ["pickedAt"] !=
                                                            null
                                                        ? Text(
                                                            dateFormat(
                                                              historyController
                                                                          .orders[
                                                                      index]
                                                                  ["pickedAt"],
                                                              format: "HH:mm",
                                                            ),
                                                          )
                                                        : const Text("--"),
                                                    const SizedBox(height: 5),
                                                    Container(
                                                      height: 35,
                                                      width: 3,
                                                      decoration:
                                                          const BoxDecoration(
                                                        color:
                                                            Colors.transparent,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(10),
                                                        ),
                                                      ),
                                                    ),
                                                    historyController.orders[
                                                                    index]
                                                                ["endedAt"] !=
                                                            null
                                                        ? Text(
                                                            dateFormat(
                                                              historyController
                                                                          .orders[
                                                                      index]
                                                                  ["endedAt"],
                                                              format: "HH:mm",
                                                            ),
                                                          )
                                                        : const Text("--"),
                                                  ],
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 15),
                                                      height: 8,
                                                      width: 8,
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.blue,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(50),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Container(
                                                      height: 35,
                                                      width: 3,
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(10),
                                                        ),
                                                      ),
                                                    ),
                                                    const Icon(
                                                        Icons.arrow_drop_down)
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 10),
                                            Flexible(
                                              flex: 1,
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height: 45,
                                                    child: TextField(
                                                      enabled: false,
                                                      decoration:
                                                          getAddressInputDecoration(
                                                        hintMaxLines: 2,
                                                        historyController
                                                                    .orders[
                                                                index]["depart"]
                                                            ["address"],
                                                        background: const Color(
                                                            0XFFFAFAFA),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  const SizedBox(height: 10),
                                                  SizedBox(
                                                    height: 45,
                                                    child: TextField(
                                                      enabled: false,
                                                      decoration:
                                                          getAddressInputDecoration(
                                                        historyController
                                                                        .orders[
                                                                    index]
                                                                ["destination"]
                                                            ["address"],
                                                        hintMaxLines: 2,
                                                        background: const Color(
                                                            0XFFFAFAFA),
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
                                );
                              },
                            ),
                          )
              ],
            );
          },
        ),
      ),
    );
  }
}
