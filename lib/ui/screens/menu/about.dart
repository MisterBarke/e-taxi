import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kano/constants.dart';
import 'package:kano/ui/screens/support/faqs_details.dart';
import 'package:kano/translation/translation_keys.dart' as translation;

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Flex(
            direction: Axis.vertical,
            children: [
              Expanded(flex: 1, child: Container(color: Colors.white)),
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
                      child: Text(translation.about.tr,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                          textAlign: TextAlign.center),
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1,
            right: 0,
            left: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child: Text(
                      descriptionKano,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      "V1.0.0",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: Colors.black,
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: ListTile(
                          title: const Text(
                            'AZ TRANSPORT PLUS',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          subtitle: const Text(
                            '6 rue Louis Aragon 44800 Saint-Herblain',
                            style: TextStyle(color: Colors.grey),
                          ),
                          onTap: () {
                            // Handle email button tap
                          },
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.home),
                        title: Text(
                          'Adresse',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle:
                            Text('6 rue Louis Aragon 44800 Saint-Herblain'),
                        onTap: () {
                          // Handle email button tap
                        },
                      ),
                      Divider(),
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text(
                          'Email',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('kanovtc@gmail.com'),
                        onTap: () {
                          // Handle email button tap
                        },
                      ),
                      Divider(),
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: const Text(
                          'Phone',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('+33 7 49 52 85 85'),
                        onTap: () {
                          // Handle phone button tap
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
