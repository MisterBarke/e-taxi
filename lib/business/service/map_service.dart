import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kano/business/model/address.dart';
import 'package:kano/constants.dart';
import 'package:kano/utils.dart';

class MapService {
  static Future<List<Marker>> buildStartEndMarkers(
      {required Address startAddress,
      String startIcon = 'assets/images/location_pin.png',
      required Address endAddress}) async {
    final markers = <Marker>[];

    final icon1 = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(600, 600)), startIcon);

    markers.add(
      Marker(
        markerId: const MarkerId("start"),
        position: startAddress.latLng!,
        infoWindow: InfoWindow(
          title: startAddress.description ?? "",
          snippet: 'Départ',
        ),
        icon: icon1,
      ),
    );

    final icon2 = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(300, 300)),
        'assets/images/start_pin.png');

    markers.add(
      Marker(
        markerId: const MarkerId("end"),
        position: endAddress.latLng!,
        infoWindow: InfoWindow(
          title: endAddress.description ?? "",
          snippet: 'Destination',
        ),
        icon: icon2,
      ),
    );

    return markers;
  }

  static Future<Marker> buildMarker(
      {required Address startAddress,
      iconPath = "assets/images/car_top_nobg.png",
      required String id}) async {
    final icon1 = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, iconPath);

    return Marker(
      markerId: MarkerId(id),
      position: startAddress.latLng!,
      infoWindow: InfoWindow(
        title: startAddress.description ?? "",
        snippet: 'Départ',
      ),
      icon: icon1,
    );
  }

  static Future<Map<PolylineId, Polyline>> buildPolylines(
      {required List<LatLng> coordinates,
      Color color = const Color(0xFF7EAB3A)}) async {
    if (coordinates.length < 2)
      throw Exception("coordinates params must have at least 2 items");

    PolylinePoints polylinePoints = PolylinePoints();
    Map<PolylineId, Polyline> data = {};

    for (int i = 1; i < coordinates.length; i++) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        kGoogleApiKey,
        PointLatLng(coordinates[i - 1].latitude, coordinates[i - 1].longitude),
        PointLatLng(coordinates.last.latitude, coordinates.last.longitude),
        travelMode: TravelMode.driving,
      );

      log("============ RESULT =============");
      log("${result.status}");

      PolylineId id = PolylineId(i.toString());
      final response = parseToPolyline(parseToLatLngList(result.points), id);
      data.putIfAbsent(id, () => response);
    }

    return data;
  }

  static Polyline parseToPolyline(
      List<LatLng> polylineCoordinates, PolylineId id,
      {Color color = const Color(0xFF7EAB3A)}) {
    return Polyline(
      polylineId: id,
      color: const Color(0xFF7EAB3A),
      points: polylineCoordinates,
      width: 4,
    );
  }

  static List<LatLng> parseToLatLngList(List<PointLatLng> points) {
    List<LatLng> polylineCoordinates = [];
    for (var point in points) {
      polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    }
    return polylineCoordinates;
  }

  static Future<double> calculateWholeDistance(
      List<LatLng> polylineCoordinates) async {
    double totalDistance = 0;
    for (var i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += calculateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude);
    }

    return  double.parse(totalDistance.toStringAsFixed(2));
  }
}
