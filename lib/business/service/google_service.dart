import 'dart:convert';
import 'package:google_geocoding/google_geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart' as places;
import 'package:http/http.dart' as http;
import 'package:kano/business/model/address.dart';
import 'package:kano/constants.dart';
import 'package:kano/translation/translation_keys.dart';

class GoogleService{

  // Recherche d'adresse
  static Future<List<String>> filterAddress(String query) async {

    query = query.replaceAll(" ", "+");

    try{

      final response = await http.get(Uri.parse(
          "https://maps.googleapis.com/maps/api/place/autocomplete/json"
          "?key=$kGoogleApiKey&input=$query&sensor=true"
      ));

     List<String> list =  _parseAddress(jsonDecode(response.body));
     return list;

    }on Exception catch(e){
      return [];
    }

  }

  static _parseAddress(dynamic data){

    List<String> list = [];
    final predictions = data["predictions"] as List<dynamic>;

    for(int i = 0; i < predictions.length; i++){
      list.add(predictions[i]['description']);
    }

    return list;

  }

  // Transforme une adresse textuelle en coordonnées gps
  static Future<Location?> geocode(String address) async{

    var googleGeocoding = GoogleGeocoding(kGoogleApiKey);
    final result = await googleGeocoding.geocoding.get(address, []);

    return result?.results?.first.geometry?.location;
  }

  static Future<Address?> decode(LatLng latLng) async{

    final result = await GoogleGeocoding(kGoogleApiKey).geocoding.getReverse(LatLon(latLng.latitude, latLng.longitude));
    try{

      String? address = result?.results?.reversed.last.formattedAddress;
      return Address(description: address, latLng: latLng, name: address);

    }catch(e){
      return Address(description: "Inconnu", latLng: latLng, name: "Inconnu");
    }

  }






  // Recherche d'adresse
  static Future<List<places.AutocompletePrediction>> searchGooglePlace(String query) async {

    var result = await places.GooglePlace(kGoogleApiKey).autocomplete.get(query);
    if(result != null && result.predictions != null){

      return result.predictions!;

    }

    return [];

  }

}