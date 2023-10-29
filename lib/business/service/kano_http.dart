import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:kano/constants.dart';

const apiUrl = apiBaseUrl;


Future<dynamic> http_post(String route,Map<String, dynamic> data) async{

  log("=============== POSTING ON : $apiUrl$route ================");

  try{

    final requestPayload = jsonEncode(data);
    final headers = {'Content-Type': 'application/json'};
    var response = await http.post(Uri.parse("$apiUrl$route"), headers: headers, body: requestPayload);

    log("=============== POST RESULT ==============");
    log(response.body);
    return json.decode(response.body);

  }catch(exception){
    log("==== POST ERROR : ${exception.toString()}");
    return null;
  }

}


Future<dynamic> http_get(String route) async{

  try{

    log("=============== CALLING ON : $route ================");

    var response = await http.get(Uri.parse(apiUrl+route));

    return json.decode(response.body);

  }catch(exception){
    log("==== GET ERROR : ${exception.toString()}");
    return null;
  }

}