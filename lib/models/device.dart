class Device {
  String nombre;
  double watts;
  double horas;

  Device({
    required this.nombre,
    required this.watts,
    required this.horas,
  });

  double consumoMensual() {
    return (watts * horas * 30) / 1000;
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'watts': watts,
      'horas': horas,
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      nombre: map['nombre'] as String? ?? '',
      watts: (map['watts'] as num?)?.toDouble() ?? 0.0,
      horas: (map['horas'] as num?)?.toDouble() ?? 0.0,
    );
  }
}