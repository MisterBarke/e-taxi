import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kano/constants.dart';
import 'package:kano/translation/translation_keys.dart' as translation;
import '../../../business/controller/notification_controller.dart';

class Notifications extends StatelessWidget {
  Notifications({super.key});

  final notificationController = Get.put(NotitificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: Obx(
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
                    Flexible(
                      child: SizedBox(
                        width: double.maxFinite,
                        child: Text(translation.notifications.tr,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                            textAlign: TextAlign.center),
                      ),
                    )
                  ],
                ),
              ),
              notificationController.isLoading.value
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : notificationController.notifications.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 50),
                            child: Text("Vous n'avez pas de notifications",
                                style: TextStyle(color: Colors.grey)),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount:
                                notificationController.notifications.length,
                            itemBuilder: (context, index) {
                              final date = notificationController
                                      .notifications[index]["createdAt"]
                                      .seconds *
                                  1000;

                              notificationController.getTimeAtDate(
                                  DateTime.fromMillisecondsSinceEpoch(date));
                              return Card(
                                margin: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  bottom: 5,
                                  top: 5,
                                ),
                                elevation: 0,
                                color: notificationController
                                            .notifications[index]["opened"] ==
                                        true
                                    ? null
                                    : Colors.grey.withOpacity(0.2),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      width: 1,
                                      color:
                                          Color.fromARGB(255, 204, 200, 200)),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: ListTile(
                                    onTap: () {
                                      Get.defaultDialog(
                                        title: notificationController
                                            .notifications[index]["title"],
                                        middleText: notificationController
                                            .notifications[index]["body"],
                                        cancelTextColor: Colors.red,
                                        buttonColor: Colors.red,
                                        textCancel: "Retour",
                                        radius: 5,
                                      );
                                      notificationController
                                          .updateNotificationsStatus(
                                        notificationController
                                            .notifications[index]["id"],
                                      );
                                    },
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          notificationController
                                              .notifications[index]["title"],
                                          style: notificationController
                                                          .notifications[index]
                                                      ["opened"] ==
                                                  true
                                              ? const TextStyle()
                                              : const TextStyle(
                                                  fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                          notificationController.temps.value,
                                          style: notificationController
                                                          .notifications[index]
                                                      ["opened"] ==
                                                  true
                                              ? const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                )
                                              : const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                ),
                                        )
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Divider(thickness: 1, height: 20),
                                        Text(
                                          notificationController
                                              .notifications[index]["body"],
                                          style: notificationController
                                                          .notifications[index]
                                                      ["opened"] ==
                                                  true
                                              ? const TextStyle()
                                              : const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.black,
                                                ),
                                        ),
                                        const SizedBox(height: 20)
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
      )),
    );
  }
}
