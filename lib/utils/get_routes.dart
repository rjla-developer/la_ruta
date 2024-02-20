//Latlong2:
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const mapboxAccessToken =
    "sk.eyJ1IjoicmotZGV2ZWxvcGVyIiwiYSI6ImNsc2dkazgzdTFsbjIybG8wMmFtcXVwODMifQ.gJl_3nLWEv_E9SeT6H_PkQ";

String getCoords(busName) {
  var route;
  if (busName == "Santa María - Buena vista - Francisco Villa") {
    route = [
      const LatLng(18.786022, -99.247230), //"La Cascada" Jardín
      const LatLng(18.873114, -99.226615), //Huesero
      const LatLng(18.925176, -99.238123), //Bodega Aurrera
      const LatLng(18.977468, -99.253351), //La Kekita
      const LatLng(18.974735, -99.262000), //Ruta 3 base Santa Maria
      const LatLng(18.928915, -99.239665), //Las Mañanitas
      const LatLng(18.910017, -99.232927), //Hotel Cuernavaca
      const LatLng(18.832719, -99.226511), //Carnitas Fer Temixco
      const LatLng(18.788728, -99.244098), //Rines Xochi
      const LatLng(18.786022, -99.247230), //"La Cascada" Jardín
    ];
  } else if (busName == "Santa María - Buena vista - Calera") {
    route = [
      const LatLng(18.788646, -99.242968), //El Cuexcomate
      const LatLng(18.879278, -99.229466), //Carpintería Alvarez III
      const LatLng(18.977502, -99.253349), //Barbacoa Doña Natalia
      const LatLng(18.974735, -99.262000), //Ruta 3 base Santa Maria
      const LatLng(18.940714, -99.241622), //Tortilleria Rayito
      const LatLng(
          18.928857, -99.238352), //Puesto de periodicos de La Union de Morelos
      const LatLng(18.908121, -99.232297), //Registro Agrario Nacional Morelos
      const LatLng(18.844531, -99.223947), //Don Cacahuate
      const LatLng(18.788646, -99.242968), //El Cuexcomate
    ];
  }
  return route
      .map((waypoint) => '${waypoint.longitude},${waypoint.latitude}')
      .join(';');
}

Future<List<LatLng>> getRoute(busName) async {
  final response = await http.get(Uri.parse(
      'https://api.mapbox.com/directions/v5/mapbox/driving/${getCoords(busName)}?geometries=geojson&access_token=$mapboxAccessToken'));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final geometry = data['routes'][0]['geometry']['coordinates'];
    final List<LatLng> points =
        geometry.map<LatLng>((coord) => LatLng(coord[1], coord[0])).toList();
    return points;
  } else {
    throw Exception('Failed to load route');
  }
}
