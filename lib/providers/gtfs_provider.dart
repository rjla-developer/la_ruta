import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

//Dart:
import 'dart:convert';
import 'package:archive/archive.dart';
import 'dart:async';

//Models:
import 'package:la_ruta/models/providers/gtfs/stop_model.dart';
import 'package:la_ruta/models/providers/gtfs/bus_stop_model.dart';
import 'package:la_ruta/models/providers/gtfs/shape_model.dart';
import 'package:la_ruta/models/providers/gtfs/route_model.dart';
import 'package:la_ruta/models/providers/gtfs/trip_model.dart';

class GTFS {
  final List<Stop> _stopsInfo;
  final List<BusStop> _busStopsInfo;
  final List<Shape> _shapesInfo;
  final List<RouteModel> _routesInfo;
  final List<Trip> _tripsInfo;

  GTFS(
      {required List<Stop> stopsInfo,
      required List<BusStop> busStopsInfo,
      required List<Shape> shapesInfo,
      required List<RouteModel> routesInfo,
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
  List<RouteModel> get routesInfo => _routesInfo;
  List<Trip> get tripsInfo => _tripsInfo;

  @override
  String toString() {
    return 'GTFS(stopsInfo: $_stopsInfo, busStopsInfo: $_busStopsInfo, shapesInfo: $_shapesInfo, routesInfo: $_routesInfo, tripsInfo: $_tripsInfo)';
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
        .map((e) => RouteModel.fromList(e))
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
