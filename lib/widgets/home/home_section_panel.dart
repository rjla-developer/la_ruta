import "package:flutter/material.dart";

class HomeSectionPanel extends StatelessWidget {
  const HomeSectionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            color: Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0)),
            boxShadow: [
              BoxShadow(
                blurRadius: 10.0,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ]),
        child: const Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Text(
              "Panel",
              textAlign: TextAlign.center,
            ),
          ],
        ));
  }
}
