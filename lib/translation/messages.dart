import 'package:get/get.dart';
import 'package:kano/translation/fr.dart';

import 'en.dart';

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'fr': Fr().messages,
    'en': En().messages,
  };
}