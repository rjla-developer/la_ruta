import 'package:flutter/material.dart';

//Widgets:
import 'package:la_ruta/widgets/home/home-section-map/home_section_map.dart';
import 'package:la_ruta/infrastructure/models/locations.dart';

//Latlong2:
import 'package:latlong2/latlong.dart';

//Functions:
import 'package:la_ruta/utils/get_routes.dart';

//Http:
import 'package:http/http.dart' as http;

const searchLocationAccessToken =
    "pk.eyJ1IjoicmotZGV2ZWxvcGVyIiwiYSI6ImNsa3JpOXNudDB2dG8zcXFtN3RqYzk2ZngifQ.OjfZuB4ku290h-qvB-BecA";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<LatLng> routePoints = [];
  var responseLocations;
  String inputSearchLocation = "";

  @override
  void initState() {
    super.initState();
  }

  Future<void> getSearches() async {
    var url = Uri.https('api.mapbox.com', '/search/searchbox/v1/suggest', {
      'q': inputSearchLocation,
      'language': 'es',
      'session_token': '0c7aeceb-2101-4e31-88dc-f0be2dc05108',
      'access_token': searchLocationAccessToken
    });
    var response = await http.get(url);
    print(response.body);
    setState(() {
      responseLocations = locationsFromJson(response.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        HomeSectionMap(routePoints: routePoints),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Center(
            child: SizedBox(
              width: double.infinity,
              child: Material(
                color: Colors.grey,
                child: Column(
                  children: [
                    const SizedBox(height: 160.0),
                    Text(
                      responseLocations?.suggestions[0].name ?? "No hay datos",
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      responseLocations?.suggestions[1].name ?? "No hay datos",
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      responseLocations?.suggestions[2].name ?? "No hay datos",
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      responseLocations?.suggestions[3].name ?? "No hay datos",
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10.0),
                  ],
                ),
              ),
            ),
          ),
        ),
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
                  onChanged: (value) => {
                    setState(() {
                      inputSearchLocation = value;
                    }),
                    getSearches()
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
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
        ),
      ],
    );
  }
}
