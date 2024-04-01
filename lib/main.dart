import 'package:flutter/material.dart';

//Providers:
import 'package:provider/provider.dart';

//Class providers:
import 'package:la_ruta/providers/controls_map_provider.dart';
import 'package:la_ruta/providers/gtfs_provider.dart';

//Screens:
import 'screens/splash.dart';

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
        ChangeNotifierProvider(create: (_) => GTFSProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: true,
        title: 'La Ruta',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const Splash(),
      ),
    );
  }
}
