import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

//Latlong2:
import 'package:latlong2/latlong.dart';

//Geolocator:
import 'package:geolocator/geolocator.dart';

//SlidingUpPanel:
import 'package:sliding_up_panel/sliding_up_panel.dart';

//Dart:
import 'dart:convert';
import 'package:archive/archive.dart';
import 'dart:async';

class GTFS {
  final List<List<String>> _stopsInfo;
  final Map<String, List<LatLng>> _shapesInfo;

  GTFS(
      {required List<List<String>> stopsInfo,
      required Map<String, List<LatLng>> shapesInfo})
      : assert(
            stopsInfo.isNotEmpty, 'La lista de paradas no puede estar vacía.'),
        assert(
            shapesInfo.isNotEmpty, 'La lista de formas no puede estar vacía.'),
        _stopsInfo = stopsInfo,
        _shapesInfo = shapesInfo;

  get stopsInfo => _stopsInfo;
  get shapesInfo => _shapesInfo;

  @override
  String toString() {
    return 'GTFS(stopsInfo: $_stopsInfo, shapesInfo: $_shapesInfo)';
  }
}

class ControlsMapProvider extends ChangeNotifier {
  LatLng? _userPosition;
  LatLng? _targetPosition;
  final PanelController _panelController = PanelController();
  final List<LatLng> _route = [];
  final Map<String, List<LatLng>> _posiblesRoutesToDestination = {};
  GTFS? _dataGTFS;

//Getters:
  LatLng? get userPosition => _userPosition;
  LatLng? get targetPosition => _targetPosition;
  PanelController get panelController => _panelController;
  List<LatLng> get route => _route;
  Map<String, List<LatLng>> get posiblesRoutesToDestination =>
      _posiblesRoutesToDestination;
  GTFS? get dataGTFS => _dataGTFS;

//Setters:
  Future<void> _setUserPosition() async {
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
    _userPosition = LatLng(
        userPositionDetermined.latitude, userPositionDetermined.longitude);
    notifyListeners();
  }

  void setTargetPosition(LatLng position) {
    if (position == const LatLng(0, 0)) {
      _targetPosition = null;
      panelController.close();
    } else {
      _targetPosition = position;
      panelController.open();
    }
    notifyListeners();
  }

  set route(List<LatLng> value) {
    _route.clear();
    _route.addAll(value);
    notifyListeners();
  }

  Future<void> _getDataGTFS() async {
    bool _isNumeric(String s) {
      if (s == null) {
        return false;
      }
      return double.tryParse(s) != null;
    }

    final List<List<String>> stopsInfo = [];
    final Map<String, List<LatLng>> shapesInfo = {};

    //Aquí estamos abriendo un archivo que contiene información sobre todas las rutas de autobús.
    final byteData = await rootBundle.load('assets/gtfs/ruta3_ahuatlan.zip');
    //Aquí estamos leyendo el archivo.
    final bytes = byteData.buffer.asUint8List();
    //Aquí estamos descomprimiendo el archivo, ya que viene en un archivo (.zip).
    final archive = ZipDecoder().decodeBytes(bytes);

    //Aquí estamos buscando el archivo que contiene la información de las rutas de autobús.
    final stopsFile = archive.findFile('ruta3_ahuatlan/stops.txt');
    final shapesFile = archive.findFile('ruta3_ahuatlan/shapes.txt');

    if (stopsFile != null) {
      //Aquí estamos leyendo el contenido del archivo.
      final stopsData = utf8.decode(stopsFile.content);
      //Aquí estamos dividiendo el contenido del archivo en líneas, ya que el archivo 'stops.txt', es un archivo de texto que contiene varias líneas de datos.
      final splitByLinesStopData = stopsData.split('\n');

      for (int i = 1; i < splitByLinesStopData.length; i++) {
        //El 0 es el encabezado por eso empezamos en 1
        //Aquí estamos dividiendo cada línea en campos.
        var fields = splitByLinesStopData[i].split(',');

        //Aquí estamos agregando los campos de cada línea a la lista de formas de las rutas de autobús.
        //En este caso no se necesita pero en el futuro quiero mostrar todas las paradas de las rutas en el mapa.
        //Esa variable tendra toda la informacion de las paradas de las rutas de autobus.
        stopsInfo.add(fields);
      }
      /* print('stopsInfo: $stopsInfo'); */
    }

    if (shapesFile != null) {
      //Aquí estamos leyendo el contenido del archivo.
      final shapesData = utf8.decode(shapesFile.content);
      //Aquí estamos dividiendo el contenido del archivo en líneas, ya que el archivo 'shapes.txt', es un archivo de texto que contiene varias líneas de datos.
      final splitByLinesShapesData = shapesData.split('\n');

      for (int i = 0; i < splitByLinesShapesData.length; i++) {
        //Aquí estamos dividiendo cada línea en campos.
        var fields = splitByLinesShapesData[i].split(',');

        if (_isNumeric(fields[1]) && _isNumeric(fields[2])) {
          var coordinates =
              LatLng(double.parse(fields[1]), double.parse(fields[2]));

          if (shapesInfo.containsKey(fields[0])) {
            shapesInfo[fields[0]]?.add(coordinates);
          } else {
            shapesInfo[fields[0]] = [coordinates];
          }
        }
      }
      /* print('shapesMap: $shapesInfo'); */
    }

    if (stopsInfo.isEmpty || shapesInfo.isEmpty) {
      return Future.error('No se encontró información en el archivo GTFS.');
    } else {
      _dataGTFS = GTFS(stopsInfo: stopsInfo, shapesInfo: shapesInfo);
    }
  }

  set posiblesRoutesToDestination(Map<String, List<LatLng>> value) {
    _posiblesRoutesToDestination.clear();
    _posiblesRoutesToDestination.addAll(value);
    notifyListeners();
  }

  ControlsMapProvider() {
    _setUserPosition().catchError((error) {
      print('Ocurrió un error al determinar la posición: $error');
    });
    _getDataGTFS().catchError((error) {
      print('Ocurrió un error con el archivo GTFS: $error');
    });
  }
}
