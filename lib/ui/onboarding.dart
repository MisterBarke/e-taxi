import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kano/ui/screens/auth_screen.dart';
import 'package:kano/ui/widgets/utils_widgets.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  late PageController _controller;
  int currentIndex = 0;

  final contents = [
    {
      'image': 'assets/images/img.png',
      'title': 'Commander une course tres simplement',
      'description':
          'Notre application révolutionnaire simplifie la réservation de courses. En quelques clics, commandez une course sans tracas.'
    },
    {
      'image': 'assets/images/intro_4.jpg',
      'title': 'Disponible 24h/24 et 7j/7',
      'description':
          'Nous comprenons que vos besoins en matière de transport peuvent survenir à tout moment.'
    },
    {
      'image': 'assets/images/intro_2.png',
      'title': 'Plusieurs moyens de paiement',
      'description':
          'Notre application vous offre une variété de moyens de paiement pour votre confort.'
    },
    {
      'image': 'assets/images/intro_3.png',
      'title': 'Suivez le trajet en direct',
      'description':
          'Plus besoin de deviner où se trouve votre chauffeur ou de vous inquiéter de l\'heure d\'arrivée.'
    },
  ];

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemBuilder: (_, index) {
                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(contents[index]['image'].toString(),
                          height: 200, width: 200),
                      const SizedBox(height: 30),
                      Text(
                        contents[index]['title'].toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(height: 20),
                      Text(contents[index]['description'].toString(),
                          textAlign: TextAlign.center),
                      _buildButton(index)
                    ],
                  ),
                );
              },
              controller: _controller,
              itemCount: contents.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.all(2),
                  height: 10,
                  width: currentIndex == index ? 25 : 10,
                  decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(40))),
                );
              }),
            ),
          )
        ],
      ),
    );
  }

  _buildButton(index) {
    return index != (contents.length - 1)
        ? Container()
        : Column(
            children: [
              const SizedBox(height: 50),
              DefaultButton(
                  text: "Terminer",
                  onPress: () {
                    Get.offAll(() {
                      return AuthScreen();
                    });
                  })
            ],
          );
  }
}
