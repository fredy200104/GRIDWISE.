import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceModel {
  final String deviceId;
  final String name;
  final String type;
  final String? brand;
  final String? modelName;
  final double powerWatts;
  final String location;
  final bool isActive;
  final bool isMonitored;
  final double dailyUsageHours;
  final String iconKey;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeviceModel({
    required this.deviceId,
    required this.name,
    required this.type,
    this.brand,
    this.modelName,
    required this.powerWatts,
    required this.location,
    this.isActive = false,
    this.isMonitored = false,
    required this.dailyUsageHours,
    this.iconKey = 'devices',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Consumo mensual estimado en kWh
  double get monthlyKwh => (powerWatts * dailyUsageHours * 30) / 1000;

  /// Costo mensual estimado en COP (tarifa por defecto 362.5 $/kWh)
  double monthlyCost([double tariffRate = 362.5]) => monthlyKwh * tariffRate;

  factory DeviceModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return DeviceModel(
      deviceId: doc.id,
      name: d['name'] ?? '',
      type: d['type'] ?? 'other',
      brand: d['brand'],
      modelName: d['model_name'],
      powerWatts: (d['power_watts'] as num?)?.toDouble() ?? 0.0,
      location: d['location'] ?? '',
      isActive: d['is_active'] ?? false,
      isMonitored: d['is_monitored'] ?? false,
      dailyUsageHours: (d['daily_usage_hours'] as num?)?.toDouble() ?? 0.0,
      iconKey: d['icon_key'] ?? 'devices',
      createdAt: _parseDate(d['created_at']),
      updatedAt: _parseDate(d['updated_at']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'type': type,
        'brand': brand,
        'model_name': modelName,
        'power_watts': powerWatts,
        'location': location,
        'is_active': isActive,
        'is_monitored': isMonitored,
        'daily_usage_hours': dailyUsageHours,
        'monthly_kwh_estimate': monthlyKwh,
        'icon_key': iconKey,
        'created_at': Timestamp.fromDate(createdAt),
        'updated_at': Timestamp.fromDate(DateTime.now()),
      };

  DeviceModel copyWith({
    String? name,
    String? type,
    String? brand,
    String? modelName,
    double? powerWatts,
    String? location,
    bool? isActive,
    bool? isMonitored,
    double? dailyUsageHours,
    String? iconKey,
  }) {
    return DeviceModel(
      deviceId: deviceId,
      name: name ?? this.name,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      modelName: modelName ?? this.modelName,
      powerWatts: powerWatts ?? this.powerWatts,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      isMonitored: isMonitored ?? this.isMonitored,
      dailyUsageHours: dailyUsageHours ?? this.dailyUsageHours,
      iconKey: iconKey ?? this.iconKey,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// Tipos de dispositivo disponibles
class DeviceTypes {
  static const Map<String, Map<String, dynamic>> all = {
    'climate': {'label': 'Climatización', 'icon': 'ac_unit'},
    'lighting': {'label': 'Iluminación', 'icon': 'lightbulb'},
    'appliance': {'label': 'Electrodoméstico', 'icon': 'kitchen'},
    'entertainment': {'label': 'Entretenimiento', 'icon': 'tv'},
    'ev_charger': {'label': 'Cargador EV', 'icon': 'ev_station'},
    'solar_panel': {'label': 'Panel Solar', 'icon': 'solar_power'},
    'other': {'label': 'Otro', 'icon': 'devices'},
  };
}
