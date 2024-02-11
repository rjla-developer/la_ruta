import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

//Latlong2:
import 'package:latlong2/latlong.dart';

const mapboxAccessToken =
    "sk.eyJ1IjoicmotZGV2ZWxvcGVyIiwiYSI6ImNsc2dkazgzdTFsbjIybG8wMmFtcXVwODMifQ.gJl_3nLWEv_E9SeT6H_PkQ";

const myPosition = LatLng(18.9216, -99.2347);

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: myPosition,
        initialZoom: 19.5,
      ),
      children: [
        TileLayer(
          urlTemplate:
              "https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=$mapboxAccessToken",
          additionalOptions: const {
            'accessToken': mapboxAccessToken,
            'id': 'mapbox/streets-v11',
          },
        ),
      ],
    );
  }
}
