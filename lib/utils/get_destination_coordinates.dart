import 'package:flutter/material.dart';

//Dart:
import 'dart:convert';
import 'dart:async';

//Http:
import 'package:http/http.dart' as http;

//Latlong2:
import 'package:latlong2/latlong.dart';

//FlutterMap:
import 'package:flutter_map/flutter_map.dart';

//Utils:
import 'package:la_ruta/utils/get_options_routes.dart';

const searchLocationAccessToken =
    "pk.eyJ1IjoicmotZGV2ZWxvcGVyIiwiYSI6ImNsa3JpOXNudDB2dG8zcXFtN3RqYzk2ZngifQ.OjfZuB4ku290h-qvB-BecA";

const searchLocationSessionToken = '08aed845-b073-4761-88dd-bb2059d0caa8';

Future<void> getDestinationCoordinates(controlsMapProvider, gtfsProvider,
    locationId, animatedMapController) async {
  var url =
      Uri.https('api.mapbox.com', '/search/searchbox/v1/retrieve/$locationId', {
    'access_token': searchLocationAccessToken,
    'session_token': searchLocationSessionToken
  });
  var response = await http.get(url);
  Map<String, dynamic> jsonData = jsonDecode(response.body);
  /* print('latitude: ${jsonData['features'][0]['geometry']['coordinates'][1]}');
    print(
        'longitude: ${jsonData['features'][0]['geometry']['coordinates'][0]}'); */
  controlsMapProvider.setTargetPosition(LatLng(
      jsonData['features'][0]['geometry']['coordinates'][1],
      jsonData['features'][0]['geometry']['coordinates'][0]));

  final points = [
    controlsMapProvider.userPosition,
    controlsMapProvider.targetPosition
  ];
  animatedMapController.animatedFitCamera(
    cameraFit: CameraFit.coordinates(
      coordinates:
          points.where((point) => point != null).cast<LatLng>().toList(),
      padding: const EdgeInsets.only(
        top: 180,
        right: 50,
        bottom: 360,
        left: 50,
      ),
    ),
    rotation: 0.0,
    customId: '_useTransformerId',
  );
  getOptionsRoutes(controlsMapProvider, gtfsProvider);
}
