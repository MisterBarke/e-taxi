import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kano/business/controller/profile_controller.dart';
import 'package:kano/constants.dart';
import 'package:kano/translation/translation_keys.dart' as translation;
import 'package:kano/ui/screens/profile/edit_adresses_favorites_map.dart';
import 'package:kano/ui/screens/profile/profile.dart';

class EditProfileAdressesFavorites extends StatelessWidget {
  final args = Get.arguments;
  final inputText = TextEditingController();
  final _key = GlobalKey<FormState>();
  final editAdressesCtrl = Get.put(ProfileController());
  EditProfileAdressesFavorites({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GetX<ProfileController>(
        builder: (ctrl) {
          return SafeArea(
            child: Column(
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
                //edit form
                Form(
                  key: _key,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20,20,20,5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: inputText,
                          decoration: const InputDecoration(
                            hintText:
                                "Entrer l'adresse ici",
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: inputGreyColor,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                          ),
                          onChanged: (value) {
                            ctrl.searchAddress(value);
                          },
                        ),
                        const SizedBox(height: 10),
                        //bouton choisir sur une carte
                        TextButton(
                          onPressed: () {
                            Get.off(
                              () => EditAdresseFavoritesMap(),
                              fullscreenDialog: true,
                              arguments: {
                                'title':
                                    args['title'].toString().toLowerCase().tr,
                                "type": args['type'],
                              },
                            );
                          },
                          child: Text(
                            translation.useMap.tr,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //affichages des suggestions d'adresses
                ctrl.addressesSearchResult.isNotEmpty
                    ? Expanded(
                        child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                            itemBuilder: (context, index) {
                              return InkWell(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                          color: Color(0XFFF0F0F0)),
                                      child: const Icon(Icons.location_pin),
                                    ),
                                    const SizedBox(width: 20),
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(15),
                                        decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                width: 1,
                                                color: Color(0XFFF0F0F0),
                                              ),
                                            ),
                                            color: Colors.white),
                                        child: Text(
                                            ctrl.addressesSearchResult[index]),
                                      ),
                                    )
                                  ],
                                ),
                                onTap: () {
                                  ctrl.updateAddressField(args['type']);
                                  ctrl.geocode(
                                      ctrl.addressesSearchResult[index]);
                                  inputText.clear();
                                  ctrl.addressesSearchResult.clear();
                                  Future.delayed(const Duration(seconds: 1),
                                      () {
                                    Get.back();
                                  });
                                },
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(height: 0);
                            },
                            itemCount: ctrl.addressesSearchResult.length),
                      )
                    : ctrl.isUpdateLoading.value
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.only(top: 80),
                            child: Text(
                              translation.aucuneAddresseTrouve.tr,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                ctrl.isUpdateLoading.value
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator.adaptive(),
                          Container(
                            margin: const EdgeInsets.only(left: 20),
                            child: const Text("Chargement..."),
                          )
                        ],
                      )
                    : Container()
              ],
            ),
          );
        },
      ),
    );
  }
}
