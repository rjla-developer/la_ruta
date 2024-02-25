import 'package:flutter/material.dart';

//Widgets:
import 'package:la_ruta/widgets/home/home-section-map/home_section_map.dart';
import 'package:la_ruta/widgets/home/home_section_search.dart';

//Latlong2:
import 'package:latlong2/latlong.dart';

const searchLocationAccessToken =
    "pk.eyJ1IjoicmotZGV2ZWxvcGVyIiwiYSI6ImNsa3JpOXNudDB2dG8zcXFtN3RqYzk2ZngifQ.OjfZuB4ku290h-qvB-BecA";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<LatLng> routePoints = [];
  final controllerResponseInputSearch = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        HomeSectionMap(routePoints: routePoints),
        HomeSectionSearch(
            controllerResponseInputSearch: controllerResponseInputSearch),
        /* Positioned(
          bottom: 60,
          left: 50,
          right: 50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  var result =
                      await getRoute("Santa María - Buena vista - Calera");
                  setState(() {
                    routePoints = result;
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
                  var result = await getRoute(
                      "Santa María - Buena vista - Francisco Villa");
                  setState(() {
                    routePoints = result;
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
      ],
    );
  }
}
