import 'package:flutter/material.dart';

//FlutterMap:
import 'package:flutter_map/flutter_map.dart';

//Latlong2:
import 'package:latlong2/latlong.dart';

//FlutterMapAnimations:
import 'package:flutter_map_animations/flutter_map_animations.dart';

const mapboxAccessToken =
    "sk.eyJ1IjoicmotZGV2ZWxvcGVyIiwiYSI6ImNsc2dkazgzdTFsbjIybG8wMmFtcXVwODMifQ.gJl_3nLWEv_E9SeT6H_PkQ";

class HomeSectionMap extends StatelessWidget {
  final LatLng? userPosition;
  final LatLng? targetPosition;
  final AnimatedMapController animatedMapController;
  const HomeSectionMap({
    Key? key,
    required this.userPosition,
    required this.targetPosition,
    required this.animatedMapController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return userPosition != null
        ? FlutterMap(
            mapController: animatedMapController.mapController,
            options: MapOptions(
              initialCenter: userPosition!,
              initialZoom: 17,
              maxZoom: 22,
              minZoom: 9.5,
              /* onTap: (_, point) => _addMarker(point), */
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
                  if (targetPosition != null)
                    AnimatedMarker(
                      point: targetPosition!,
                      builder: (_, animation) {
                        final size = 50.0 * animation.value;
                        return Icon(
                          Icons.location_pin,
                          size: size,
                          color: const Color.fromARGB(255, 170, 39, 39),
                        );
                      },
                    ),
                ],
              ),
              /* AnimatedMarker(
                        point: const LatLng(18.940714, -99.241622),
                        builder: (_, animation) {
                          final size = 50.0 * animation.value;
                          return Icon(
                            Icons.directions_bus,
                            size: size,
                            color: const Color.fromARGB(255, 189, 39, 194),
                          );
                        },
                      ), */
              /* PolylineLayer(
                  polylines: [
                    Polyline(
                      strokeWidth: 4.0,
                      points: widget.routePoints,
                      color: Colors.green,
                    ),
                  ],
                ), */
            ],
          )
        : const Center(child: CircularProgressIndicator());
  }
}
