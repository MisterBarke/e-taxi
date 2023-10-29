import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kano/ui/widgets/utils_widgets.dart';

class BounceInBottomSheet extends StatefulWidget {

  final String message;

  const BounceInBottomSheet({super.key, required this.message});

  @override
  State<BounceInBottomSheet> createState() => _BounceInBottomSheetState();
}

class _BounceInBottomSheetState extends State<BounceInBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.bounceIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 10),

            DefaultButton(text: "OK", onPress: (){
              Get.back();
            })

          ]
        ),
      ),
    );
  }
}