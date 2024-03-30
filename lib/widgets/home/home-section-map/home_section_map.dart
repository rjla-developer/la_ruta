import 'package:flutter/material.dart';

//FlutterMap:
import 'package:flutter_map/flutter_map.dart';

//FlutterMapAnimations:
import 'package:flutter_map_animations/flutter_map_animations.dart';

//Latlong2:
import 'package:latlong2/latlong.dart';

//Providers:
import 'package:provider/provider.dart';
import 'package:la_ruta/providers/controls_map_provider.dart';
import 'package:la_ruta/providers/gtfs_provider.dart';

const mapboxAccessToken =
    "sk.eyJ1IjoicmotZGV2ZWxvcGVyIiwiYSI6ImNsc2dkazgzdTFsbjIybG8wMmFtcXVwODMifQ.gJl_3nLWEv_E9SeT6H_PkQ";

class HomeSectionMap extends StatefulWidget {
  final AnimatedMapController animatedMapController;
  const HomeSectionMap({
    super.key,
    required this.animatedMapController,
  });

  @override
  State<HomeSectionMap> createState() => _HomeSectionMapState();
}

class _HomeSectionMapState extends State<HomeSectionMap> {
  @override
  Widget build(BuildContext context) {
    final controlsMapProvider = context.watch<ControlsMapProvider>();
    final gtfsProvider = context.watch<GTFSProvider>();

    return FlutterMap(
      mapController: widget.animatedMapController.mapController,
      options: MapOptions(
        initialCenter: controlsMapProvider.userPosition!,
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
        PolylineLayer(
          polylines: [
            controlsMapProvider.dataPolylineRoute,
          ],
        ),
        AnimatedMarkerLayer(
          markers: [
            AnimatedMarker(
              point: controlsMapProvider.userPosition!,
              builder: (_, animation) {
                final size = 50.0 * animation.value;
                return Icon(
                  Icons.person_pin,
                  size: size,
                  color: const Color.fromARGB(255, 25, 176, 218),
                );
              },
            ),
            if (controlsMapProvider.targetPosition != null)
              AnimatedMarker(
                point: controlsMapProvider.targetPosition!,
                builder: (_, animation) {
                  final size = 50.0 * animation.value;
                  return Icon(
                    Icons.location_pin,
                    size: size,
                    color: const Color.fromARGB(255, 170, 39, 39),
                  );
                },
              ),
            /* if (gtfsProvider.dataGTFS != null)
                    for (int i = 0;
                        i < gtfsProvider.dataGTFS!.stopsInfo.length;
                        i++)
                      AnimatedMarker(
                        point: LatLng(
                            gtfsProvider.dataGTFS!.stopsInfo[i].stopLat,
                            gtfsProvider.dataGTFS!.stopsInfo[i].stopLon),
                        builder: (_, animation) {
                          final size = 25.0 * animation.value;
                          return Icon(
                            Icons.pin_drop,
                            size: size,
                            color: const Color.fromARGB(255, 164, 188, 213),
                          );
                        },
                      ), */
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
      ],
    );
  }
}
