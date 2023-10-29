import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kano/constants.dart';
import 'package:kano/ui/screens/support/faqs_details.dart';
import 'package:kano/translation/translation_keys.dart' as translation;

class FAQS extends StatelessWidget {
  const FAQS({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  Flexible(
                    child: SizedBox(
                      width: double.maxFinite,
                      child: Text('foireAuxQuestions'.tr,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                          textAlign: TextAlign.center),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 30),
                  titleWidget(title: 'compte'),
                  const SizedBox(height: 20),
                  carWidget(title: translation.deverouillerCompte.tr),
                  divider(),
                  carWidget(title: translation.changerDeNumeroDeTelephone.tr),
                  divider(),
                  carWidget(title: translation.confidentialite.tr),
                  divider(),
                  const SizedBox(height: 20),
                  titleWidget(title: 'kano'),
                  const SizedBox(height: 20),
                  carWidget(title: translation.modesDePaiementAcceptes.tr),
                  divider(),
                  carWidget(title: translation.appreciationDuVoyage.tr),
                  divider(),
                  carWidget(title: translation.paiementDannulationDeVoyage.tr),
                  divider(),
                  carWidget(title: translation.prixPlusEleveQuePrevu.tr),
                  divider(),
                  carWidget(title: translation.changerDeNumeroDeTelephone.tr),
                  divider(),
                  carWidget(title: translation.confidentialite.tr),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Divider divider() => const Divider(
        endIndent: 20,
        thickness: 1,
        indent: 20,
      );

  //car widget
  Card carWidget({
    required String title,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      child: ListTile(
        onTap: () {
          Get.to(
            () => FaqsDetails(),
            fullscreenDialog: true,
            arguments: {'title': title},
          );
        },
        title: Text(
          title.tr,
          style: const TextStyle(color: fontBlackColor),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_outlined, size: 17),
      ),
    );
  }

  //title widget
  Card titleWidget({
    required String title,
    double size = 18,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      child: ListTile(
        title: Text(
          title.tr,
          style: TextStyle(
            fontSize: size,
            fontWeight: fontWeight,
            color: fontBlackColor,
          ),
        ),
      ),
    );
  }
}
