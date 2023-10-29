import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../business/controller/payment_controller.dart';

class CardsList extends StatelessWidget {
  CardsList({super.key});

  final PaymentController paymentController = Get.find();
  final args = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () {
          return Column(
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
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(100)),
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
                          Get.back();
                        },
                      ),
                      const Flexible(
                        child: SizedBox(
                          width: double.maxFinite,
                          child: Text(
                            "Sélectionner le moyen",
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
              paymentController.isLoadingPM.value
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : paymentController.paymentMethods.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Center(
                            child: Text(
                              "Aucune carte bancaire pour le moment",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: <Widget>[
                              for (int i = 0;
                                  i < paymentController.paymentMethods.length;
                                  i++)
                                ListTile(
                                  title: Text(paymentController
                                      .paymentMethods[i]["brand"]),
                                  subtitle: Text(
                                    "**** ${paymentController.paymentMethods[i]["last4"]}",
                                  ),
                                  leading: Radio(
                                    value: i,
                                    groupValue:
                                        paymentController.selectedIndex.value,
                                    onChanged: (value) {
                                      paymentController.selectedIndex.value =
                                          value!;
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
              paymentController.isLoading.isTrue
                  ? const SpinKitThreeBounce(
                      color: Colors.blue,
                      size: 40,
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                      child: SizedBox(
                        height: 45,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                const MaterialStatePropertyAll(Colors.blue),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          onPressed: () {
                            paymentController
                                .pay(orderId: args["orderId"])
                                .then((value) {
                              paymentController.isLoading(false);
                              if (value["succes"] == true) {
                                Fluttertoast.showToast(
                                  msg: value["msg"],
                                  backgroundColor: Colors.green,
                                );
                              } else {
                                Fluttertoast.showToast(
                                  msg: value["msg"] + "\nMerci de réessayer",
                                  backgroundColor: Colors.red,
                                );
                              }
                            });
                          },
                          child: const Text(
                            "Confirmer",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}
