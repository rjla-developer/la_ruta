import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

//Latlong2:
import 'package:latlong2/latlong.dart';

const mapboxAccessToken =
    "sk.eyJ1IjoicmotZGV2ZWxvcGVyIiwiYSI6ImNsc2dkazgzdTFsbjIybG8wMmFtcXVwODMifQ.gJl_3nLWEv_E9SeT6H_PkQ";

const myPosition = LatLng(18.9213, -99.2347);

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        FlutterMap(
          options: const MapOptions(
            initialCenter: myPosition,
            initialZoom: 18.5,
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
                  point: LatLng(18.9225, -99.23479),
                  child: Icon(
                    Icons.directions_bus,
                    size: 50.0,
                    color: Color.fromARGB(255, 26, 180, 54),
                  ),
                ),
              ],
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [
                    myPosition,
                    const LatLng(18.9216, -99.23367),
                    const LatLng(18.9225, -99.23479),
                  ],
                  color: Colors.blue,
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
