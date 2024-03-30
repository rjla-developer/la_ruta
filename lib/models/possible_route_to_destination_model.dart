import 'package:latlong2/latlong.dart';

class PossibleRouteToDestinationModel {
  final double routeId;
  final List<LatLng> coordinates;
  final String routeShortName;
  final String routeLongName;
  final String routeType;

  PossibleRouteToDestinationModel(
      {required this.routeId,
      required this.coordinates,
      required this.routeShortName,
      required this.routeLongName,
      required this.routeType});

  factory PossibleRouteToDestinationModel.fromList(List<String> data) {
    List<LatLng> coordinates = data[1].split(',').map((coordinate) {
      List<String> latLng =
          coordinate.replaceAll('(', '').replaceAll(')', '').split(',');
      return LatLng(double.parse(latLng[0]), double.parse(latLng[1]));
    }).toList();
    return PossibleRouteToDestinationModel(
        routeId: double.parse(data[0]),
        coordinates: coordinates,
        routeShortName: data[2],
        routeLongName: data[3],
        routeType: data[4]);
  }

  @override
  String toString() {
    return 'PossibleRouteToDestinationModel(routeId: $routeId, coordinates: $coordinates, routeShortName: $routeShortName, routeLongName: $routeLongName, routeType: $routeType)';
  }
}
