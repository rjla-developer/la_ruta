import 'package:flutter/material.dart';

//Dart:
import 'dart:async';

//Latlong2:
import 'package:latlong2/latlong.dart';

//Providers:
import 'package:provider/provider.dart';
import 'package:la_ruta/providers/controls_map_provider.dart';
import 'package:la_ruta/providers/gtfs_provider.dart';

//FlutterMapAnimations:
import 'package:flutter_map_animations/flutter_map_animations.dart';

//Utils:
import 'package:la_ruta/utils/get_searches.dart';
import 'package:la_ruta/utils/get_destination_coordinates.dart';

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
                                      responseLocations[i]['mapbox_id'],
                                      widget.animatedMapController);
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
                  _debounce =
                      Timer(const Duration(milliseconds: 200), () async {
                    if (controllerResponseInputSearch.text.isEmpty) {
                      setState(() => responseLocations = []);
                    } else {
                      final jsonData =
                          await getSearches(controllerResponseInputSearch);
                      setState(
                          () => responseLocations = jsonData['suggestions']);
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
