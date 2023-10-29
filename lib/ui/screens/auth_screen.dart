import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:kano/business/controller/auth_controller.dart';
import 'package:kano/constants.dart';
import 'package:kano/ui/screens/home.dart';
import 'package:kano/ui/widgets/utils_widgets.dart';
import 'package:pinput/pinput.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthController authController = Get.put(AuthController());
  late PageController _controller;
  int currentIndex = 1;

  bool cguAccepted = false;

  bool creating = false;
  bool checkingUserInDB = false;

  TextEditingController otpController = TextEditingController();

  // User firstname
  final TextEditingController firstname = TextEditingController(text: "");

  // User lastname
  final TextEditingController lastname = TextEditingController(text: "");

  // User email
  final TextEditingController email = TextEditingController(text: "");

  // User city
  final TextEditingController city = TextEditingController(text: "");

  // User address
  final TextEditingController address = TextEditingController(text: "");

  // First screen
  final TextEditingController phone = TextEditingController(text: "");

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String initialCountry = 'BF';
  PhoneNumber number = PhoneNumber(isoCode: 'BF');

  String? userPhone;

  late String verificationId;

  bool verifyingOtp = false;
  final focusNode = FocusNode();

  final focusedBorderColor = const Color.fromRGBO(23, 171, 144, 1);
  final fillColor = const Color.fromRGBO(243, 246, 249, 0);
  final borderColor = const Color.fromRGBO(23, 171, 144, 0.4);

  Map<String, dynamic>? findedUser;

  @override
  void initState() {
    _controller = PageController(initialPage: currentIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: PageView.builder(
          itemBuilder: (_, index) {
            if (index == 0) {
              return _buildRegistrationPage();
            } else if (index == 1) {
              return _buildLoginPage();
            } else if (index == 2) {
              return _buildOtpPage();
            } else {
              return _buildRegistrationSuccess();
            }
          },
          itemCount: 4,
          physics: const NeverScrollableScrollPhysics(),
          controller: _controller,
        ),
      ),
    );
  }

  Widget _buildRegistrationPage() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            color: Colors.white,
            width: double.infinity,
            child: const Text("Créer un compte",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: 18)),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                border: Border.all(color: colorBlue, width: 1),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5))),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.info_outline),
                                SizedBox(width: 10),
                                Flexible(
                                    flex: 1,
                                    child: Text(
                                        "Vous n’avez pas un compte merci de completer les informations pour créer"))
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text("NOM",
                              style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 6),
                          AdvancedTextField(
                              controller: lastname, hint: "", icon: null),
                          const SizedBox(height: 20),
                          const Text("PRENOM",
                              style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 6),
                          AdvancedTextField(
                              controller: firstname, hint: "", icon: null),
                          const SizedBox(height: 20),
                          const Text("EMAIL",
                              style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 6),
                          AdvancedTextField(
                              controller: email, hint: "", icon: null),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Checkbox(
                                  value: cguAccepted,
                                  onChanged: (value) {
                                    cguAccepted = value!;
                                    setState(() {});
                                  }),
                              const Flexible(
                                child: Text(
                                    "J'ACCEPTE LES CONDITIONS D'UTILISTATIONS",
                                    style: TextStyle(
                                        fontSize: 12,
                                        overflow: TextOverflow.ellipsis),
                                    maxLines: 1),
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                          buildWidget(() {
                            return creating
                                ? const SpinKitThreeBounce(
                                    color: Colors.blue,
                                    size: 40,
                                  )
                                : SizedBox(
                                    width: double.infinity,
                                    child: DefaultButton(
                                        text: "Créer mon compte",
                                        onPress: () {
                                          if (firstname.text.isEmpty) {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Veuillez saisir votre prénom !");
                                            return;
                                          }
                                          if (lastname.text.isEmpty) {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Veuillez saisir votre nom de famille !");
                                            return;
                                          }
                                          if (email.text.isEmpty) {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Veuillez saisir votre adresse email !");
                                            return;
                                          }

                                          if (!cguAccepted ||
                                              number.phoneNumber == null) {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Veuillez accepter les conditions générales d'utilisation");
                                            return;
                                          }

                                          _sendOtpCode();
                                        }));
                          }),
                        ],
                      ))
                ],
              ),
            ),
          ),
          _buildMentionLegales()
        ],
      ),
    );
  }

  Widget _buildLoginPage() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Image.asset(
                            "assets/images/illustration_login.jpg",
                            height: 170,
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          "CONNEXION",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 40),
                        const SizedBox(height: 6),
                        InternationalPhoneNumberInput(
                          onInputChanged: (PhoneNumber number) {
                            setState(() {
                              this.number = number;
                            });
                          },
                          selectorConfig: const SelectorConfig(
                            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                            setSelectorButtonAsPrefixIcon: true,
                            leadingPadding: 20,
                            useEmoji: true,
                          ),
                          ignoreBlank: false,
                          selectorTextStyle: TextStyle(color: Colors.black),
                          textFieldController: phone,
                          formatInput: false,
                          inputDecoration:
                              getAddressInputDecoration("Numéro de téléphone"),
                          keyboardType: const TextInputType.numberWithOptions(
                              signed: true, decimal: true),
                          countries: ["FR"],
                          //initialValue: PhoneNumber(isoCode: "FR"),
                          inputBorder: const OutlineInputBorder(),
                          onSaved: (PhoneNumber number) {
                            print('On Saved: $number');
                          },
                        ),
                        const SizedBox(height: 20),
                        checkingUserInDB
                            ? const SpinKitThreeBounce(
                                color: Colors.blue,
                                size: 40,
                              )
                            : SizedBox(
                                width: double.infinity,
                                child: DefaultButton(
                                    text: "Se connecter",
                                    onPress: () {
                                      if (number.phoneNumber == null) {
                                        Fluttertoast.showToast(
                                            msg:
                                                "Veuillez saisir un numéro de téléphone valide !");
                                        return;
                                      }

                                      setState(() {
                                        checkingUserInDB = true;
                                        userPhone = number.phoneNumber;
                                      });

                                      authController
                                          .findUser(number.phoneNumber!)
                                          .then((value) {
                                        // Si l'utilisateur n'existe pas dans la base de donnée
                                        if (value.docs.isEmpty) {
                                          _controller.animateToPage(0,
                                              curve: Curves.linear,
                                              duration: const Duration(
                                                  milliseconds: 600));
                                          setState(() {
                                            currentIndex = 0;
                                          });
                                        }
                                        //only for google play logging
                                        else if (value.docs.isNotEmpty &&
                                            number.phoneNumber ==
                                                "+22662723688") {
                                          setState(() {
                                            findedUser =
                                                value.docs.first.data();
                                          });
                                          FirebaseAuth.instance
                                              .signInWithEmailAndPassword(
                                                  email: "62723688@gmail.com",
                                                  password: "123456")
                                              .then((data) {
                                            authController.updateUserTokenId(
                                                value.docs.first.data()["uid"],
                                                {
                                                  ...findedUser!,
                                                  "tokenID": authController
                                                      .tokenID.value,
                                                  "uid": value.docs.first
                                                      .data()["uid"]
                                                });
                                            authController
                                                .saveUserInfos(findedUser);
                                            _openHomePage();
                                          });
                                        } else {
                                          setState(() {
                                            findedUser =
                                                value.docs.first.data();
                                          });

                                          _sendOtpCode();
                                          _controller.animateToPage(2,
                                              curve: Curves.linear,
                                              duration: const Duration(
                                                  milliseconds: 600));
                                        }
                                      });
                                    })),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildMentionLegales()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The function that creates the otp page
  Widget _buildOtpPage() {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );

    return SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {},
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    child: const Text("Vérifier le code",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 40)
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                Text(
                  "Un code a été envoyer au \n"
                  "${phone.text} via SMS",
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Form(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: Get.width - 20,
                            child: Pinput(
                              length: 6,
                              controller: otpController,
                              focusNode: focusNode,
                              androidSmsAutofillMethod:
                                  AndroidSmsAutofillMethod.smsUserConsentApi,
                              listenForMultipleSmsOnAndroid: true,
                              defaultPinTheme: defaultPinTheme,
                              hapticFeedbackType:
                                  HapticFeedbackType.lightImpact,
                              onCompleted: (pin) {
                                debugPrint('onCompleted: $pin');
                              },
                              onChanged: (value) {
                                debugPrint('onChanged: $value');
                              },
                              cursor: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 9),
                                    width: 22,
                                    height: 1,
                                    color: focusedBorderColor,
                                  ),
                                ],
                              ),
                              focusedPinTheme: defaultPinTheme.copyWith(
                                decoration:
                                    defaultPinTheme.decoration!.copyWith(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: focusedBorderColor),
                                ),
                              ),
                              submittedPinTheme: defaultPinTheme.copyWith(
                                decoration:
                                    defaultPinTheme.decoration!.copyWith(
                                  color: fillColor,
                                  borderRadius: BorderRadius.circular(19),
                                  border: Border.all(color: focusedBorderColor),
                                ),
                              ),
                              errorPinTheme: defaultPinTheme.copyBorderWith(
                                border: Border.all(color: Colors.redAccent),
                              ),
                            ))
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                creating
                    ? const SpinKitThreeBounce(
                        color: Colors.blue,
                        size: 40,
                      )
                    : InkWell(
                        child: const Text("Renvoyer le sms",
                            style: TextStyle(
                                color: Colors.grey,
                                decoration: TextDecoration.underline)),
                        onTap: () {
                          _sendOtpCode();
                        },
                      ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            width: double.infinity,
            child: verifyingOtp
                ? const SpinKitThreeBounce(
                    color: Colors.blue,
                    size: 40,
                  )
                : DefaultButton(
                    text: "Confirmer",
                    onPress: () {
                      setState(() {
                        verifyingOtp = true;
                      });
                      final otp = otpController.text;

                      authController
                          .signInWithOtp(otp, verificationId)
                          .then((value) {
                        setState(() {
                          verifyingOtp = false;
                        });

                        if (value != null && value.user != null) {
                          Fluttertoast.showToast(
                              msg: "Authentifié avec succès !");

                          if (currentIndex == 0) {
                            final user = {
                              'uid': value.user!.uid,
                              'firstname': firstname.text,
                              'lastname': lastname.text,
                              'phone': number.phoneNumber,
                              'email': email.text,
                              'city': "",
                              'address': "",
                              'dueAmount': 0,
                              "tokenID": authController.tokenID.value
                            };

                            authController.registerUser(user).then((value) {
                              authController.saveUserInfos(user);
                              _controller.jumpToPage(3);
                            });
                          } else {
                            authController.updateUserTokenId(value.user!.uid, {
                              ...findedUser!,
                              "tokenID": authController.tokenID.value,
                              "uid": value.user!.uid
                            });
                            authController.saveUserInfos(findedUser);
                            _openHomePage();
                          }
                        } else {
                          Fluttertoast.showToast(
                              msg: "Code invalide veuillez réessayer !");
                        }
                      });
                    },
                  ),
          ),
          const SizedBox(height: 20)
        ],
      ),
    );
  }

  _buildMentionLegales() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("KANO 1.0.0"),
          const SizedBox(width: 10),
          InkWell(
            child: const Text("Mentions légales",
                style: TextStyle(color: Colors.blue)),
            onTap: () {
              //
            },
          ),
        ],
      ),
    );
  }

  _buildRegistrationSuccess() {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 4,
                )
              ]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/ic_success.png",
                      width: 80, height: 80),
                  const SizedBox(height: 20),
                  const Text("Felicitations",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  const SizedBox(height: 20),
                  const Text(
                      "Votre compte est bien crée. Cliquez sur continuer"),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: DefaultButton(
                  text: "Continuer",
                  onPress: () {
                    _openHomePage();
                  }),
            )
          ],
        ),
      ),
    );
  }

  void _sendOtpCode() {
    setState(() {
      creating = true;
    });

    authController.verifyPhoneNumber(userPhone!,
        verificationCompleted: (AuthCredential credential) async {
      Fluttertoast.showToast(msg: "Code OTP vérifié avec succès !");

      setState(() {
        creating = false;
      });
    }, verificationFailed: (FirebaseAuthException exception) {
      // OTP verification failed.
      Fluttertoast.showToast(msg: exception.toString());
      setState(() {
        creating = false;
      });
    }, codeSent: (code, resendToken) {
      setState(() {
        verificationId = code;
        creating = false;
      });

      _controller.jumpToPage(2);
    }, codeAutoRetrievalTimeout: (String verificationId) {
      // OTP auto retrieval timed out.
      // Handle the error.

      setState(() {
        creating = false;
      });
    });
  }

  void _openHomePage() {
    Get.to(() => const AppHome());
  }
}

class OptField extends StatelessWidget {
  final Function onSaved;
  final TextEditingController controller;

  const OptField({Key? key, required this.onSaved, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 50,
      child: TextFormField(
        maxLines: 1,
        controller: controller,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.blue, fontSize: 25, fontWeight: FontWeight.bold),
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly
        ],
        decoration: getInputDeco(),
        cursorColor: Colors.blue,
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          } else {
            FocusScope.of(context).previousFocus();
          }
        },
        onSaved: (value) {
          onSaved(value);
        },
      ),
    );
  }

  getInputDeco() {
    return const InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      fillColor: Color(0x00ffffff),
      filled: true,
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }
}
