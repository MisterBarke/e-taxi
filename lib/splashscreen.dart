import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'business/controller/splashscreen_controller.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final splashScreenController = Get.put(SplashScreenController());

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellowAccent,
      height: MediaQuery.of(context).size.height * 1,
      child: Column(
        children: [
          const Spacer(),
          Image.asset(
            'assets/images/logo_kano.png',
            height: 150,
            width: 150,
          ),
          const Spacer(),
          const Text(
            "V1",
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
