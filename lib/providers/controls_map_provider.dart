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

class ControlsMapProvider extends ChangeNotifier {
  LatLng? _userPosition;
  LatLng? _targetPosition;
  final PanelController _panelController = PanelController();
  List? _closeStopFromOrigin; //Posiblemente se quite
  List? _closeStopFromDestination; //Posiblemente se quite
  final List<LatLng> _route = [];
  List<List<String>> _stopsInfo = [];

//Getters:
  LatLng? get userPosition => _userPosition;
  LatLng? get targetPosition => _targetPosition;
  PanelController get panelController => _panelController;
  List? get closeStopFromOrigin => _closeStopFromOrigin; //Posiblemente se quite
  List? get closeStopFromDestination =>
      _closeStopFromDestination; //Posiblemente se quite
  List<LatLng> get route => _route;
  List<List<String>> get stopsInfo => _stopsInfo;

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

  void setCloseStopFromOrigin(List value) {
    _closeStopFromOrigin = value;
    notifyListeners();
  } //Posiblemente se quite

  void setCloseStopFromDestination(List value) {
    _closeStopFromDestination = value;
    notifyListeners();
  } //Posiblemente se quite

  Future<void> _getStopsInfo() async {
    //Aquí estamos abriendo un archivo que contiene información sobre todas las rutas de autobús.
    final byteData = await rootBundle.load('assets/gtfs/ruta3_ahuatlan.zip');
    //Aquí estamos leyendo el archivo.
    final bytes = byteData.buffer.asUint8List();
    //Aquí estamos descomprimiendo el archivo, ya que viene en un archivo (.zip).
    final archive = ZipDecoder().decodeBytes(bytes);
    //Aquí estamos buscando el archivo que contiene la información de las rutas de autobús.
    final stopsFile = archive.findFile('ruta3_ahuatlan/stops.txt');

    if (stopsFile != null) {
      //Aquí estamos leyendo el contenido del archivo.
      final stopsData = utf8.decode(stopsFile.content);
      //Aquí estamos dividiendo el contenido del archivo en líneas, ya que el archivo 'stops.txt', es un archivo de texto que contiene varias líneas de datos.
      final splitByLinesStopData = stopsData.split('\n');

      for (int i = 0; i < splitByLinesStopData.length; i++) {
        //Aquí estamos dividiendo cada línea en campos.
        var fields = splitByLinesStopData[i].split(',');

        //Aquí estamos agregando los campos de cada línea a la lista de formas de las rutas de autobús.
        //En este caso no se necesita pero en el futuro quiero mostrar todas las paradas de las rutas en el mapa.
        //Esa variable tendra toda la informacion de las paradas de las rutas de autobus.
        _stopsInfo.add(fields);
      }
    }
  }

  ControlsMapProvider() {
    _setUserPosition().catchError((error) {
      print('Ocurrió un error al determinar la posición: $error');
    });
    _getStopsInfo().catchError((error) {
      print('Ocurrió un error al obtener las paradas: $error');
    });
  }
}
