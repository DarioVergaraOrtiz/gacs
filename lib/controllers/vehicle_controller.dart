import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle.dart';

class VehicleController with ChangeNotifier {
  List<Vehicle> _vehicles = [];

  List<Vehicle> get vehicles => _vehicles;

Future<void> loadVehicles() async {
  final prefs = await SharedPreferences.getInstance();
  final vehicleStrings = prefs.getStringList('vehicles');

  if (vehicleStrings == null || vehicleStrings.isEmpty) {
    // Vehículos por defecto si no hay datos
_vehicles = [
  Vehicle(
    placa: 'ABC123',
    marca: 'Toyota',
    anio: 2020,
    color: 'Rojo',
    costoPorDia: 50.0,
    imagePath: 'assets/car1.png',
  ),
  Vehicle(
    placa: 'XYZ789',
    marca: 'Honda',
    anio: 2019,
    color: 'Azul',
    costoPorDia: 45.0,
    imagePath: 'assets/car2.png',
  ),
];

    await _saveVehicles(); // Guardar en SharedPreferences
  } else {
    _vehicles = vehicleStrings.map((vehicleString) {
      try {
        final vehicleMap = json.decode(vehicleString);
        return Vehicle.fromMap(Map<String, dynamic>.from(vehicleMap));
      } catch (e) {
        print('Error decoding vehicle: $e');
        return Vehicle(
          placa: 'Error',
          marca: 'Error',
          anio: 0,
          color: 'Error',
          costoPorDia: 0.0,
        );
      }
    }).toList();
  }

  notifyListeners();
}

  Future<void> _saveVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'vehicles',
      _vehicles.map((v) => json.encode(v.toMap())).toList(),
    );
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    _vehicles.add(vehicle);
    await _saveVehicles();
    notifyListeners();
  }

  Future<void> updateVehicle(String placa, Vehicle newVehicle) async {
    final index = _vehicles.indexWhere((v) => v.placa == placa);
    if (index != -1) {
      _vehicles[index] = newVehicle;
      await _saveVehicles();
      notifyListeners();
    }
  }

  Future<void> deleteVehicle(String placa) async {
    _vehicles.removeWhere((v) => v.placa == placa);
    await _saveVehicles();
    notifyListeners();
  }
}