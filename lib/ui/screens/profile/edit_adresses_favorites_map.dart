import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kano/business/controller/profile_controller.dart';
import 'package:kano/business/model/address.dart';
import 'package:kano/business/service/google_service.dart';
import 'package:kano/constants.dart';
import 'package:kano/translation/translation_keys.dart' as translation;
import 'package:kano/ui/screens/profile/profile.dart';
import 'package:kano/ui/widgets/utils_widgets.dart';

class EditAdresseFavoritesMap extends StatelessWidget {
  final args = Get.arguments;
  final inputText = TextEditingController();
  final editAdressesCtrl = Get.put(ProfileController());
  GoogleMapController? _controller;
  EditAdresseFavoritesMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GetX<ProfileController>(
        builder: (ctrl) {
          return Stack(
            children: [
              //google maps
              SizedBox(
                height: double.infinity,
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    //innital position in map
                    target: LatLng(
                      12.3917911,
                      -1.4806899,
                    ), //initial position
                    zoom: 12.0, //initial zoom level
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                  },
                  myLocationEnabled: true,
                  mapToolbarEnabled: false,
                  //calcul les coordonnes du centre de l'ecran du google maps visible
                  onCameraIdle: () async {
                    ctrl.loadingAddress(true);

                    LatLngBounds bounds = await _controller!.getVisibleRegion();
                    final lon = (bounds.northeast.longitude +
                            bounds.southwest.longitude) /
                        2;
                    final lat = (bounds.northeast.latitude +
                            bounds.southwest.latitude) /
                        2;

                    Address? address =
                        await GoogleService.decode(LatLng(lat, lon));

                    ctrl.loadingAddress(false);

                    if (address != null) {
                      ctrl.selected = address;
                    } else {
                      Fluttertoast.showToast(msg: "Adresse introuvable !");
                    }
                  },
                ),
              ),
              //buil for input
              Positioned(
                top: MediaQuery.of(context).size.height * 0.15,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    //user select position input container widget
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 3,
                              blurRadius: 2)
                        ],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25)),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 35,
                            child: TextField(
                              decoration:
                                  getAddressInputDecoration(args['title']),
                              controller: TextEditingController(
                                  text: ctrl.selected?.description),
                              onChanged: (value) {
                                ctrl.searchAddress(value);
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            child: const Text(
                              "Quitter la carte",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              Get.back();
                            },
                          )
                        ],
                      ),
                    ),
                    //linear progress indicator container widget
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: ctrl.loadingAddress.value
                          ? const LinearProgressIndicator()
                          : null,
                    )
                  ],
                ),
              ),
              //build for the pin
              Center(
                child: Image.asset(
                  "assets/images/start_pin.png",
                  height: 60,
                  width: 60,
                ),
              ),

              //build for the "app bar"
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
                      Flexible(
                        child: SizedBox(
                          width: double.maxFinite,
                          child: Text(
                            "${translation.modifier.tr} ${args['title'].toString().toLowerCase().tr}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              //affiche le bonton confirmer
              !ctrl.loadingAddress.value && ctrl.selected != null
                  ? Positioned(
                      bottom: 10,
                      child: Container(
                        width: Get.width,
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: DefaultButton(
                          text: "Confirmer l'addresse",
                          onPress: () {
                            if (ctrl.selected == null) return;
                            ctrl.updateAddressField(args["type"]);
                            ctrl.geocode(ctrl.selected?.description);
                            Future.delayed(const Duration(seconds: 1), () {
                              Get.back();
                            });
                          },
                        ),
                      ),
                    )
                  : Container(),
              ctrl.isUpdateLoading.value
                  ? const Center(
                      child: CircularProgressIndicator.adaptive(
                        backgroundColor: Colors.white,
                      ),
                    )
                  : Container()
            ],
          );
        },
      ),
    );
  }
}
