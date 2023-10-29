import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kano/business/service/kano_http.dart';

import '../../utils.dart';

class OrderService {
  static Future<dynamic> calculatePrice(dynamic rideData) async {
    final response = await http_post("/api/rides/calculateprice", rideData);
    if (response != null) {
      return response;
    }

    return null;
  }

  static double calculateWholeDistance(List<LatLng> polylineCoordinates) {
    double totalDistance = 0;
    for (var i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += calculateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude);
    }

    return totalDistance;
  }

  static Future<dynamic> notifyOrderToBackend(String uuid) async {
    return http_post("/api/rides/request/$uuid", {});
  }

  static Future<dynamic> refreshRide(String uuid) async {
    return http_post("/api/rides/$uuid/refresh", {});
  }
}
