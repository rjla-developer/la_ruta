import 'package:flutter/material.dart';

//Widgets:
import 'package:la_ruta/widgets/home/home-section-map/home_section_map.dart';
import 'package:la_ruta/widgets/home/home_section_search.dart';
import 'package:la_ruta/widgets/home/home_section_panel.dart';

//Latlong2:
import 'package:latlong2/latlong.dart';

//Functions:
/* import 'package:la_ruta/utils/get_routes.dart'; */

//FlutterMapAnimations:
import 'package:flutter_map_animations/flutter_map_animations.dart';

//FlutterMap:
import 'package:flutter_map/flutter_map.dart';

//SlidingUpPanel:
import 'package:sliding_up_panel/sliding_up_panel.dart';

//Geolocator:
import 'package:geolocator/geolocator.dart';

const mapboxAccessToken =
    "sk.eyJ1IjoicmotZGV2ZWxvcGVyIiwiYSI6ImNsc2dkazgzdTFsbjIybG8wMmFtcXVwODMifQ.gJl_3nLWEv_E9SeT6H_PkQ";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  LatLng? userPosition;
  LatLng? targetPosition;
  late final animatedMapController = AnimatedMapController(vsync: this);
  final bool _useTransformer = true;
  static const _useTransformerId = '_useTransformerId';

  //SlidingUpPanel:
  final PanelController _panelController = PanelController();

  void setTargetPosition(LatLng position) {
    setState(() {
      targetPosition = position;
    });
    _panelController.open();
    {
      final points = [userPosition, targetPosition];
      animatedMapController.animatedFitCamera(
        cameraFit: CameraFit.coordinates(
          coordinates:
              points.where((point) => point != null).cast<LatLng>().toList(),
          padding: const EdgeInsets.all(80),
        ),
        rotation: 0,
        customId: _useTransformer ? _useTransformerId : null,
      );
    }
  }

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
  void dispose() {
    animatedMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      renderPanelSheet: false,
      controller: _panelController,
      minHeight: 0,
      maxHeight: 300.0,
      panel: const HomeSectionPanel(),
      body: Stack(
        children: <Widget>[
          HomeSectionMap(
            userPosition: userPosition,
            targetPosition: targetPosition,
            animatedMapController: animatedMapController,
          ),
          HomeSectionSearch(setTargetPosition: setTargetPosition),

          /* Positioned(
            bottom: 60,
            left: 50,
            right: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    var route =
                        await getRoute("Santa María - Buena vista - Calera");
                    setState(() {
                      routePoints = route;
                    });
                  },
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
                  onPressed: () async {
                    var route = await getRoute(
                        "Santa María - Buena vista - Francisco Villa");
                    setState(() {
                      routePoints = route;
                    });
                  },
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
          ), */
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => animatedMapController.animatedZoomOut(
                customId: _useTransformer ? _useTransformerId : null,
              ),
              tooltip: 'Zoom out',
              child: const Icon(Icons.zoom_out),
            ),
          ),
        ],
      ),
    );
  }
}
