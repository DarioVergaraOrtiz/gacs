import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../controllers/vehicle_controller.dart';
import '../../models/vehicle.dart';

class AddEditVehicleScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const AddEditVehicleScreen({Key? key, this.vehicle}) : super(key: key);

  @override
  _AddEditVehicleScreenState createState() => _AddEditVehicleScreenState();
}

class _AddEditVehicleScreenState extends State<AddEditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _placaController;
  late TextEditingController _marcaController;
  late TextEditingController _anioController;
  late TextEditingController _colorController;
  late TextEditingController _costoController;
  File? _imageFile;
  String? _selectedAsset;
  bool _activo = true;

  final List<String> _assetImages = [
    'assets/car1.jpg',
    'assets/car2.jpg',
    'assets/car3.png',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _placaController = TextEditingController(text: widget.vehicle?.placa ?? '');
    _marcaController = TextEditingController(text: widget.vehicle?.marca ?? '');
    _anioController = TextEditingController(
      text: widget.vehicle?.anio.toString() ?? '',
    );
    _colorController = TextEditingController(text: widget.vehicle?.color ?? '');
    _costoController = TextEditingController(
      text: widget.vehicle?.costoPorDia.toString() ?? '',
    );
    _activo = widget.vehicle?.activo ?? true;
  }

  Future<void> _pickImage() async {
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Seleccionar imagen'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galería'),
                  onTap: () => _getFromGallery(),
                ),
              ],
            ),
          ),
    );

    if (result == 'gallery') {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _selectedAsset = null;
        });
      }
    }
  }

  void _getFromGallery() {
    Navigator.pop(context, 'gallery');
  }

  void _showAssetSelection() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Seleccionar imagen de assets'),
            content: SizedBox(
              width: double.maxFinite,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _assetImages.length,
                itemBuilder:
                    (context, index) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAsset = _assetImages[index];
                          _imageFile = null;
                        });
                        Navigator.pop(context);
                      },
                      child: Image.asset(_assetImages[index]),
                    ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.vehicle == null ? 'Nuevo Vehículo' : 'Editar Vehículo',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _buildImagePreview(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _placaController,
                decoration: const InputDecoration(labelText: 'Placa'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _marcaController,
                decoration: const InputDecoration(labelText: 'Marca'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _anioController,
                decoration: const InputDecoration(labelText: 'Año'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Color'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _costoController,
                decoration: const InputDecoration(labelText: 'Costo por día'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              SwitchListTile(
                title: const Text('Activo'),
                value: _activo,
                onChanged: (value) => setState(() => _activo = value),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _saveVehicle(context),
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_imageFile != null) {
      return Image.file(_imageFile!, fit: BoxFit.cover);
    } else if (widget.vehicle?.imagePath != null) {
      return Image.file(File(widget.vehicle!.imagePath!), fit: BoxFit.cover);
    }
    return const Center(child: Icon(Icons.add_a_photo, size: 50));
  }

  void _saveVehicle(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final vehicle = Vehicle(
        placa: _placaController.text,
        marca: _marcaController.text,
        anio: int.parse(_anioController.text),
        color: _colorController.text,
        costoPorDia: double.parse(_costoController.text),
        activo: _activo,
        imagePath: _imageFile?.path,
      );

      final controller = Provider.of<VehicleController>(context, listen: false);
      if (widget.vehicle == null) {
        controller.addVehicle(vehicle);
      } else {
        controller.updateVehicle(widget.vehicle!.placa, vehicle);
      }

      Navigator.pop(context);
    }
  }
}
