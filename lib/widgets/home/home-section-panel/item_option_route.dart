import "package:flutter/material.dart";

//Models:
import "package:la_ruta/models/possible_route_to_destination_model.dart";

//Functions:
import "package:la_ruta/utils/get_routes.dart";

//Latlong2:
import "package:latlong2/latlong.dart";

class ItemOptionRoute extends StatefulWidget {
  final PossibleRouteToDestinationModel data;
  const ItemOptionRoute({super.key, required this.data});

  @override
  State<ItemOptionRoute> createState() => _ItemOptionRouteState();
}

class _ItemOptionRouteState extends State<ItemOptionRoute> {
  @override
  Widget build(BuildContext context) {
    Color colorRoute = widget.data.colorRoute;
    List<LatLng> coordinates = widget.data.coordinates;
    double routeId = widget.data.routeId;
    String routeShortName = widget.data.routeShortName;
    String routeLongName = widget.data.routeLongName;

    return Material(
      color: Colors.grey[300],
      borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () => getRoute(context, coordinates, colorRoute),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Image(
                image: AssetImage(routeId == 3.0
                    ? 'assets/images/ruta_3.png'
                    : 'assets/images/ruta_1.png'),
                width: 100,
                height: 80,
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routeShortName,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Text(
                        'Dirección:',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        routeLongName,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
