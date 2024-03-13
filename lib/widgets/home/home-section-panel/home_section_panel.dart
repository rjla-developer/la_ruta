import "package:flutter/material.dart";

//Provider:
import "package:provider/provider.dart";

//Providers:
import "package:la_ruta/providers/controls_map_provider.dart";

//Widgets:
import "package:la_ruta/widgets/home/home-section-panel/item_option_route.dart";

class HomeSectionPanel extends StatelessWidget {
  const HomeSectionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controlsMapProvider = context.watch<ControlsMapProvider>();
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
                ...controlsMapProvider.posiblesRoutesToDestination.entries
                    .expand((entry) {
                  String nameRoute = entry.key;
                  var value = entry.value;
                  return [
                    ItemOptionRoute(nameRoute: nameRoute, value: value),
                    const SizedBox(
                      height: 20,
                    ),
                  ];
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


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