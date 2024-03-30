import "package:flutter/material.dart";

//Provider:
import "package:provider/provider.dart";

//Providers:
import "package:la_ruta/providers/controls_map_provider.dart";

//Widgets:
import "package:la_ruta/widgets/home/home-section-panel/item_option_route.dart";

//Models:
import "package:la_ruta/models/possible_route_to_destination_model.dart";

class HomeSectionPanel extends StatefulWidget {
  const HomeSectionPanel({super.key});

  @override
  State<HomeSectionPanel> createState() => _HomeSectionPanelState();
}

class _HomeSectionPanelState extends State<HomeSectionPanel> {
  @override
  Widget build(BuildContext context) {
    final controlsMapProvider = context.watch<ControlsMapProvider>();
    final List<PossibleRouteToDestinationModel> possibleRoutesToDestination =
        controlsMapProvider.possibleRoutesToDestination;
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
        boxShadow: [
          BoxShadow(
            blurRadius: 10.0,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Container(
            width: 30,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 10, right: 10),
              children: [
                ...possibleRoutesToDestination
                    .expand((possibleRouteToDestination) {
                  return [
                    ItemOptionRoute(data: possibleRouteToDestination),
                    const SizedBox(
                      height: 20,
                    ),
                  ];
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
