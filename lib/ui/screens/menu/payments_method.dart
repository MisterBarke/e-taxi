import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kano/business/controller/payment_controller.dart';
import 'package:kano/ui/screens/menu/add_payment_method.dart';

class PaymentsMethod extends StatelessWidget {
  PaymentsMethod({Key? key}) : super(key: key);
  final PaymentController paymentController = Get.find();
  @override
  Widget build(BuildContext context) {

    return Scaffold(
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
                          child: Text("Moyen de paiement",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                              textAlign: TextAlign.center),
                        ),
                      )
                    ],
                  ),
                ),
                cashWidget(),
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
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                              itemCount:
                                  paymentController.paymentMethods.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  child: ListTile(
                                    leading:
                                        const Icon(Icons.credit_score_outlined),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          paymentController
                                              .paymentMethods[index]["brand"],
                                        ),
                                        Text(
                                          "**** ${paymentController.paymentMethods[index]["last4"]}",
                                        ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Expire : ${paymentController.paymentMethods[index]["expMonth"]} / ${paymentController.paymentMethods[index]["expYear"]}",
                                          ),
                                          Text(
                                            "Type : ${paymentController.paymentMethods[index]["funding"]}",
                                          ),
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
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.white,
        onPressed: () {
          Get.to(() => AddPaymentMethod(), fullscreenDialog: true);
        },
        label: const Icon(Icons.add, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Padding cashWidget() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
      child: Card(
        child: ListTile(
          leading: Icon(Icons.payments_rounded),
          title: Text("Cash"),
        ),
      ),
    );
  }
}
