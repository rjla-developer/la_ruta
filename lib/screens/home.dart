import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

//Dart:
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:csv/csv.dart';

//Widgets:
import 'package:la_ruta/widgets/home/home-section-map/home_section_map.dart';
import 'package:la_ruta/widgets/home/home_section_search.dart';
import 'package:la_ruta/widgets/home/home_section_panel.dart';

//FlutterMapAnimations:
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';

//SlidingUpPanel:
import 'package:sliding_up_panel/sliding_up_panel.dart';

//Providers:
import 'package:provider/provider.dart';
import 'package:la_ruta/providers/controls_map_provider.dart';

const mapboxAccessToken =
    "sk.eyJ1IjoicmotZGV2ZWxvcGVyIiwiYSI6ImNsc2dkazgzdTFsbjIybG8wMmFtcXVwODMifQ.gJl_3nLWEv_E9SeT6H_PkQ";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late final animatedMapController = AnimatedMapController(vsync: this);

  @override
  void dispose() {
    animatedMapController.dispose();
    super.dispose();
  }

  void loadGtfsData(BuildContext context) async {
    final controlsMapProvider =
        Provider.of<ControlsMapProvider>(context, listen: false);

    final byteData = await rootBundle.load('assets/gtfs/ruta3_ahuatlan.zip');
    final bytes = byteData.buffer.asUint8List();
    final archive = ZipDecoder().decodeBytes(bytes);

    /* for (var file in archive) {
      print(file.name);
    } */

    final shapesFile = archive.findFile('ruta3_ahuatlan/shapes.txt');

    if (shapesFile != null) {
      final shapesData = utf8.decode(shapesFile.content);
      final lines = shapesData.split('\n');
      List<List<String>> shapes = [];

      for (var line in lines) {
        var fields = line.split(',');
        shapes.add(fields);
      }

      List<LatLng> routePoints = [];

      for (int i = 1; i < shapes.length; i++) {
        var shape = shapes[i];
        double lat = double.parse(shape[1]);
        double lon = double.parse(shape[2]);
        routePoints.add(LatLng(lat, lon));
      }

      controlsMapProvider.route = routePoints;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controlsMapProvider = context.watch<ControlsMapProvider>();
    return SlidingUpPanel(
      renderPanelSheet: false,
      controller: controlsMapProvider.panelController,
      minHeight: 0,
      maxHeight: 300.0,
      panel: const HomeSectionPanel(),
      body: Stack(
        children: <Widget>[
          HomeSectionMap(
            animatedMapController: animatedMapController,
          ),
          HomeSectionSearch(
            animatedMapController: animatedMapController,
          ),
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => loadGtfsData(context),
              tooltip: 'Zoom out',
              child: const Icon(Icons.remove_red_eye),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => animatedMapController.animatedZoomOut(
                customId: '_useTransformerId',
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
