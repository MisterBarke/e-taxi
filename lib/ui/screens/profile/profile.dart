import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kano/business/controller/profile_controller.dart';
import 'package:kano/constants.dart';
import 'package:kano/translation/translation_keys.dart' as translation;
import 'package:kano/ui/screens/profile/edit_profile.dart';
import 'package:kano/ui/screens/profile/edit_adresses_favorites.dart';

class Profile extends StatelessWidget {
  Profile({super.key});

  final profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    profileController.getUser();
    return Scaffold(
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
                        Expanded(
                          flex: 4,
                          child: Container(
                            color: colorYellow,
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Container(
                            color: Colors.white,
                          ),
                        )
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
                                child: Text(translation.monProfile.tr,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.1,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: profileController.user["docsPhoto"] ==
                                        null
                                    ? Image.asset(
                                        "assets/images/default_avatar.png",
                                        width: 100,
                                        height: 100,
                                      )
                                    : CircleAvatar(
                                        radius: 50,
                                        backgroundImage: NetworkImage(
                                          profileController.user["docsPhoto"]
                                              ["link"],
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 20),
                              //profile info items widget
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
                                    profileInfosItemsWidget(
                                      title: translation.firstName.tr,
                                      contenu:
                                          "${profileController.user["firstname"]}",
                                      type: 'firstname',
                                    ),
                                    divider(),
                                    profileInfosItemsWidget(
                                      title: translation.lastName.tr,
                                      contenu:
                                          '${profileController.user["lastname"]}',
                                      type: 'lastname',
                                    ),
                                    divider(),
                                    profileInfosItemsWidget(
                                      title: translation.email.tr,
                                      contenu:
                                          '${profileController.user["email"]}',
                                      type: 'email',
                                    ),
                                    divider(),
                                    profileInfosItemsWidget(
                                      title: translation.telephone.tr,
                                      contenu:
                                          '${profileController.user["phone"]}',
                                      type: 'phone',
                                    ),
                                    divider(),
                                    profileInfosItemsWidget(
                                      title: translation.ville.tr,
                                      contenu:
                                          '${profileController.user["city"]}',
                                      type: 'city',
                                    ),
                                    divider(),
                                    profileInfosItemsWidget(
                                      title: translation.adresse.tr,
                                      contenu:
                                          profileController.user["address"] ??
                                              "Pas d'adresse",
                                      type: 'address',
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),
                              SizedBox(
                                height: 40,
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(
                                        Colors.red[400]),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15))),
                                  ),
                                  onPressed: () {
                                    Get.defaultDialog(
                                      title: "Déconnexion",
                                      middleText:
                                          "Voulez-vous vraiment vous déconnectez ?",
                                      textCancel: "NON",
                                      textConfirm: "OUI",
                                      confirmTextColor: Colors.white,
                                      onConfirm: () {
                                        profileController.signOut();
                                      },
                                      radius: 5,
                                    );
                                  },
                                  child: Text(
                                    translation.seDeconnecter.tr,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
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

  Card profileInfosItemsWidget(
      {required String title, required String contenu, required String type}) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      child: ListTile(
        onTap: () {
          title == translation.telephone.tr || title == translation.email.tr
              ? null
              : Get.to(
                  () => EditProfile(),
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
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing:
            title == translation.telephone.tr || title == translation.email.tr
                ? const Icon(Icons.check_circle, color: Colors.green, size: 15)
                : const Icon(Icons.arrow_forward_ios, size: 15),
      ),
    );
  }

  Divider divider() => const Divider(thickness: 1, height: 1);
}
