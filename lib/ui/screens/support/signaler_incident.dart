import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kano/business/controller/signaler_incident_controller.dart';
import '../../../constants.dart';

class SignalerIncident extends StatelessWidget {
  SignalerIncident({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();
  final signalerIncidentController = Get.put(SignalerIncidentController());
  final args = Get.arguments;

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
                          child: Text("Signaler un incident",
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
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    children: [
                      const Text(
                        'Si vous avez eu un incident, vous devrez nous envoyer un message immédiatement, assurez-vous de nous fournir autant de détails que possible sur l\'incident.',
                        style: TextStyle(),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Description",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.black54,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller:
                                  signalerIncidentController.description.value,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: inputGreyColor,
                                hintText: "Entrer votre message ici",
                                hintStyle: TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'veuillezSaissirUnMessage'.tr;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Image",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.black54,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 10),
                            signalerIncidentController.image.value == null
                                ? Card(
                                    color: inputGreyColor,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: SizedBox(
                                      height: 150,
                                      width: double.infinity,
                                      child: IconButton(
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (builder) {
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ListTile(
                                                    onTap: () {
                                                      signalerIncidentController
                                                          .index(1);
                                                      signalerIncidentController
                                                          .pickImage();
                                                      Get.back();
                                                    },
                                                    title: const Text(
                                                        "Choisir une photo"),
                                                  ),
                                                  ListTile(
                                                    onTap: () {
                                                      signalerIncidentController
                                                          .index(2);
                                                      signalerIncidentController
                                                          .pickImage();
                                                      Get.back();
                                                    },
                                                    title: const Text(
                                                        "Prendre une photo"),
                                                  )
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        icon: Icon(
                                          Icons.photo_camera,
                                          color: Colors.grey.withOpacity(0.5),
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.2,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: FileImage(
                                          File(signalerIncidentController
                                              .image.value!.path),
                                        ),
                                      ),
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        signalerIncidentController
                                            .deleteImage();
                                      },
                                      icon: const Icon(
                                        Icons.delete_forever,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                            const SizedBox(height: 25),
                            if (signalerIncidentController.isLoading.value)
                              const Center(
                                child: CircularProgressIndicator.adaptive(),
                              )
                            else
                              SizedBox(
                                height: 50,
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate() &&
                                        signalerIncidentController
                                                .image.value !=
                                            null) {
                                      signalerIncidentController
                                          .orderId(args["orderId"]);
                                      signalerIncidentController
                                          .userName(args["userName"]);
                                      signalerIncidentController
                                          .driverName(args["driverName"]);
                                      signalerIncidentController
                                          .uploadImageToFirebaseStorage();
                                    }
                                  },
                                  child: Text(
                                    'Envoyer'.tr,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
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
