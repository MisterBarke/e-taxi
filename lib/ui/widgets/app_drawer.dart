import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kano/business/controller/auth_controller.dart';
import 'package:kano/translation/translation_keys.dart' as translation;
import 'package:kano/ui/screens/menu/about.dart';
import 'package:kano/ui/screens/menu/help.dart';
import 'package:kano/ui/screens/menu/legal.dart';
import 'package:kano/ui/screens/menu/my_history.dart';
import 'package:kano/ui/screens/menu/payments_method.dart';
import 'package:kano/ui/screens/menu/support.dart';
import 'package:kano/ui/screens/profile/profile.dart';
import '../../business/controller/app_controller.dart';

class AppDrawer extends StatelessWidget {
  final appController = Get.put(AppController());
  final authController = Get.put(AuthController());

  AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = authController.getUser();

    return SafeArea(
      child: Obx(() {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Spacer(),
                  DropdownButton(
                      value: appController.currentLocal.value,
                      items: const [
                        DropdownMenuItem(value: "fr", child: Text("Français")),
                        DropdownMenuItem(value: "en", child: Text("Anglais")),
                      ],
                      onChanged: (value) {
                        appController.currentLocal.value = value!;
                        Get.updateLocale(Locale(value));
                      })
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.to(() => Profile());
                            },
                            child: Image.asset(
                                "assets/images/default_avatar.png",
                                width: 100,
                                height: 100),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                              width: double.infinity,
                              child: Text(
                                "${user['firstname']} ${user['lastname']}",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              )),
                          const SizedBox(height: 5),
                          SizedBox(
                              width: double.infinity,
                              child: Text(
                                "${user['email']}",
                                textAlign: TextAlign.center,
                              ))
                        ],
                      ),
                      const SizedBox(height: 30),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: GridView.count(
                            primary: false,
                            padding: const EdgeInsets.all(20),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            children: <Widget>[
                              InkWell(
                                child: Container(
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
                                          Radius.circular(10))),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset("assets/images/history.png",
                                            width: 40, height: 40),
                                        const SizedBox(height: 15),
                                        Text(
                                          translation.myOrders.tr.toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Get.to(() => HistoryPage());
                                },
                              ),
                              InkWell(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
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
                                        Radius.circular(10)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset("assets/images/payment.png",
                                          width: 40, height: 40),
                                      const SizedBox(height: 15),
                                      Text(
                                        translation.paymentMethods.tr
                                            .toUpperCase(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10),
                                      )
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  Get.to(() => PaymentsMethod());
                                },
                              ),
                              InkWell(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
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
                                          Radius.circular(10))),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset("assets/images/ic_help.png",
                                          width: 40, height: 40),
                                      const SizedBox(height: 15),
                                      Text(
                                        translation.setting.tr.toUpperCase(),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10),
                                      )
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  Get.to(() => Help());
                                },
                              ),
                              InkWell(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
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
                                          Radius.circular(10))),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                          "assets/images/ic_support.png",
                                          width: 40,
                                          height: 40),
                                      const SizedBox(height: 15),
                                      Text(
                                        translation.support.tr.toUpperCase(),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10),
                                      )
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  Get.to(() => Support());
                                },
                              ),
                              InkWell(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
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
                                          Radius.circular(10))),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                          "assets/images/ic_support.png",
                                          width: 40,
                                          height: 40),
                                      const SizedBox(height: 15),
                                      Text(
                                        translation.legal.tr.toUpperCase(),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10),
                                      )
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  Get.to(() => Legal());
                                },
                              ),
                              InkWell(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
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
                                          Radius.circular(10))),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                          "assets/images/ic_support.png",
                                          width: 40,
                                          height: 40),
                                      const SizedBox(height: 15),
                                      Text(
                                        translation.about.tr.toUpperCase(),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10),
                                      )
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  Get.to(() => About(), fullscreenDialog: true);
                                },
                              ),
                            ]),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
