import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kano/business/controller/profile_controller.dart';
import 'package:kano/constants.dart';
import 'package:kano/translation/translation_keys.dart' as translation;

class EditProfile extends StatelessWidget {
  EditProfile({super.key});
  final args = Get.arguments;
  final inputText = TextEditingController();
  final _key = GlobalKey<FormState>();
  final profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: Obx(
        () {
          return Column(
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: profileController.inputText.value,
                        decoration: InputDecoration(
                          hintText:
                              "Entrer votre ${args['title'].toString().toLowerCase().tr} ici",
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: inputGreyColor,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requis*';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      profileController.isUpdateLoading.value
                          ? const CircularProgressIndicator.adaptive()
                          : SizedBox(
                              height: 40,
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15))),
                                ),
                                onPressed: () {
                                  if (_key.currentState!.validate()) {
                                    profileController.updateField(args['type']);
                                    profileController.updateUser();
                                    profileController.inputText.value.text = '';
                                    Get.back();
                                  }
                                },
                                child: Text(
                                  translation.enregister.tr,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      )),
    );
  }
}
