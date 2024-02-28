import 'package:flutter/material.dart';

//Widgets:
import 'package:la_ruta/widgets/home/home-section-map/home_section_map.dart';
import 'package:la_ruta/widgets/home/home_section_search.dart';

//Latlong2:
import 'package:latlong2/latlong.dart';

//Functions:
/* import 'package:la_ruta/utils/get_routes.dart'; */

//FlutterMapAnimations:
import 'package:flutter_map_animations/flutter_map_animations.dart';

//FlutterMap:
import 'package:flutter_map/flutter_map.dart';

//SlidingUpPanel:
import 'package:sliding_up_panel/sliding_up_panel.dart';

const mapboxAccessToken =
    "sk.eyJ1IjoicmotZGV2ZWxvcGVyIiwiYSI6ImNsc2dkazgzdTFsbjIybG8wMmFtcXVwODMifQ.gJl_3nLWEv_E9SeT6H_PkQ";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  LatLng? targetPosition;
  late final animatedMapController = AnimatedMapController(vsync: this);
  bool useTransformer = true;
  bool show = false;
  static const useTransformerId = 'useTransformerId';
  final markers = ValueNotifier<List<AnimatedMarker>>([]);

  //SlidingUpPanel:
  final PanelController _panelController = PanelController();

  void setTargetPosition(LatLng position) {
    setState(() {
      targetPosition = position;
    });
    _panelController.open();
  }

  @override
  void dispose() {
    markers.dispose();
    animatedMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      renderPanelSheet: false,
      controller: _panelController,
      minHeight: 0,
      maxHeight: 300.0,
      panel: Container(
        decoration: const BoxDecoration(
            color: Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0)),
            boxShadow: [
              BoxShadow(
                blurRadius: 10.0,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 15.0,
                ),
              ),
              child: const Text(
                'Santa María - Buena vista - Calera',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          HomeSectionMap(
              targetPosition: targetPosition,
              animatedMapController: animatedMapController),
          HomeSectionSearch(setTargetPosition: setTargetPosition),

          /* Positioned(
            bottom: 60,
            left: 50,
            right: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    var route =
                        await getRoute("Santa María - Buena vista - Calera");
                    setState(() {
                      routePoints = route;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 15.0,
                    ),
                  ),
                  child: const Text(
                    'Santa María - Buena vista - Calera',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    var route = await getRoute(
                        "Santa María - Buena vista - Francisco Villa");
                    setState(() {
                      routePoints = route;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 15.0,
                    ),
                  ),
                  child: const Text(
                    'Santa María - Buena vista - Francisco Villa',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ), */
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => setState(() {
                show = !show;
              }),
              child: const Icon(Icons.grain),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => animatedMapController.animatedZoomOut(
                customId: useTransformer ? useTransformerId : null,
              ),
              tooltip: 'Zoom out',
              child: const Icon(Icons.zoom_out),
            ),
          ),
        ],
      ),
    );
  }
}
