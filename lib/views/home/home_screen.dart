import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../controllers/auth_controller.dart';
import '../../controllers/vehicle_controller.dart';
import '../../models/vehicle.dart';
import 'add_edit_vehicle_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    await Provider.of<VehicleController>(context, listen: false).loadVehicles();
  }

  @override
  Widget build(BuildContext context) {
    final vehicleController = Provider.of<VehicleController>(context);
    final authController = Provider.of<AuthController>(context);

      print("Vehículos cargados: ${vehicleController.vehicles.length}");
  vehicleController.vehicles.forEach((v) {
    print("Vehículo: ${v.placa} - Imagen: ${v.imagePath}");
  });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehículos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authController.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, '/addVehicle'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadVehicles,
        child:
            vehicleController.vehicles.isEmpty
                ? const Center(child: Text('No hay vehículos registrados'))
                : ListView.builder(
                  itemCount: vehicleController.vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = vehicleController.vehicles[index];
                    return _buildVehicleCard(vehicle, context);
                  },
                ),
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle, BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: _buildVehicleImage(vehicle),
        title: Text('${vehicle.marca} - ${vehicle.placa}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Año: ${vehicle.anio}'),
            Text('Color: ${vehicle.color}'),
            Text(
              '\$${vehicle.costoPorDia.toStringAsFixed(2)}/día',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Chip(
              label: Text(
                vehicle.activo ? 'Disponible' : 'No disponible',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: vehicle.activo ? Colors.green : Colors.red,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed:
                  () => Navigator.pushNamed(
                    context,
                    '/editVehicle',
                    arguments: vehicle,
                  ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, vehicle),
            ),
          ],
        ),
      ),
    );
  }
  

  Widget _buildVehicleImage(Vehicle vehicle) {
  if (vehicle.imagePath != null) {
    try {
      return Image.asset(
        vehicle.imagePath!,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("Error cargando imagen: ${vehicle.imagePath}");
          return const Icon(Icons.error);
        },
      );
    } catch (e) {
      print("Excepción al cargar imagen: $e");
      return const Icon(Icons.car_repair);
    }
  }
  return const Icon(Icons.car_repair);
}

  Future<void> _confirmDelete(BuildContext context, Vehicle vehicle) async {
    final vehicleController = Provider.of<VehicleController>(
      context,
      listen: false,
    );
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Text('¿Eliminar ${vehicle.marca} ${vehicle.placa}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  await vehicleController.deleteVehicle(vehicle.placa);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${vehicle.placa} eliminado')),
                  );
                },
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  
}


