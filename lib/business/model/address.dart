
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Address{

  String? description;
  String? name;
  LatLng? latLng;

  Address({this.description, this.latLng, this.name});

  Map<String, dynamic> map(){
    return {
      "address": description,
      "lat": latLng!.latitude,
      "long": latLng!.longitude,
    };
  }

}