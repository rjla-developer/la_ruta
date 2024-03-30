import 'package:flutter/material.dart';

class RouteModel {
  final double routeId;
  final String agencyId;
  final String routeShortName;
  final String routeLongName;
  final String routeType;
  final Color colorRoute;

  RouteModel(
      {required this.routeId,
      required this.agencyId,
      required this.routeShortName,
      required this.routeLongName,
      required this.routeType,
      required this.colorRoute});

  factory RouteModel.fromList(List<String> data) {
    return RouteModel(
      routeId: double.parse(data[0]),
      agencyId: data[1],
      routeShortName: data[2],
      routeLongName: data[3],
      routeType: data[4],
      colorRoute: Color(int.parse('FF${data[5]}', radix: 16)),
    );
  }

  @override
  String toString() {
    return 'RouteModel(routeId: $routeId, agencyId: $agencyId, routeShortName: $routeShortName, routeLongName: $routeLongName, routeType: $routeType, colorRoute: $colorRoute)';
  }
}
