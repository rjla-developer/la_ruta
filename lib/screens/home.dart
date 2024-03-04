import 'package:flutter/material.dart';

//Widgets:
import 'package:la_ruta/widgets/home/home-section-map/home_section_map.dart';
import 'package:la_ruta/widgets/home/home_section_search.dart';
import 'package:la_ruta/widgets/home/home_section_panel.dart';

//Functions:
/* import 'package:la_ruta/utils/get_routes.dart'; */

//FlutterMapAnimations:
import 'package:flutter_map_animations/flutter_map_animations.dart';

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
          const HomeSectionSearch(),
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
