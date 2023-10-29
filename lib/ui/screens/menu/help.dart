import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kano/translation/translation_keys.dart' as translation;

import '../../../business/controller/profile_controller.dart';
import '../../../constants.dart';
import '../profile/edit_adresses_favorites.dart';

class Help extends StatelessWidget {
  Help({Key? key}) : super(key: key);
  final profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    profileController.getUser();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () {
          return profileController.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator.adaptive(),
                )
              : Stack(
                  children: [
                    Flex(
                      direction: Axis.vertical,
                      children: [
                        Expanded(flex: 4, child: Container(color: colorYellow)),
                        const Expanded(flex: 6, child: Text(''))
                      ],
                    ),
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
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(100)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 3,
                                        blurRadius: 2,
                                      )
                                    ]),
                                child: const Icon(
                                    Icons.arrow_back_ios_new_outlined,
                                    size: 17),
                              ),
                              onTap: () {
                                Get.back();
                              },
                            ),
                            Flexible(
                              child: SizedBox(
                                width: double.maxFinite,
                                child: Text(translation.setting.tr,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 18,
                                    ),
                                    textAlign: TextAlign.center),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.25,
                      left: 20,
                      right: 20,
                      bottom: 0,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 10,
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.black,
                                ),
                                Text(
                                  translation.adressesFavoris.tr,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    color: Colors.black.withOpacity(0.1),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white,
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  adressesFavorisItemsWidget(
                                    title: translation.maison.tr,
                                    contenu: profileController
                                                .user["homeLocation"] ==
                                            null
                                        ? "Pas d'adresse"
                                        : profileController.user["homeLocation"]
                                            ["address"],
                                    type: 'homeLocation',
                                  ),
                                  divider(),
                                  adressesFavorisItemsWidget(
                                    title: translation.travail.tr,
                                    contenu: profileController
                                                .user["workLocation"] ==
                                            null
                                        ? "Pas d'adresse"
                                        : profileController.user["workLocation"]
                                            ["address"],
                                    type: 'workLocation',
                                  ),
                                  divider(),
                                  adressesFavorisItemsWidget(
                                    title: translation.gym.tr,
                                    contenu: profileController
                                                .user["gymLocation"] ==
                                            null
                                        ? "Pas d'adresse"
                                        : profileController.user["gymLocation"]
                                            ["address"],
                                    type: 'gymLocation',
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }

  //adresse favoris items widget
  Card adressesFavorisItemsWidget({
    required String title,
    required String contenu,
    required String type,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      child: ListTile(
        onTap: () {
          Get.to(
            () => EditProfileAdressesFavorites(),
            fullscreenDialog: true,
            arguments: {'title': title, "type": type},
          );
        },
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: fontBlackColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              contenu,
              style: TextStyle(
                color: contenu == "Pas d'adresse" ? Colors.grey : Colors.black,
                fontSize: 15,
                fontWeight: contenu == "Pas d'adresse"
                    ? FontWeight.normal
                    : FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: title == translation.telephone.tr
            ? const Icon(Icons.check_circle, color: Colors.green, size: 15)
            : const Icon(Icons.arrow_forward_ios, size: 15),
      ),
    );
  }

  Divider divider() => const Divider(
        thickness: 1,
        height: 1,
      );
}
