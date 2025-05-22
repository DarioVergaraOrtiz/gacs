import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'controllers/auth_controller.dart';
import 'controllers/vehicle_controller.dart';
import 'models/vehicle.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/home/home_screen.dart';
import 'views/home/add_edit_vehicle_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Limpiar datos solo en desarrollo
  await prefs.clear();

  if (!prefs.containsKey('vehicles')) {
    final vehicles = [
      Vehicle(
        placa: 'ABC123',
        marca: 'Toyota',
        anio: 2022,
        color: 'Blanco',
        costoPorDia: 45.99,
        imagePath: 'assets/car1.jpg', 
      ),
      Vehicle(
        placa: 'XYZ789',
        marca: 'Honda',
        anio: 2021,
        color: 'Plomo',
        costoPorDia: 39.99,
        imagePath: 'assets/car2.jpg',
      ),
            Vehicle(
        placa: 'ABZ777',
        marca: 'Ford',
        anio: 2021,
        color: 'Rojo',
        costoPorDia: 39.99,
        imagePath: 'assets/car3.png',
      ),
    ];
    
    await prefs.setStringList(
      'vehicles',
      vehicles.map((v) => json.encode(v.toMap())).toList(),
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(
          create: (_) => VehicleController()..loadVehicles(), // Cargar vehículos al inicio
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vehicle App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/addVehicle': (context) => const AddEditVehicleScreen(),
        '/editVehicle': (context) => AddEditVehicleScreen(
              vehicle: ModalRoute.of(context)!.settings.arguments as Vehicle,
            ),
      },
    );
  }
}