import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//Latlong2:
import 'package:latlong2/latlong.dart';

//Providers:
import 'package:la_ruta/providers/controls_map_provider.dart';
import 'package:provider/provider.dart';

const mapboxAccessToken =
    "sk.eyJ1IjoicmotZGV2ZWxvcGVyIiwiYSI6ImNsc2dkazgzdTFsbjIybG8wMmFtcXVwODMifQ.gJl_3nLWEv_E9SeT6H_PkQ";

String getCoords(List<LatLng> route) {
  return route
      .map((waypoint) => '${waypoint.longitude},${waypoint.latitude}')
      .join(';');
}

Future<List<LatLng>> getRoute(
    BuildContext context, List<LatLng> route, Color colorRoute) async {
  final controlsMapProvider =
      Provider.of<ControlsMapProvider>(context, listen: false);
  final response = await http.get(Uri.parse(
      'https://api.mapbox.com/directions/v5/mapbox/driving/${getCoords(route)}?geometries=geojson&overview=full&access_token=$mapboxAccessToken'));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final geometry = data['routes'][0]['geometry']['coordinates'];
    final List<LatLng> points =
        geometry.map<LatLng>((coord) => LatLng(coord[1], coord[0])).toList();

    final Polyline dataPolylineRoute = Polyline(
      strokeWidth: 4.0,
      points: points,
      color: colorRoute,
    );
    controlsMapProvider.dataPolylineRoute = dataPolylineRoute;

    return points;
  } else {
    throw Exception('Failed to load _route');
  }
}
