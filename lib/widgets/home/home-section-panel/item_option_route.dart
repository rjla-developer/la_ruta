import "package:flutter/material.dart";

//Functions:
import "package:la_ruta/utils/get_routes.dart";

//Latlong2:
import "package:latlong2/latlong.dart";

class ItemOptionRoute extends StatefulWidget {
  final String nameRoute;
  final List<LatLng> value;
  const ItemOptionRoute(
      {super.key, required this.nameRoute, required this.value});

  @override
  State<ItemOptionRoute> createState() => _ItemOptionRouteState();
}

class _ItemOptionRouteState extends State<ItemOptionRoute> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[300],
      borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () => getRoute(context, widget.value),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              const Image(
                image: NetworkImage(
                  'https://queruta.mx/wp-content/uploads/2023/10/5.png',
                ),
                width: 100,
                height: 80,
              ),
              const SizedBox(
                width: 20,
              ),
              Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    const Text(
                      'Dirección:',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      widget.nameRoute,
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Tiempo estimado al destino:',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    const Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 12.0,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        Text(
                          '50 minutos',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
