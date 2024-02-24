import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

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
  final _controllerResponseInputSearch = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> getSearches() async {
    /* var url = Uri.https('api.mapbox.com', '/search/searchbox/v1/suggest', {
      'q': responseInputSearch,
      'language': 'es',
      'country': 'mx',
      'proximity': '-99.23426591658529, 18.921791278067488',
      'session_token': '08aed845-b073-4761-88dd-bb2059d0caa8',
      'access_token': searchLocationAccessToken
    });
    var response = await http.get(url);
    print(response.body);
    setState(() {
      responseLocations = locationsFromJson(response.body);
    }); */

    String jsonString =
        await rootBundle.loadString('assets/jsons/search-places.json');

    Map<String, dynamic> jsonData = jsonDecode(jsonString);

    /* print(jsonData['suggestions'][0]['name']); */
    setState(() {
      responseLocations = jsonData['suggestions'];
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
          child: Material(
            color: const Color.fromARGB(248, 30, 30, 30),
            child: Column(
              children: [
                const SizedBox(height: 140.0),
                if (responseLocations != null)
                  for (var i = 0; i < responseLocations.length; i++)
                    SizedBox(
                      width: 350,
                      child: Column(
                        children: [
                          const SizedBox(height: 5.0),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _controllerResponseInputSearch.text =
                                    responseLocations?[i]['name'];
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
                                        responseLocations?[i]['name'] ??
                                            "No hay datos",
                                        style: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      Text(
                                        responseLocations?[i]['full_address'] ??
                                            "No hay datos",
                                        style: const TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                                255, 227, 220, 220)),
                                        maxLines: null,
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
                if (responseLocations == null)
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
                  controller: _controllerResponseInputSearch,
                  onChanged: (value) => {getSearches()},
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    hintText: "A dónde quieres ir?",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _controllerResponseInputSearch.clear(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
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
