import "package:flutter/material.dart";

class HomeSectionPanel extends StatelessWidget {
  const HomeSectionPanel({super.key});

  @override
  Widget build(BuildContext context) {
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
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.all(Radius.circular(12.0)),
              ),
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Image(
                      image: NetworkImage(
                        'https://queruta.mx/wp-content/uploads/2023/10/5.png',
                      ),
                      width: 100,
                      height: 80,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Material(
                      color: Colors.transparent,
                      child: Column(
                        /* crossAxisAlignment: CrossAxisAlignment.end, */
                        children: [
                          Text(
                            'Dirección:',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            'Santa María - Buena vista - Calera',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          /* Text(
                            'Esta ruta llega cada:',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            '8 a 10 minutos',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ), */
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
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