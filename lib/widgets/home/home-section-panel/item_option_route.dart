import "package:flutter/material.dart";

class ItemOptionRoute extends StatelessWidget {
  const ItemOptionRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[300],
      borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {},
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
                    Text(
                      'Tiempo estimado al destino:',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Row(
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