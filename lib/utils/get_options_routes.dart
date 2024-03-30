//Dart:
import 'dart:math';

//Latlong2:
import 'package:latlong2/latlong.dart';

//Models:
import 'package:la_ruta/models/stop_model.dart';
import 'package:la_ruta/models/bus_stop_model.dart';
import 'package:la_ruta/models/shape_model.dart';
import 'package:la_ruta/models/route_model.dart';
import 'package:la_ruta/models/possible_route_to_destination_model.dart';

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
        .where((element) => element.stopId == closestStopFromOriginData!.stopId)
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
          LatLng coordinatesBusWithClosestStopFromDestination =
              LatLng(stopFromDestination.stopLat, stopFromDestination.stopLon);
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
              colorRoute: element.colorRoute,
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
