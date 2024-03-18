import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

//Dart:
import 'dart:convert';
import 'package:archive/archive.dart';
import 'dart:async';
import 'dart:math';

//Http:
import 'package:http/http.dart' as http;

//Latlong2:
import 'package:latlong2/latlong.dart';

//Providers:
import 'package:provider/provider.dart';
import 'package:la_ruta/providers/controls_map_provider.dart';
import 'package:la_ruta/providers/gtfs_provider.dart';

//FlutterMapAnimations:
import 'package:flutter_map_animations/flutter_map_animations.dart';

//FlutterMap:
import 'package:flutter_map/flutter_map.dart';

const searchLocationAccessToken =
    "pk.eyJ1IjoicmotZGV2ZWxvcGVyIiwiYSI6ImNsa3JpOXNudDB2dG8zcXFtN3RqYzk2ZngifQ.OjfZuB4ku290h-qvB-BecA";

const searchLocationSessionToken = '08aed845-b073-4761-88dd-bb2059d0caa8';

class HomeSectionSearch extends StatefulWidget {
  final AnimatedMapController animatedMapController;
  const HomeSectionSearch({super.key, required this.animatedMapController});

  @override
  State<HomeSectionSearch> createState() => _HomeSectionSearchState();
}

class _HomeSectionSearchState extends State<HomeSectionSearch> {
  TextEditingController controllerResponseInputSearch = TextEditingController();
  var _showModalSearch = false;
  List responseLocations = [];
  Timer? _debounce;

  Future<void> getSearches() async {
    String inputValue = controllerResponseInputSearch.text;
    var url = Uri.https('api.mapbox.com', '/search/searchbox/v1/suggest', {
      'q': inputValue,
      'language': 'es',
      'country': 'mx',
      'proximity': '-99.23426591658529, 18.921791278067488',
      'session_token': searchLocationSessionToken,
      'access_token': searchLocationAccessToken
    });
    var response = await http.get(url);
    Map<String, dynamic> jsonData = jsonDecode(response.body);
    setState(() => responseLocations = jsonData['suggestions']);
  }

  Future<void> getDestinationCoordinates(
      controlsMapProvider, gtfsProvider, locationId) async {
    var url = Uri.https(
        'api.mapbox.com', '/search/searchbox/v1/retrieve/$locationId', {
      'access_token': searchLocationAccessToken,
      'session_token': searchLocationSessionToken
    });
    var response = await http.get(url);
    Map<String, dynamic> jsonData = jsonDecode(response.body);
    /* print('latitude: ${jsonData['features'][0]['geometry']['coordinates'][1]}');
    print(
        'longitude: ${jsonData['features'][0]['geometry']['coordinates'][0]}'); */
    controlsMapProvider.setTargetPosition(LatLng(
        jsonData['features'][0]['geometry']['coordinates'][1],
        jsonData['features'][0]['geometry']['coordinates'][0]));

    final points = [
      controlsMapProvider.userPosition,
      controlsMapProvider.targetPosition
    ];
    widget.animatedMapController.animatedFitCamera(
      cameraFit: CameraFit.coordinates(
        coordinates:
            points.where((point) => point != null).cast<LatLng>().toList(),
        padding: const EdgeInsets.only(
          top: 180,
          right: 50,
          bottom: 360,
          left: 50,
        ),
      ),
      rotation: 0,
      customId: '_useTransformerId',
    );
    getOptionsRoutes(controlsMapProvider, gtfsProvider);
  }

  double calculateDistance(LatLng point1, LatLng point2) {
    const R = 6371e3; // Esto es el radio de la Tierra en metros
    var lat1 = point1.latitude * pi / 180;
    var lat2 = point2.latitude * pi / 180;
    var deltaLat = (point2.latitude - point1.latitude) * pi / 180;
    var deltaLon = (point2.longitude - point1.longitude) * pi / 180;

    var a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  void getOptionsRoutes(controlsMapProvider, gtfsProvider) async {
    LatLng? userLocation = controlsMapProvider.userPosition;
    LatLng? destination = controlsMapProvider.targetPosition;

    Stop? closestStopFromOriginData;
    Stop? closestStopFromDestinationData;

    const double limitDistance = 1000.0;
    double closestStopDistance = double.infinity;
    double closestRouteDistance = double.infinity;

    List<Stop> stopsInfo = gtfsProvider.dataGTFS!.stopsInfo;

    for (int i = 0; i < stopsInfo.length; i++) {
      var fieldCoordinates = LatLng(stopsInfo[i].stopLat, stopsInfo[i].stopLon);
      var distanceUserToNextStop =
          calculateDistance(userLocation!, fieldCoordinates);
      var distanceDestinationToNextStop =
          calculateDistance(destination!, fieldCoordinates);

      if (distanceUserToNextStop < closestStopDistance) {
        //Aquí estamos actualizando los datos de la parada más cercana al origen del usuario.
        closestStopFromOriginData = stopsInfo[i];
        //Aquí estamos actualizando la distancia más corta de la parada más cercana al origen del usuario.
        closestStopDistance = distanceUserToNextStop;
      }

      if (distanceDestinationToNextStop < closestRouteDistance) {
        //Aquí estamos actualizando los datos de la parada más cercana al destino del usuario.
        closestStopFromDestinationData = stopsInfo[i];
        //Aquí estamos actualizando la distancia más corta de la parada más cercana del destino del usuario.
        closestRouteDistance = distanceDestinationToNextStop;
      }
    }
    // Si no hay rutas cerca del destino del usuario, informa al usuario
    if (closestRouteDistance > limitDistance) {
      print('No hay rutas cerca de tu destino.');
    } else {
      /* print('Parada más cercana al origen: $closestStopFromOriginData');
      print('Parada más cercana al destino: $closestStopFromDestinationData'); */

      List<BusStop> busStopsInfo = gtfsProvider.dataGTFS!.busStopsInfo;
      List<BusStop> busesWithClosestStopFromOrigin = busStopsInfo
          .where(
              (element) => element.stopId == closestStopFromOriginData!.stopId)
          .toList();
      List<BusStop> busesWithClosestStopFromDestination = busStopsInfo
          .where((element) =>
              element.stopId == closestStopFromDestinationData!.stopId)
          .toList();

      /* print('$busesWithClosestStopFromOrigin');
      print('$busesWithClosestStopFromDestination'); */

      //Determinar microbuses directos al destino:
      List<Shape> shapesInfo = gtfsProvider.dataGTFS!.shapesInfo;
      Map<double, List<LatLng>> routeToDestination = {};

      //Esta lógica une a los microbuses con el 'routeId' identicos que tienen paradas cercanas al origen y al destino del usuario.
      //Específicamente en el if unimos a los microbuses
      for (int i = 0; i < busesWithClosestStopFromOrigin.length; i++) {
        for (int j = 0; j < busesWithClosestStopFromDestination.length; j++) {
          if (busesWithClosestStopFromOrigin[i].routeId ==
              busesWithClosestStopFromDestination[j].routeId) {
            LatLng? coordinatesBusWithClosestStopFromOrigin;
            LatLng? coordinatesBusWithClosestStopFromDestination;

            for (var element in stopsInfo) {
              if (element.stopId == busesWithClosestStopFromOrigin[i].stopId) {
                coordinatesBusWithClosestStopFromOrigin =
                    LatLng(element.stopLat, element.stopLon);
              }
              if (element.stopId ==
                  busesWithClosestStopFromDestination[j].stopId) {
                coordinatesBusWithClosestStopFromDestination =
                    LatLng(element.stopLat, element.stopLon);
              }
            }

            if (!routeToDestination
                .containsKey(busesWithClosestStopFromOrigin[i].routeId)) {
              routeToDestination[busesWithClosestStopFromOrigin[i].routeId] = [
                coordinatesBusWithClosestStopFromOrigin!
              ];
            }

            /* print('Ruta directa: $directBusesToDestination'); */

            for (int k = 0; k < shapesInfo.length; k++) {
              if (shapesInfo[k].shapeId ==
                  busesWithClosestStopFromOrigin[i].routeId) {
                LatLng shapeCoordinates =
                    LatLng(shapesInfo[k].shapePtLat, shapesInfo[k].shapePtLon);

                if (busesWithClosestStopFromDestination[j].stopSequence >
                        shapesInfo[k].stopSequence &&
                    shapesInfo[k].stopSequence >
                        busesWithClosestStopFromOrigin[i].stopSequence) {
                  if (routeToDestination
                      .containsKey(busesWithClosestStopFromOrigin[i].routeId)) {
                    routeToDestination[
                            busesWithClosestStopFromOrigin[i].routeId]!
                        .add(shapeCoordinates);
                  }
                }
              }
            }

            if (routeToDestination
                .containsKey(busesWithClosestStopFromOrigin[i].routeId)) {
              routeToDestination[busesWithClosestStopFromOrigin[i].routeId]!
                  .add(coordinatesBusWithClosestStopFromDestination!);
            }
          }
        }
      }
      /* print('$routeToDestination'); */

      controlsMapProvider.posiblesRoutesToDestination = routeToDestination
          .map((key, value) => MapEntry(key.toString(), value));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controlsMapProvider = context.watch<ControlsMapProvider>();
    final gtfsProvider = context.watch<GTFSProvider>();
    return Stack(children: [
      if (_showModalSearch) ...[
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () => setState(() => _showModalSearch = false),
            child: Material(
              color: const Color.fromARGB(248, 30, 30, 30),
              child: Column(
                children: [
                  const SizedBox(height: 140.0),
                  if (responseLocations.isNotEmpty)
                    for (var i = 0; i < responseLocations.length; i++)
                      SizedBox(
                        width: 350,
                        child: Column(
                          children: [
                            const SizedBox(height: 5.0),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  controllerResponseInputSearch.text =
                                      responseLocations[i]['name'];
                                  getDestinationCoordinates(
                                      controlsMapProvider,
                                      gtfsProvider,
                                      responseLocations[i]['mapbox_id']);
                                  _showModalSearch = false;
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 0.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Color.fromARGB(255, 224, 57, 57),
                                    size: 30.0,
                                  ),
                                  const SizedBox(width: 10.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          responseLocations[i]['name'] ??
                                              "No hay datos",
                                          style: const TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                        Text(
                                          responseLocations[i]
                                                  ['full_address'] ??
                                              "No hay datos",
                                          style: const TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 227, 220, 220)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5.0),
                          ],
                        ),
                      ),
                  if (responseLocations.isEmpty)
                    const Column(
                      children: [
                        SizedBox(height: 30),
                        Center(
                          child: Text(
                            'Sin ubicaciones para mostrar',
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
      Positioned(
        top: 80,
        left: 0,
        right: 0,
        child: Center(
          child: SizedBox(
            width: 350,
            child: Material(
              elevation: 8.0,
              borderRadius: BorderRadius.circular(30.0),
              child: TextField(
                controller: controllerResponseInputSearch,
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 200), () {
                    if (controllerResponseInputSearch.text.isEmpty) {
                      setState(() => responseLocations = []);
                    } else {
                      getSearches();
                    }
                  });
                },
                onTap: () {
                  controlsMapProvider.panelController.close();
                  setState(() => _showModalSearch = true);
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  hintText: "A dónde quieres ir?",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => {
                      controllerResponseInputSearch.clear(),
                      controlsMapProvider.setTargetPosition(const LatLng(0, 0)),
                      setState(() => responseLocations = [])
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}
