import 'package:flutter/material.dart';

//FlutterMap:
import 'package:flutter_map/flutter_map.dart';

//Latlong2:
import 'package:latlong2/latlong.dart';

//Geolocator:
import 'package:geolocator/geolocator.dart';

//FlutterMapAnimations:
import 'package:flutter_map_animations/flutter_map_animations.dart';

const mapboxAccessToken =
    "sk.eyJ1IjoicmotZGV2ZWxvcGVyIiwiYSI6ImNsc2dkazgzdTFsbjIybG8wMmFtcXVwODMifQ.gJl_3nLWEv_E9SeT6H_PkQ";

class HomeSectionMap extends StatefulWidget {
  final LatLng? targetPosition;
  final AnimatedMapController animatedMapController;
  const HomeSectionMap(
      {Key? key,
      required this.targetPosition,
      required this.animatedMapController})
      : super(key: key);

  @override
  State<HomeSectionMap> createState() => _HomeSectionMapState();
}

class _HomeSectionMapState extends State<HomeSectionMap> {
  LatLng? userPosition;

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

    var userPositionDetermined = await Geolocator.getCurrentPosition();
    setState(() {
      userPosition = LatLng(
          userPositionDetermined.latitude, userPositionDetermined.longitude);
    });
    return userPositionDetermined;
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return userPosition != null
        ? FlutterMap(
            mapController: widget.animatedMapController.mapController,
            options: MapOptions(
              initialCenter: userPosition!,
              initialZoom: 17,
              maxZoom: 22,
              minZoom: 9.5,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://api.mapbox.com/styles/v1/rj-developer/clsgye3i303gv01o88gzf40sf/tiles/256/{z}/{x}/{y}@2x?access_token=$mapboxAccessToken",
                additionalOptions: const {
                  'accessToken': mapboxAccessToken,
                },
              ),
              AnimatedMarkerLayer(
                markers: [
                  AnimatedMarker(
                    point: userPosition!,
                    builder: (_, animation) {
                      final size = 50.0 * animation.value;
                      return Icon(
                        Icons.person_pin,
                        size: size,
                        color: const Color.fromARGB(255, 25, 176, 218),
                      );
                    },
                  ),
                  if (widget.targetPosition != null)
                    AnimatedMarker(
                      point: widget.targetPosition!,
                      builder: (_, animation) {
                        final size = 50.0 * animation.value;
                        return Icon(
                          Icons.location_pin,
                          size: size,
                          color: const Color.fromARGB(255, 170, 39, 39),
                        );
                      },
                    ),
                  AnimatedMarker(
                    point: const LatLng(18.940714, -99.241622),
                    builder: (_, animation) {
                      final size = 50.0 * animation.value;
                      return Icon(
                        Icons.directions_bus,
                        size: size,
                        color: const Color.fromARGB(255, 189, 39, 194),
                      );
                    },
                  ),
                ],
              ),
              /* PolylineLayer(
                polylines: [
                  Polyline(
                    strokeWidth: 4.0,
                    points: widget.routePoints,
                    color: Colors.green,
                  ),
                ],
              ), */
              /* MarkerLayer(
                markers: [
                  Marker(
                    point: userPosition!,
                    child: const Icon(
                      Icons.person_pin,
                      size: 50.0,
                      color: Color.fromARGB(255, 25, 176, 218),
                    ),
                  ),
                  if (widget.targetPosition != null)
                    Marker(
                      point: widget.targetPosition!,
                      child: const Icon(
                        Icons.location_pin,
                        size: 50.0,
                        color: Color.fromARGB(255, 170, 39, 39),
                      ),
                    ),
                  const Marker(
                    point: LatLng(18.940714, -99.241622),
                    child: Icon(
                      Icons.directions_bus,
                      size: 50.0,
                      color: Color.fromARGB(255, 189, 39, 194),
                    ),
                  ),
                ],
              ), */
            ],
          )
        : const Center(child: CircularProgressIndicator());
  }
}
