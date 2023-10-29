import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kano/constants.dart';

class DefaultButton extends StatelessWidget {
  final String text;
  final Color background;
  final Color textColor;
  final Function onPress;

  const DefaultButton(
      {Key? key,
      required this.text,
      this.background = Colors.blue,
      this.textColor = Colors.white,
      required this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          onPress();
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(background),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          )),
        ),
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 30),
            child: Text(
              text,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            )));
  }
}

class AdvancedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? icon;

  final bool isObscure;
  TextInputType inputType;

  AdvancedTextField(
      {Key? key,
      required this.controller,
      required this.hint,
      this.icon,
      this.isObscure = false,
      this.inputType = TextInputType.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          border: Border.all(color: const Color(0XFFf0f0f0), width: 1)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(icon == null ? 0 : 8),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(100))),
            child: icon == null
                ? null
                : Icon(
                    icon,
                    color: Colors.blue,
                    size: 22,
                  ),
          ),
          Flexible(
              flex: 1,
              child: TextField(
                style: TextStyle(
                    color: Colors.black54, fontWeight: FontWeight.w600),
                obscureText: isObscure,
                keyboardType: inputType,
                decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    fillColor: inputGreyColor,
                    hintText: hint,
                    filled: true,
                    // labelText: hint,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.white.withOpacity(0), width: 0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.white.withOpacity(0), width: 0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.white.withOpacity(0), width: 0),
                    ),
                    errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1)),
                    hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500)),
                textAlign: TextAlign.start,
                controller: controller,
                cursorColor: Colors.black,
              ))
        ],
      ),
    );
  }

  InputDecoration getDefaultInputDecoration(hint) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      fillColor: const Color(0XFFf2f6fc),
      filled: true,
      //hintText: hint,
      // labelText: hint,
      border: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF504F4F), width: 1),
          borderRadius: BorderRadius.all(Radius.circular(4))),
      enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF333232), width: 1),
          borderRadius: BorderRadius.all(Radius.circular(4))),
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(4)),
      errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1)),
    );
  }
}

InputDecoration getAddressInputDecoration(hint,
    {background = const Color(0XFFf2f6fc), hintMaxLines = 1}) {
  return InputDecoration(
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
    fillColor: background,
    filled: true,
    hintText: hint,
    hintMaxLines: hintMaxLines,
    //hintText: hint,
    // labelText: hint,
    border: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFFAFAFA), width: 1),
        borderRadius: BorderRadius.all(Radius.circular(4))),
    enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFFAFAFA), width: 1),
        borderRadius: BorderRadius.all(Radius.circular(4))),
    disabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFFAFAFA), width: 1),
        borderRadius: BorderRadius.all(Radius.circular(4))),
    focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFFAFAFA), width: 1),
        borderRadius: BorderRadius.circular(4)),
    errorBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 1),
    ),
  );
}

Widget buildWidget(Function consumer) {
  return consumer();
}

Container buildDragger() {
  return Container(
    height: 5,
    width: 50,
    decoration: const BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(20))),
  );
}

Text getStatusTextWidget(int status) {
  var text = "";
  var color = Colors.deepOrange;
  switch (status) {
    case 1:
      text = "En attente du chauffeur";
      color = Colors.orange;
      break;
    case 2:
      text = "En cours";
      color = Colors.green;
      break;
    case 3:
      text = "Terminée non payé";
      color = Colors.lightGreen;
      break;
    case 4:
      text = "Terminée";
      color = Colors.green;
      break;
    case -1:
      text = "Annulée, non due";
      color = Colors.red;
      break;
    case -2:
      text = "Annulée, due";
      color = Colors.red;
      break;
    case -3:
      text = "A venir";
      color = Colors.grey;
      break;
    default:
  }
  return Text(
    text,
    textAlign: TextAlign.right,
    style: TextStyle(
      fontWeight: FontWeight.bold,
      color: color,
    ),
  );
}

formatDate(int timeStamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
  return DateFormat('dd/MM/yyyy, HH:mm').format(date);
}

dateFormat(dynamic timestamp, {required String format}) {
  if (timestamp != null) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
    return DateFormat(format).format(date);
  }
}
