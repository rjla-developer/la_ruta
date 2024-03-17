import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

//Dart:
import 'dart:convert';
import 'package:archive/archive.dart';
import 'dart:async';

class GTFS {
  final List<Stop> _stopsInfo;
  final List<BusStop> _busStopsInfo;
  final List<Shape> _shapesInfo;
  final List<Route> _routesInfo;
  final List<Trip> _tripsInfo;

  GTFS(
      {required List<Stop> stopsInfo,
      required List<BusStop> busStopsInfo,
      required List<Shape> shapesInfo,
      required List<Route> routesInfo,
      required List<Trip> tripsInfo})
      : assert(
            stopsInfo.isNotEmpty, 'La lista de paradas no puede estar vacía.'),
        assert(busStopsInfo.isNotEmpty,
            'La lista de paradas de autobús no puede estar vacía.'),
        assert(
            shapesInfo.isNotEmpty, 'La lista de formas no puede estar vacía.'),
        assert(
            routesInfo.isNotEmpty, 'La lista de rutas no puede estar vacía.'),
        assert(
            tripsInfo.isNotEmpty, 'La lista de viajes no puede estar vacía.'),
        _stopsInfo = stopsInfo,
        _busStopsInfo = busStopsInfo,
        _shapesInfo = shapesInfo,
        _routesInfo = routesInfo,
        _tripsInfo = tripsInfo;

  List<Stop> get stopsInfo => _stopsInfo;
  List<BusStop> get busStopsInfo => _busStopsInfo;
  List<Shape> get shapesInfo => _shapesInfo;
  List<Route> get routesInfo => _routesInfo;
  List<Trip> get tripsInfo => _tripsInfo;

  @override
  String toString() {
    return 'GTFS(stopsInfo: $_stopsInfo, busStopsInfo: $_busStopsInfo, shapesInfo: $_shapesInfo, routesInfo: $_routesInfo, tripsInfo: $_tripsInfo)';
  }
}

class Stop {
  final int stopId;
  final String stopName;
  final double stopLat;
  final double stopLon;

  Stop(
      {required this.stopId,
      required this.stopName,
      required this.stopLat,
      required this.stopLon});

  factory Stop.fromList(List<String> data) {
    return Stop(
      stopId: int.parse(data[0]),
      stopName: data[1],
      stopLat: double.parse(data[2]),
      stopLon: double.parse(data[3]),
    );
  }

  @override
  String toString() {
    return 'Stop(stopId: $stopId, stopName: $stopName, stopLat: $stopLat, stopLon: $stopLon)';
  }
}

class BusStop {
  final double routeId;
  final int stopId;
  final int stopSequence;

  BusStop(
      {required this.routeId,
      required this.stopId,
      required this.stopSequence});

  factory BusStop.fromList(List<String> data) {
    return BusStop(
      routeId: double.parse(data[0]),
      stopId: int.parse(data[1]),
      stopSequence: int.parse(data[2]),
    );
  }

  @override
  String toString() {
    return 'BusStop(routeId: $routeId, stopId: $stopId, stopSequence: $stopSequence)';
  }
}

class Shape {
  final double shapeId;
  final double shapePtLat;
  final double shapePtLon;
  final int shapePtSequence;

  Shape(
      {required this.shapeId,
      required this.shapePtLat,
      required this.shapePtLon,
      required this.shapePtSequence});

  factory Shape.fromList(List<String> data) {
    return Shape(
      shapeId: double.parse(data[0]),
      shapePtLat: double.parse(data[1]),
      shapePtLon: double.parse(data[2]),
      shapePtSequence: int.parse(data[3]),
    );
  }

  @override
  String toString() {
    return 'Shape(shapeId: $shapeId, shapePtLat: $shapePtLat, shapePtLon: $shapePtLon, shapePtSequence: $shapePtSequence)';
  }
}

class Route {
  final double routeId;
  final String agencyId;
  final String routeShortName;
  final String routeLongName;
  final String routeType;

  Route(
      {required this.routeId,
      required this.agencyId,
      required this.routeShortName,
      required this.routeLongName,
      required this.routeType});

  factory Route.fromList(List<String> data) {
    return Route(
      routeId: double.parse(data[0]),
      agencyId: data[1],
      routeShortName: data[2],
      routeLongName: data[3],
      routeType: data[4],
    );
  }

  @override
  String toString() {
    return 'Route(routeId: $routeId, agencyId: $agencyId, routeShortName: $routeShortName, routeLongName: $routeLongName, routeType: $routeType)';
  }
}

class Trip {
  final String tripId;
  final double routeId;
  final String serviceId;
  final double shapeId;

  Trip(
      {required this.tripId,
      required this.routeId,
      required this.serviceId,
      required this.shapeId});

  factory Trip.fromList(List<String> data) {
    return Trip(
      tripId: data[0],
      routeId: double.parse(data[1]),
      serviceId: data[2],
      shapeId: double.parse(data[3]),
    );
  }

  @override
  String toString() {
    return 'Trip(tripId: $tripId, routeId: $routeId, serviceId: $serviceId, shapeId: $shapeId)';
  }
}

class GTFSProvider extends ChangeNotifier {
  GTFS? _dataGTFS;

  GTFS? get dataGTFS => _dataGTFS;

  Future<void> _getDataGTFS() async {
    Future<List<List<String>>> processFile(
        Archive archive, String fileName) async {
      //processFile toma un archivo de un archivo ZIP y devuelve una lista de listas de Strings.
      final List<List<String>> fileInfo = [];
      final file = archive.findFile(fileName);

      if (file != null) {
        final data = utf8.decode(file.content);
        final splitByLinesData = data.split('\n');

        for (int i = 1; i < splitByLinesData.length; i++) {
          var fields = splitByLinesData[i].split(',');
          if (fields.length >= 3) {
            fileInfo.add(fields);
          }
        }
      } else {
        print('No se pudo encontrar el archivo $fileName en el archivo ZIP.');
      }

      return fileInfo;
    }

    //Aquí estamos leyendo el contenido del archivo.
    final byteData = await rootBundle.load('assets/gtfs/ruta3_ahuatlan.zip');
    //Aquí estamos leyendo el archivo.
    final bytes = byteData.buffer.asUint8List();
    //Aquí estamos descomprimiendo el archivo, ya que viene en un archivo (.zip).
    final archive = ZipDecoder().decodeBytes(bytes);

    final stopsInfo = (await processFile(archive, 'ruta3_ahuatlan/stops.txt'))
        .map((e) => Stop.fromList(e))
        .toList(); //Toda esta linea trata sobre crear una instancia de la clase correspondiente y devolverlo como una lista .
    final busStopsInfo =
        (await processFile(archive, 'ruta3_ahuatlan/bus_stops.txt'))
            .map((e) => BusStop.fromList(e))
            .toList();
    final shapesInfo = (await processFile(archive, 'ruta3_ahuatlan/shapes.txt'))
        .map((e) => Shape.fromList(e))
        .toList();
    final routesInfo = (await processFile(archive, 'ruta3_ahuatlan/routes.txt'))
        .map((e) => Route.fromList(e))
        .toList();
    final tripsInfo = (await processFile(archive, 'ruta3_ahuatlan/trips.txt'))
        .map((e) => Trip.fromList(e))
        .toList();

    if (stopsInfo.isEmpty ||
        busStopsInfo.isEmpty ||
        shapesInfo.isEmpty ||
        routesInfo.isEmpty ||
        tripsInfo.isEmpty) {
      return Future.error('No se encontró información en el archivo GTFS.');
    } else {
      _dataGTFS = GTFS(
          stopsInfo: stopsInfo,
          busStopsInfo: busStopsInfo,
          shapesInfo: shapesInfo,
          routesInfo: routesInfo,
          tripsInfo: tripsInfo);
    }

    /* print(dataGTFS); */
  }

  GTFSProvider() {
    _getDataGTFS().catchError((error) {
      print('Ocurrió un error con el archivo GTFS: $error');
    });
  }
}
