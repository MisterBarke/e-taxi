import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:kano/business/controller/payment_controller.dart';
import 'package:kano/constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kano/translation/translation_keys.dart' as translation;

class AddPaymentMethod extends StatelessWidget {
  AddPaymentMethod({super.key});
  final paymentController = Get.put(PaymentController());
  @override
  Widget build(BuildContext context) {
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
                          child: Text("Ajouter une carte",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                              textAlign: TextAlign.center),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(15, 60, 15, 15),
                    children: [
                      CardFormField(
                        countryCode: "FR",
                        enablePostalCode: false,
                        style: CardFormStyle(borderWidth: 0),
                        onCardChanged: (card) {},
                        controller: CardFormEditController(),
                      ),
                      paymentController.isLoading.value
                          ? const Center(
                              child: CircularProgressIndicator.adaptive())
                          : SizedBox(
                              height: 60,
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15)))),
                                onPressed: () {
                                  paymentController.saveCard();
                                },
                                child: const Text(
                                  "Enregistrer",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
