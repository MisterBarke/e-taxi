
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kano/business/model/payment_method.dart';

import '../../../business/controller/order_controller.dart';
import '../../widgets/utils_widgets.dart';
import 'receip.dart';
import 'package:kano/translation/translation_keys.dart' as _;

class OnTrip extends StatefulWidget {

  final Map<String, dynamic> order;

  const OnTrip({Key? key, required this.order}) : super(key: key);

  @override
  State<OnTrip> createState() => _OnTripState();
}

class _OnTripState extends State<OnTrip> {

  final OrderController _orderController = Get.find();

  GoogleMapController? _controller;
  double currentZomValue = 16;
  var currentIndex = 0;

  late final PageController _pageViewController;

  late List<Widget> pages = [];


  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white, // navigation bar color
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
        body: Builder(
          builder: (context) => Stack(
            fit: StackFit.loose,
            children: [
              Container(
                height: Get.height*0.85,
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    //innital position in map
                    target: LatLng(12.3917911, -1.4806899),
                    //initial position
                    zoom: 12.0, //initial zoom level
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                  },
                  myLocationEnabled: false,
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            child: Container(
                              padding: const EdgeInsets.all(2),
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
                              child: Image.asset(
                                  "assets/images/ic_menu.png",
                                  height: 32,
                                  width: 32),
                            ),
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },
                          ),
                          const Flexible(
                            child: SizedBox(
                              width: double.maxFinite,
                              child: Text("En déplacement",
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                  textAlign: TextAlign.center),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              _buildDraggableSheet()
            ],
          ),
        ));
  }


  @override
  void initState() {
    super.initState();
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
    _controller?.moveCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(minLat, minLong),
            northeast: LatLng(maxLat, maxLong)),
        8));
  }

  _buildDraggableSheet() {

    return DraggableScrollableSheet(

        initialChildSize: 0.15,
        minChildSize: 0.15,
        maxChildSize: 0.55,
        snap: true,
        builder: (BuildContext context, scrollSheetController) {

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: SingleChildScrollView(
              controller: scrollSheetController,
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [

                  const SizedBox(height: 10),

                  buildDragger(),

                  const SizedBox(height: 10),

                  Row(
                    children: [

                      Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                        child: Image.asset("assets/images/driver_photo.png", width: 70, height: 70),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Andre", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Row(
                            children: const [
                              Icon(Icons.star, color: Colors.amber),
                              SizedBox(width: 5),
                              Text("4.8")
                            ],
                          )
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.6),
                              borderRadius: const BorderRadius.all(Radius.circular(15)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text("У000РА", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(width: 5),
                                Text("35", style: TextStyle(fontSize: 12))
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text("Volkswagen Jetta"),

                          const SizedBox(height: 20),
                        ],
                      )
                    ],
                  ),

                  Column(
                    children: [
                      Container(
                        height: 330,
                        width: Get.width,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30),
                                topLeft: Radius.circular(30))),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children:  [

                            Container(
                              child: Column(
                                children: [

                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.all(Radius.circular(25)),
                                        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1)
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(top: 15),
                                              height: 8,
                                              width: 8,
                                              decoration: const BoxDecoration(
                                                  color: Colors.blue,
                                                  borderRadius: BorderRadius.all(Radius.circular(50))),
                                            ),
                                            const SizedBox(height: 5),
                                            Container(
                                              height:  50,
                                              width: 5,
                                              decoration: const BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius: BorderRadius.all(Radius.circular(10))),
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
                                                  getAddressInputDecoration(_.chooseDeparture.tr, background: const Color(0XFFFFFFFF)),
                                                  controller: TextEditingController(
                                                      text: _orderController
                                                          .departAddress.value.description ??
                                                          ""),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              const Divider(height: 1),
                                              const SizedBox(height: 10),
                                              SizedBox(
                                                height: 40,
                                                child: TextField(
                                                  enabled: false,
                                                  decoration:
                                                  getAddressInputDecoration(_.chooseDestination.tr, background: const Color(0XFFFFFFFF)),
                                                  controller: TextEditingController(
                                                      text: _orderController
                                                          .destinationAddress.value.description),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),


                                  const SizedBox(height: 15),

                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                        color: Color(0xFFF4F4F4),
                                        borderRadius: BorderRadius.all(Radius.circular(10))
                                    ),
                                    child: Row(
                                      children: [

                                        Image.asset("assets/images/ic_cash.png", width: 40, height: 40),
                                        const SizedBox(width: 15),
                                        const Flexible(
                                          child: Text("Cash"),
                                        )

                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.3),
                                              spreadRadius: 2,
                                              blurRadius: 10,
                                            )
                                          ]
                                      ),
                                      child: DefaultButton(text: "Evaluer le chauffeur", textColor: Colors.black, background: Colors.white, onPress: (){

                                        Get.bottomSheet(
                                            Container(
                                              height: Get.height/2,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,

                                                children:  [
                                                  Column(
                                                    children: [
                                                      Container(
                                                        decoration: const BoxDecoration(
                                                          borderRadius: BorderRadius.all(Radius.circular(100)),
                                                        ),
                                                        child: Image.asset("assets/images/driver_photo.png", width: 70, height: 70),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      const Text("Andre", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                                                    ],
                                                  ),

                                                  const SizedBox(height: 10),

                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: const [
                                                      Icon(Icons.star, color: Colors.blue),
                                                      Icon(Icons.star, color: Colors.blue),
                                                      Icon(Icons.star, color: Colors.blue),
                                                      Icon(Icons.star, color: Colors.blue),
                                                      Icon(Icons.star, color: Colors.grey),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),
                                                  const Text("Bien"),

                                                  const SizedBox(height: 20),

                                                  Container(
                                                    width: double.infinity,
                                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                                    child:  TextField(
                                                      controller: TextEditingController(text: ""),
                                                      keyboardType: TextInputType.multiline,
                                                      maxLines: 4,
                                                      decoration: const InputDecoration(
                                                          hintText: "Message",
                                                          focusedBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(width: 1, color: Color(0xFFF0F0F0))
                                                          ),
                                                          border: OutlineInputBorder(
                                                              borderSide: BorderSide(width: 1, color: Color(0xFFF0F0F0))
                                                          ),
                                                          fillColor: Color(0xFFFAFAFA),
                                                          filled: true
                                                      ),

                                                    ),
                                                  ),

                                                  const SizedBox(height: 20),

                                                  Container(
                                                    width: double.infinity,
                                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                                    child: DefaultButton(text: "Evaluer la course", onPress: (){

                                                      Get.to((){
                                                        return Receipt();
                                                      });

                                                    }),
                                                  )

                                                ],

                                              ),
                                            ),
                                            backgroundColor: Colors.white,
                                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))),
                                            isScrollControlled: true
                                        );

                                      }),
                                    ),
                                  )


                                ],
                              ),
                            )

                          ],
                        ),
                      ),
                    ],
                  )

                ],
              ),
            ),
          );
        });


  }

}
