import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

//Latlong2:
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const mapboxAccessToken =
    "sk.eyJ1IjoicmotZGV2ZWxvcGVyIiwiYSI6ImNsc2dkazgzdTFsbjIybG8wMmFtcXVwODMifQ.gJl_3nLWEv_E9SeT6H_PkQ";

const myPosition = LatLng(18.788646, -99.242968);

const route = [
  LatLng(18.788646, -99.242968), //El Cuexcomate
  LatLng(18.879278, -99.229466), //Carpintería Alvarez III
  LatLng(18.977502, -99.253349), //Barbacoa Doña Natalia
  LatLng(18.974735, -99.262000), //Ruta 3 base Santa Maria
  LatLng(18.940714, -99.241622), //Tortilleria Rayito
  LatLng(18.928857, -99.238352), //Puesto de periodicos de La Union de Morelos
  LatLng(18.908121, -99.232297), //Registro Agrario Nacional Morelos
  LatLng(18.844531, -99.223947), //Don Cacahuate
  LatLng(18.788646, -99.242968), //El Cuexcomate
];

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<LatLng> routePoints = [];

  @override
  void initState() {
    super.initState();
  }

  String getCoords() {
    return route
        .map((waypoint) => '${waypoint.longitude},${waypoint.latitude}')
        .join(';');
  }

  Future<void> getRoute() async {
    final response = await http.get(Uri.parse(
        'https://api.mapbox.com/directions/v5/mapbox/driving/${getCoords()}?geometries=geojson&access_token=$mapboxAccessToken'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['routes'][0]['geometry']['coordinates'];
      final List<LatLng> points =
          geometry.map<LatLng>((coord) => LatLng(coord[1], coord[0])).toList();
      setState(() {
        routePoints = points;
      });
    } else {
      throw Exception('Failed to load route');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        FlutterMap(
          options: const MapOptions(
            initialCenter: myPosition,
            initialZoom: 10.5,
            maxZoom: 22,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  "https://api.mapbox.com/styles/v1/rj-developer/clsgye3i303gv01o88gzf40sf/tiles/256/{z}/{x}/{y}@2x?access_token=$mapboxAccessToken",
              additionalOptions: const {
                'accessToken': mapboxAccessToken,
              },
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  strokeWidth: 4.0,
                  points: routePoints,
                  color: Colors.green,
                ),
              ],
            ),
            const MarkerLayer(
              markers: [
                /* Marker(
                  point: myPosition,
                  child: Icon(
                    Icons.person_pin,
                    size: 50.0,
                    color: Color.fromARGB(255, 25, 176, 218),
                  ),
                ), */
                Marker(
                  point: LatLng(18.940714, -99.241622),
                  child: Icon(
                    Icons.directions_bus,
                    size: 50.0,
                    color: Color.fromARGB(255, 189, 39, 194),
                  ),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: 350,
              child: Material(
                elevation: 8.0,
                borderRadius: BorderRadius.circular(30.0),
                child: TextField(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 60,
          left: 50,
          right: 50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 15.0,
                  ),
                ),
                child: const Text(
                  'Santa María - Buena vista - Calera',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 15.0,
                  ),
                ),
                child: const Text(
                  'Santa María - Buena vista - Francisco Villa',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
