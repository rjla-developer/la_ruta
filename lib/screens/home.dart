import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

//Latlong2:
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const mapboxAccessToken =
    "sk.eyJ1IjoicmotZGV2ZWxvcGVyIiwiYSI6ImNsc2dkazgzdTFsbjIybG8wMmFtcXVwODMifQ.gJl_3nLWEv_E9SeT6H_PkQ";

const myPosition = LatLng(18.9213, -99.2347);
const intermediatePosition = LatLng(18.9225, -99.23479);
const intermediatePosition2 = LatLng(18.9300, -99.23479);
const destinationPosition = LatLng(18.92330, -99.23580);

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
    fetchRoute();
  }

  Future<void> fetchRoute() async {
    final response = await http.get(Uri.parse(
        'https://api.mapbox.com/directions/v5/mapbox/driving/${myPosition.longitude},${myPosition.latitude};${intermediatePosition.longitude},${intermediatePosition.latitude};${intermediatePosition2.longitude},${intermediatePosition2.latitude};${destinationPosition.longitude},${destinationPosition.latitude}?geometries=geojson&access_token=$mapboxAccessToken'));
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
            initialZoom: 17.5,
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
                  color: Colors.blue,
                ),
              ],
            ),
            const MarkerLayer(
              markers: [
                Marker(
                  point: myPosition,
                  child: Icon(
                    Icons.person_pin,
                    size: 50.0,
                    color: Color.fromARGB(255, 25, 176, 218),
                  ),
                ),
                Marker(
                  point: LatLng(18.92330, -99.23580),
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
      ],
    );
  }
}
