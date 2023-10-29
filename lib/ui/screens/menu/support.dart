import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kano/ui/screens/support/faqs.dart';
import 'package:kano/translation/translation_keys.dart' as translation;
import 'package:kano/ui/screens/profile/profile.dart';
import '../../../constants.dart';
import '../support/historiques_incidents.dart';

class Support extends StatelessWidget {
  const Support({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent, // navigation bar color
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark));
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          Column(
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
                      child: Text(translation.support.tr,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
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
            top: MediaQuery.of(context).size.height * 0.32,
            left: 20,
            right: 20,
            child: Column(
              children: [
                //car widget
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        spreadRadius: 1,
                        blurRadius: 2,
                        color: Colors.black.withOpacity(0.1),
                      )
                    ],
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 7),
                      cardItemWidget(
                        title: 'questionsFrequemmentPosees',
                        route: const FAQS(),
                      ),
                      const Divider(thickness: 1),
                      cardItemWidget(
                        title: 'historiquesIncidents',
                        route: HistoriquesIncidents(),
                      ),
                      const SizedBox(height: 7),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                //SizedBox widget
              ],
            ),
          ),
        ],
      ),
    );
  }

//cardItem widget
  Card cardItemWidget({required String title, required Widget route}) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      child: ListTile(
        onTap: () {
          Get.to(() => route);
        },
        title: Text(
          title.tr,
          style: const TextStyle(color: fontBlackColor),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_outlined, size: 17),
      ),
    );
  }

//SizedBox widget
  SizedBox sizedBoxWidget(BuildContext context,
      {required String title, required IconData icon, required Widget route}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.28,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          onTap: () {
            Get.to(() => route);
          },
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                ),
                child: Icon(
                  icon,
                  size: 17,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title.tr,
                style: const TextStyle(
                  fontSize: 12,
                  color: fontBlackColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
