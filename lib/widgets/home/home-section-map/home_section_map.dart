import 'package:flutter/material.dart';

//FlutterMap:
import 'package:flutter_map/flutter_map.dart';

//Latlong2:
import 'package:latlong2/latlong.dart';

//Geolocator:
import 'package:geolocator/geolocator.dart';

const mapboxAccessToken =
    "sk.eyJ1IjoicmotZGV2ZWxvcGVyIiwiYSI6ImNsc2dkazgzdTFsbjIybG8wMmFtcXVwODMifQ.gJl_3nLWEv_E9SeT6H_PkQ";
const myPosition = LatLng(18.788646, -99.242968);

class HomeSectionMap extends StatefulWidget {
  final List<LatLng> routePoints;
  const HomeSectionMap({Key? key, required this.routePoints}) : super(key: key);

  @override
  State<HomeSectionMap> createState() => _HomeSectionMapState();
}

class _HomeSectionMapState extends State<HomeSectionMap> {
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Por favor, habilita los servicios de ubicación.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Los permisos de ubicación son denegados');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Los permisos de ubicación están permanentemente denegados, no podemos solicitar permisos.');
    }

    var myPosition = await Geolocator.getCurrentPosition();
    print(myPosition);
    setState(() {});
    return myPosition;
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
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
              points: widget.routePoints,
              color: Colors.green,
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
    );
  }
}
