import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:kano/business/controller/order_controller.dart';
import 'package:kano/business/controller/ride_controller.dart';
import 'package:kano/ui/screens/home.dart';
import '../../widgets/utils_widgets.dart';

class Receipt extends StatelessWidget {
  final _orderController = Get.put(OrderController());
  final _rideController = Get.put(RideController());

  Receipt({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _rideController.handleNote();
        return true;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            color: const Color(0xFFFAFAFA),
            child: Column(
              children: [
                const SizedBox(height: 100),
                Container(
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 4,
                    )
                  ]),
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/ic_success.png",
                          width: 80, height: 80),
                      const SizedBox(height: 20),
                      const Text(
                        "La course est terminée",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(25)),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(top: 15),
                                      child: _rideController.currentOrder[
                                                  "pickedAt"] !=
                                              null
                                          ? Text(
                                              dateFormat(
                                                _rideController
                                                        .currentOrder[
                                                    "pickedAt"],
                                                format: 'HH:mm',
                                              ),
                                            )
                                          : const Text("--"),
                                    ),
                                    const SizedBox(width: 5),
                                    Container(
                                      margin:
                                          const EdgeInsets.only(top: 15),
                                      height: 8,
                                      width: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50)),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const SizedBox(width: 38),
                                    Container(
                                      height: 30,
                                      width: 5,
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    _rideController
                                                .currentOrder["endedAt"] !=
                                            null
                                        ? Text(
                                            dateFormat(
                                              _rideController
                                                  .currentOrder["endedAt"],
                                              format: "HH:mm",
                                            ),
                                          )
                                        : const Text("--"),
                                    const SizedBox(width: 2),
                                    const Icon(Icons.arrow_drop_down)
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Text(
                                      _rideController.currentOrder['depart']
                                          ['address'],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Divider(height: 1),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Text(
                                      _rideController
                                              .currentOrder['destination']
                                          ['address'],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF4F4F4),
                          borderRadius:
                              BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Row(
                          children: const [],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Image.asset("assets/images/ic_receipt.png"),
                ),
                RatingBar.builder(
                  initialRating: _rideController.rideNote.value,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    _rideController.rideNote.value = rating;
                  },
                ),
                const SizedBox(height: 5),
                Obx(
                  () {
                    String note = "";
                    if (_rideController.rideNote.value <= 1) {
                      note = "Très mauvais";
                    } else if (_rideController.rideNote.value <= 2) {
                      note = "Mauvais";
                    } else if (_rideController.rideNote.value <= 3) {
                      note = "Passable";
                    } else if (_rideController.rideNote.value <= 4.5) {
                      note = "Bien";
                    } else {
                      note = "Très bien";
                    }

                    return Text(note);
                  },
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DefaultButton(
                      text: "Evaluer la course",
                      onPress: () {
                        _rideController.handleNote();
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*Image.asset(payment.image, width: 40, height: 40),
                              const SizedBox(width: 15),
                              Flexible(
                                child: Text(payment.name),
                              ),

                              Spacer(),

                              Row(
                                children: const [
                                  Text("18", style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
                                  SizedBox(width: 2),
                                  Text("€", style: TextStyle(fontSize: 12)),
                                ],
                              )*/
