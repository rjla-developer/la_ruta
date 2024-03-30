import 'package:flutter/material.dart';

//Dart:
import 'dart:convert';
import 'dart:async';
import 'dart:math';

//Http:
import 'package:http/http.dart' as http;
import 'package:la_ruta/models/possible_route_to_destination_model.dart';

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

//Models:
import 'package:la_ruta/models/stop_model.dart';
import 'package:la_ruta/models/bus_stop_model.dart';
import 'package:la_ruta/models/shape_model.dart';
import 'package:la_ruta/models/route_model.dart';

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
    /* Este código es una implementación de la fórmula de Haversine
    para calcular la distancia entre dos puntos en la superficie
    de una esfera (en este caso, la Tierra) dadas sus
    latitudes y longitudes. Aquí está la explicación línea por línea. */

    // Esto es el radio de la Tierra en metros:
    const R = 6371e3;
    //Aquí se convierte la latitud del primer punto de grados a radianes:
    var lat1 = point1.latitude * pi / 180;
    //Aquí se convierte la latitud del segundo punto de grados a radianes:
    var lat2 = point2.latitude * pi / 180;
    //Aquí se calcula la diferencia en latitud entre los dos puntos y se convierte de grados a radianes:
    var deltaLat = (point2.latitude - point1.latitude) * pi / 180;
    //Aquí se calcula la diferencia en longitud entre los dos puntos y se convierte de grados a radianes:
    var deltaLon = (point2.longitude - point1.longitude) * pi / 180;

    //Aquí se calcula el valor de a en la fórmula de Haversine:
    var a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2);
    //Aquí se calcula el valor de c en la fórmula de Haversine:
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));

    //Finalmente, se devuelve la distancia entre los dos puntos, que se calcula multiplicando R (el radio de la Tierra) por c:
    return R * c;
  }

  void getOptionsRoutes(controlsMapProvider, gtfsProvider) async {
    LatLng? userLocation = controlsMapProvider.userPosition;
    LatLng? destination = controlsMapProvider.targetPosition;

    StopModel? closestStopFromOriginData;
    StopModel? closestStopFromDestinationData;

    const double limitDistance = 1000.0;
    double closestStopDistance = double.infinity;
    double closestRouteDistance = double.infinity;

    List<StopModel> stopsInfo = gtfsProvider.dataGTFS!.stopsInfo;
    List<RouteModel> routesInfo = gtfsProvider.dataGTFS!.routesInfo;

    for (int i = 0; i < stopsInfo.length; i++) {
      var fieldCoordinates = LatLng(stopsInfo[i].stopLat, stopsInfo[i].stopLon);
      var distanceUserToNextStop =
          calculateDistance(userLocation!, fieldCoordinates);
      var distanceDestinationToNextStop =
          calculateDistance(destination!, fieldCoordinates);

      if (distanceUserToNextStop < closestStopDistance) {
        //Aquí estamos actualizando los datos de la parada más cercana al origen del usuario:
        closestStopFromOriginData = stopsInfo[i];
        //Aquí estamos actualizando la distancia más corta de la parada más cercana al origen del usuario:
        closestStopDistance = distanceUserToNextStop;
      }

      if (distanceDestinationToNextStop < closestRouteDistance) {
        //Aquí estamos actualizando los datos de la parada más cercana al destino del usuario:
        closestStopFromDestinationData = stopsInfo[i];
        //Aquí estamos actualizando la distancia más corta de la parada más cercana del destino del usuario:
        closestRouteDistance = distanceDestinationToNextStop;
      }
    }
    // Si no hay rutas cerca del destino del usuario, informa al usuario
    if (closestRouteDistance > limitDistance) {
      print('No hay rutas cerca de tu destino.');
    } else {
      List<BusStopModel> busStopsInfo = gtfsProvider.dataGTFS!.busStopsInfo;
      List<BusStopModel> busesWithClosestStopFromOrigin = busStopsInfo
          .where(
              (element) => element.stopId == closestStopFromOriginData!.stopId)
          .toList();
      List<BusStopModel> busesWithClosestStopFromDestination = busStopsInfo
          .where((element) =>
              element.stopId == closestStopFromDestinationData!.stopId)
          .toList();

      //Determinar microbuses directos al destino:
      List<ShapeModel> shapesInfo = gtfsProvider.dataGTFS!.shapesInfo;
      final List<PossibleRouteToDestinationModel> possibleRoutesToDestination =
          [];

      /* Esta lógica une a los microbuses con el 'routeId' identicos que 
      tienen paradas cercanas al origen y al destino del usuario. */

      //Este es el inicio de un bucle que recorre cada microbus en la lista busesWithClosestStopFromOrigin:
      for (var busFromOrigin in busesWithClosestStopFromOrigin) {
        //Dentro del bucle anterior, este es otro bucle que recorre cada microbus en la lista busesWithClosestStopFromDestination:
        for (var busFromDestination in busesWithClosestStopFromDestination) {
          //En este if uno a los microbuses!, es una condición que verifica si el routeId del microbus desde el ORIGEN es igual al routeId del microbus desde el DESTINO:
          if (busFromOrigin.routeId == busFromDestination.routeId) {
            /* firstWhere es un método de las listas en Dart que te permite buscar el primer elemento que cumple con una condición específica. */

            var stopFromOrigin = stopsInfo
                .firstWhere((stop) => stop.stopId == busFromOrigin.stopId);
            //En este caso, busco la primera parada en stopsInfo que tenga el mismo stopId que el stopId del microbus desde el origen.
            var stopFromDestination = stopsInfo
                .firstWhere((stop) => stop.stopId == busFromDestination.stopId);

            LatLng coordinatesBusWithClosestStopFromOrigin =
                LatLng(stopFromOrigin.stopLat, stopFromOrigin.stopLon);
            LatLng coordinatesBusWithClosestStopFromDestination = LatLng(
                stopFromDestination.stopLat, stopFromDestination.stopLon);
            List<LatLng> coordinates = [
              coordinatesBusWithClosestStopFromOrigin,
            ];

            //En está parte del código se buscan las coordenas de Shapes que estén entre las paradas más cercanas al origen y al destino del usuario.
            for (var shape in shapesInfo) {
              if (shape.shapeId == busFromOrigin.routeId &&
                  busFromDestination.stopSequence > shape.stopSequence &&
                  shape.stopSequence > busFromOrigin.stopSequence) {
                LatLng shapeCoordinates =
                    LatLng(shape.shapePtLat, shape.shapePtLon);
                coordinates.add(shapeCoordinates);
              }
            }

            coordinates.add(coordinatesBusWithClosestStopFromDestination);

            routesInfo
                .where((element) => element.routeId == busFromOrigin.routeId)
                .forEach((element) {
              PossibleRouteToDestinationModel routeToDestination =
                  PossibleRouteToDestinationModel(
                routeId: busFromOrigin.routeId,
                coordinates: coordinates,
                routeShortName: element.routeShortName,
                routeLongName: element.routeLongName,
                routeType: element.routeType,
              );
              possibleRoutesToDestination.add(routeToDestination);
            });
          }
        }
      }
      controlsMapProvider.possibleRoutesToDestination =
          possibleRoutesToDestination;
      /* print(
          'controlsMapProvider.possibleRoutesToDestination ${controlsMapProvider.possibleRoutesToDestination}'); */
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
