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

  LatLng? get userPosition => _userPosition;
  LatLng? get targetPosition => _targetPosition;
  PanelController get panelController => _panelController;

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
      notifyListeners();
    } else {
      _targetPosition = position;
      panelController.open();
      notifyListeners();
    }
    final points = [_userPosition, _targetPosition];

    /* animatedMapController.animatedFitCamera(
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
    ); */
  }

  ControlsMapProvider() {
    _setUserPosition().catchError((error) {
      /* print('Ocurrió un error al determinar la posición: $error'); */
    });
  }
}
