import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:kano/business/controller/order_controller.dart';
import 'package:kano/business/model/address.dart';
import 'package:kano/ui/screens/home.dart';
import 'package:kano/ui/widgets/utils_widgets.dart';

class Cancelation extends StatefulWidget {
  final dynamic data;

  const Cancelation({Key? key, this.data}) : super(key: key);

  @override
  State<Cancelation> createState() => _CancelationState();
}

class _CancelationState extends State<Cancelation> {
  var _selectedReason = "J'ai eu un accident";
  final orderController = Get.put(OrderController());
  var canceling = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: InkWell(
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
                  child:
                      const Icon(Icons.arrow_back_ios_new_outlined, size: 17),
                ),
                onTap: () {
                  Get.back();
                },
              ),
            ),
            const SizedBox(height: 100),
            ListTile(
              title: const Text("J'ai eu un accident"),
              leading: Radio<String>(
                value: "J'ai eu un accident",
                groupValue: _selectedReason,
                onChanged: (String? value) {
                  setState(() {
                    _selectedReason = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text("Impossible de contacter le chauffeur"),
              leading: Radio<String>(
                value: "Impossible de contacter le chauffeur",
                groupValue: _selectedReason,
                onChanged: (String? value) {
                  setState(() {
                    _selectedReason = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text("Le chauffeur est en retard"),
              leading: Radio<String>(
                value: "Le chauffeur est en retard",
                groupValue: _selectedReason,
                onChanged: (String? value) {
                  setState(() {
                    _selectedReason = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text("Le prix n'est pas raisonnable"),
              leading: Radio<String>(
                value: "Le prix n'est pas raisonnable",
                groupValue: _selectedReason,
                onChanged: (String? value) {
                  setState(() {
                    _selectedReason = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text("Adresse de voyage invalide"),
              leading: Radio<String>(
                value: "Adresse de voyage invalide",
                groupValue: _selectedReason,
                onChanged: (String? value) {
                  setState(() {
                    _selectedReason = value!;
                  });
                },
              ),
            ),
            const Spacer(),
            (canceling
                ? const SpinKitThreeBounce(
                    color: Colors.blue,
                    size: 40,
                  )
                : Padding(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      width: double.infinity,
                      child: DefaultButton(
                          text: "Annuler la commande",
                          background: Colors.red,
                          onPress: () {
                            orderController.clear();
                            _handleCancelOrder();
                          }),
                    ),
                  ))
          ],
        ),
      ),
    );
  }

  Future<void> _handleCancelOrder() async {
    setState(() {
      canceling = true;
    });
    var response =
        await orderController.cancelOrder({"reason": _selectedReason});
    Get.offAll(() => const AppHome());
  }
}
