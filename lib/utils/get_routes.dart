import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//Latlong2:
import 'package:latlong2/latlong.dart';

//Providers:
import 'package:la_ruta/providers/controls_map_provider.dart';
import 'package:provider/provider.dart';

const mapboxAccessToken =
    "sk.eyJ1IjoicmotZGV2ZWxvcGVyIiwiYSI6ImNsc2dkazgzdTFsbjIybG8wMmFtcXVwODMifQ.gJl_3nLWEv_E9SeT6H_PkQ";

const dataRoutes = {
  "Ahuatlán": [
    LatLng(18.888783, -99.231194), //Origen

    LatLng(18.933027, -99.239613), //Punto medio

    LatLng(18.957835, -99.266824), //Destino
  ],
};

String getCoords(controlsMapProvider) {
  var _route = [
    controlsMapProvider.userPosition,
    controlsMapProvider.targetPosition,
  ];

  return _route
      .map((waypoint) => '${waypoint.longitude},${waypoint.latitude}')
      .join(';');
}

Future<List<LatLng>> getRoute(BuildContext context) async {
  final controlsMapProvider =
      Provider.of<ControlsMapProvider>(context, listen: false);
  final response = await http.get(Uri.parse(
      'https://api.mapbox.com/directions/v5/mapbox/driving/${getCoords(controlsMapProvider)}?geometries=geojson&access_token=$mapboxAccessToken'));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final geometry = data['routes'][0]['geometry']['coordinates'];
    final List<LatLng> points =
        geometry.map<LatLng>((coord) => LatLng(coord[1], coord[0])).toList();

    controlsMapProvider.route = points;
    return points;
  } else {
    throw Exception('Failed to load _route');
  }
}
