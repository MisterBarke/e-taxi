import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kano/translation/translation_keys.dart' as translation;
class FaqsDetails extends StatelessWidget {
  final args = Get.arguments;
  FaqsDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                        args['title'].toString().tr,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
