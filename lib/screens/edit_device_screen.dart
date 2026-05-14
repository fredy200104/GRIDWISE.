import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../services/device_service.dart';

class EditDeviceScreen extends StatefulWidget {
  final DeviceModel device;
  const EditDeviceScreen({super.key, required this.device});

  @override
  State<EditDeviceScreen> createState() => _EditDeviceScreenState();
}

class _EditDeviceScreenState extends State<EditDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = DeviceService();

  late final _nameCtrl = TextEditingController(text: widget.device.name);
  late final _wattsCtrl = TextEditingController(text: widget.device.powerWatts.toString());
  late final _hoursCtrl = TextEditingController(text: widget.device.dailyUsageHours.toString());
  late final _locationCtrl = TextEditingController(text: widget.device.location);
  late final _brandCtrl = TextEditingController(text: widget.device.brand ?? '');
  late String _selectedType = widget.device.type;
  late bool _isActive = widget.device.isActive;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _wattsCtrl.dispose();
    _hoursCtrl.dispose();
    _locationCtrl.dispose();
    _brandCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final typeData = DeviceTypes.all[_selectedType]!;
      final updated = widget.device.copyWith(
        name: _nameCtrl.text.trim(),
        type: _selectedType,
        brand: _brandCtrl.text.trim().isEmpty ? null : _brandCtrl.text.trim(),
        powerWatts: double.parse(_wattsCtrl.text.trim()),
        location: _locationCtrl.text.trim().isEmpty ? 'Sin especificar' : _locationCtrl.text.trim(),
        isActive: _isActive,
        dailyUsageHours: double.parse(_hoursCtrl.text.trim()),
        iconKey: typeData['icon'] as String,
      );

      await _service.updateDevice(updated);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${updated.name} actualizado'),
            backgroundColor: const Color(0xFF00C853),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1626),
      appBar: AppBar(
        title: const Text('Editar Dispositivo',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F1626),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tipo
              _label('Tipo de dispositivo *'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: DeviceTypes.all.entries.map((entry) {
                  final isSelected = _selectedType == entry.key;
                  const iconMap = {
                    'ac_unit': Icons.ac_unit, 'lightbulb': Icons.lightbulb,
                    'kitchen': Icons.kitchen, 'tv': Icons.tv,
                    'ev_station': Icons.ev_station, 'solar_power': Icons.solar_power,
                    'devices': Icons.devices,
                  };
                  final icon = iconMap[entry.value['icon']] ?? Icons.devices;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = entry.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1565C0) : const Color(0xFF1E2336),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF1565C0) : Colors.white10,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, color: isSelected ? Colors.white : Colors.white38, size: 16),
                          const SizedBox(width: 6),
                          Text(entry.value['label'] as String,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white38,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            )),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              _label('Nombre *'),
              const SizedBox(height: 8),
              _field(_nameCtrl, 'Nombre del dispositivo', Icons.label_outline,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Obligatorio';
                    if (v.trim().length < 3) return 'Mínimo 3 caracteres';
                    return null;
                  }),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _label('Potencia (W) *'),
                      const SizedBox(height: 8),
                      _field(_wattsCtrl, 'Ej: 1200', Icons.bolt,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final n = double.tryParse(v ?? '');
                            if (n == null || n <= 0) return 'Número > 0';
                            return null;
                          }),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _label('Horas/día *'),
                      const SizedBox(height: 8),
                      _field(_hoursCtrl, 'Ej: 6', Icons.schedule,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final n = double.tryParse(v ?? '');
                            if (n == null || n < 0 || n > 24) return 'Entre 0-24';
                            return null;
                          }),
                    ]),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _label('Ubicación'),
              const SizedBox(height: 8),
              _field(_locationCtrl, 'Ej: Sala principal', Icons.location_on_outlined),
              const SizedBox(height: 16),
              _label('Marca (opcional)'),
              const SizedBox(height: 8),
              _field(_brandCtrl, 'Ej: Samsung', Icons.business_outlined),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2336),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.power_settings_new, color: Color(0xFF00C853)),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Activo ahora', style: TextStyle(color: Colors.white))),
                    Switch(
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                      activeColor: const Color(0xFF00C853),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(height: 22, width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Guardar cambios',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.7), fontSize: 12,
        fontWeight: FontWeight.w600, letterSpacing: 0.5,
      ));

  Widget _field(TextEditingController ctrl, String hint, IconData icon,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: const Color(0xFF1E2336),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent)),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}
