import 'package:flutter/material.dart';

//Latlong2:
import 'package:latlong2/latlong.dart';

//Geolocator:
import 'package:geolocator/geolocator.dart';

//SlidingUpPanel:
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ControlsMapProvider extends ChangeNotifier {
  LatLng? _userPosition;
  LatLng? _targetPosition;
  final PanelController _panelController = PanelController();
  List? _closeStopFromOrigin;
  List? _closeStopFromDestination;
  final List<LatLng> _route = [];

  LatLng? get userPosition => _userPosition;
  LatLng? get targetPosition => _targetPosition;
  PanelController get panelController => _panelController;
  List? get closeStopFromOrigin => _closeStopFromOrigin;
  List? get closeStopFromDestination => _closeStopFromDestination;
  List<LatLng> get route => _route;

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
  }

  void setCloseStopFromDestination(List value) {
    _closeStopFromDestination = value;
    notifyListeners();
  }

  ControlsMapProvider() {
    _setUserPosition().catchError((error) {
      /* print('Ocurrió un error al determinar la posición: $error'); */
    });
  }
}
