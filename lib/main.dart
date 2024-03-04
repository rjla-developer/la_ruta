import 'package:flutter/material.dart';

//Providers:
import 'package:provider/provider.dart';

//Class providers:
import 'package:la_ruta/providers/controls_map_provider.dart';

//Screens:
import 'screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ControlsMapProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: true,
        title: 'La Ruta',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const Home(),
      ),
    );
  }
}
