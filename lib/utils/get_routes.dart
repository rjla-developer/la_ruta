import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//Dart:
import 'dart:math';
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

String getCoords(List<LatLng> route) {
  return route
      .map((waypoint) => '${waypoint.longitude},${waypoint.latitude}')
      .join(';');
}

class Ruta {
  String nombre;
  double latitudInicio;
  double longitudInicio;
  double latitudFin;
  double longitudFin;

  Ruta(this.nombre, this.latitudInicio, this.longitudInicio, this.latitudFin,
      this.longitudFin);
}

Ruta encontrarRutaMasCercana(controlsMapProvider) {
  List<LatLng> puntosDestino = [
    controlsMapProvider.userPosition,
    controlsMapProvider.targetPosition,
  ];
  double distanciaMinima = double.infinity;
  Ruta? rutaMasCercana;

  for (var entry in dataRoutes.entries) {
    var puntosInicio = entry.value;
    double distancia = sqrt(
        pow(puntosDestino[0].latitude - puntosInicio[0].latitude, 2) +
            pow(puntosDestino[0].longitude - puntosInicio[0].longitude, 2));

    if (distancia < distanciaMinima) {
      distanciaMinima = distancia;
      rutaMasCercana = Ruta(
          entry.key,
          puntosInicio[0].latitude,
          puntosInicio[0].longitude,
          puntosInicio[2].latitude,
          puntosInicio[2].longitude);
    }
  }

  if (rutaMasCercana != null) {
    print('Ruta más cercana: ${rutaMasCercana.nombre}');
    return rutaMasCercana;
  } else {
    throw Exception('No se encontró ninguna ruta cercana.');
  }
}

Future<void> getRoute(BuildContext context) async {
  final controlsMapProvider =
      Provider.of<ControlsMapProvider>(context, listen: false);
  Ruta mejorRuta = encontrarRutaMasCercana(controlsMapProvider);

  String rutaCoords = getCoords([
    LatLng(mejorRuta.latitudInicio, mejorRuta.longitudInicio),
    LatLng(mejorRuta.latitudFin, mejorRuta.longitudFin),
  ]);

  try {
    final response = await http.get(Uri.parse(
        'https://api.mapbox.com/directions/v5/mapbox/driving/$rutaCoords?geometries=geojson&access_token=$mapboxAccessToken'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['routes'][0]['geometry']['coordinates'];
      final List<LatLng> points =
          geometry.map<LatLng>((coord) => LatLng(coord[1], coord[0])).toList();

/* final List<LatLng> rutaOptimizada = points
          .where((point) =>
              point.latitude == mejorRuta.latitudInicio &&
              point.longitude == mejorRuta.longitudInicio)
          .toList();

      controlsMapProvider.route = rutaOptimizada; */
      controlsMapProvider.route = points;
    } else {
      throw Exception('Failed to load route');
    }
  } catch (e) {
    print('Error al obtener la ruta detallada: $e');
  }
}
