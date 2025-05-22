class Vehicle {
  final String placa;
  final String marca;
  final int anio;
  final String color;
  final double costoPorDia;
  bool activo;
  final String? imagePath; // Para imágenes locales

  Vehicle({
    required this.placa,
    required this.marca,
    required this.anio,
    required this.color,
    required this.costoPorDia,
    this.activo = true,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'placa': placa,
      'marca': marca,
      'anio': anio,
      'color': color,
      'costoPorDia': costoPorDia,
      'activo': activo,
      'imagePath': imagePath,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      placa: map['placa'] ?? '',
      marca: map['marca'] ?? '',
      anio: map['anio'] ?? 0,
      color: map['color'] ?? '',
      costoPorDia: map['costoPorDia']?.toDouble() ?? 0.0,
      activo: map['activo'] ?? true,
      imagePath: map['imagePath'],
    );
  }
}