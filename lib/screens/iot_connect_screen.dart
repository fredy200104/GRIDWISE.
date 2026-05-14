import 'dart:async';
import 'package:flutter/material.dart';
import '../services/iot_service.dart';

class IoTConnectScreen extends StatefulWidget {
  const IoTConnectScreen({super.key});

  @override
  State<IoTConnectScreen> createState() => _IoTConnectScreenState();
}

class _IoTConnectScreenState extends State<IoTConnectScreen> {
  final _iotService = IotService();
  Timer? _simTimer;
  bool _simRunning = false;
  bool _registeringReal = false;

  @override
  void dispose() {
    _simTimer?.cancel();
    super.dispose();
  }

  void _toggleSimulation() {
    if (_simRunning) {
      _simTimer?.cancel();
      setState(() => _simRunning = false);
      return;
    }

    _simTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _iotService.runSimulationStep();
    });
    setState(() => _simRunning = true);
  }

  Future<void> _createDeviceDialog() async {
    final nameCtrl = TextEditingController();
    String selectedType = 'enchufe';
    final formKey = GlobalKey<FormState>();

    final created = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vincular dispositivo simulado'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre del dispositivo'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(value: 'enchufe', child: Text('Enchufe inteligente')),
                  DropdownMenuItem(value: 'medidor', child: Text('Medidor de energia')),
                  DropdownMenuItem(value: 'aire', child: Text('Aire acondicionado')),
                  DropdownMenuItem(value: 'iluminacion', child: Text('Iluminacion')),
                ],
                onChanged: (v) => selectedType = v ?? 'enchufe',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Vincular'),
          ),
        ],
      ),
    );

    if (created == true) {
      await _iotService.addSimulatedDevice(name: nameCtrl.text.trim(), type: selectedType);
    }
  }

  Future<void> _registerRealDeviceDialog() async {
    final nameCtrl = TextEditingController();
    final locationCtrl = TextEditingController(text: 'Hogar');
    final backendCtrl = TextEditingController(text: 'http://localhost:3000');
    String selectedType = 'medidor';
    final formKey = GlobalKey<FormState>();

    final shouldRegister = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Registrar dispositivo real'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre del dispositivo'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(value: 'medidor', child: Text('Medidor de energia')),
                  DropdownMenuItem(value: 'enchufe', child: Text('Enchufe inteligente')),
                  DropdownMenuItem(value: 'aire', child: Text('Aire acondicionado')),
                  DropdownMenuItem(value: 'otro', child: Text('Otro')),
                ],
                onChanged: (v) => selectedType = v ?? 'medidor',
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: locationCtrl,
                decoration: const InputDecoration(labelText: 'Ubicacion'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: backendCtrl,
                decoration: const InputDecoration(labelText: 'URL backend'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa URL backend' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );

    if (shouldRegister != true) return;
    setState(() => _registeringReal = true);

    try {
      final result = await _iotService.registerRealDevice(
        name: nameCtrl.text.trim(),
        type: selectedType,
        location: locationCtrl.text.trim(),
        backendBaseUrl: backendCtrl.text.trim(),
      );

      if (!mounted) return;
      final deviceId = result['device_id']?.toString() ?? '';
      final deviceToken = result['device_token']?.toString() ?? '';
      final dataTopic = result['mqtt_data_topic']?.toString() ?? '';
      final commandTopic = result['mqtt_command_topic']?.toString() ?? '';

      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Credenciales IoT generadas'),
          content: SelectableText(
            'device_id: $deviceId\n'
            'device_token: $deviceToken\n'
            'topic_data: $dataTopic\n'
            'topic_commands: $commandTopic\n\n'
            'Configura estos valores en tu ESP32 o dispositivo IoT.',
          ),
          actions: [
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Entendido')),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error registrando dispositivo real: $e')),
      );
    } finally {
      if (mounted) setState(() => _registeringReal = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: _createDeviceDialog,
                icon: const Icon(Icons.add_link),
                label: const Text('Vincular simulado'),
              ),
              OutlinedButton.icon(
                onPressed: _registeringReal ? null : _registerRealDeviceDialog,
                icon: _registeringReal
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.router),
                label: const Text('Registrar real'),
              ),
              OutlinedButton.icon(
                onPressed: _toggleSimulation,
                icon: Icon(_simRunning ? Icons.pause_circle : Icons.play_circle),
                label: Text(_simRunning ? 'Pausar simulacion' : 'Iniciar simulacion'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.45),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'IoT disponible en dos modos: simulado y real. El modo real lee consumo desde telemetria MQTT (instant_power_watts).',
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _iotService.getDevicesStream(),
            builder: (context, snap) {
              final devices = snap.data ?? const <Map<String, dynamic>>[];
              if (devices.isEmpty) {
                return const Center(child: Text('Aun no hay dispositivos IoT vinculados.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final d = devices[index];
                  final isConnected = d['is_connected'] == true;
                  final watts = (d['last_power_watts'] as num?)?.toDouble() ?? 0;
                  final mode = d['mode']?.toString() ?? 'simulated';

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isConnected ? Colors.green.withOpacity(0.18) : Colors.grey.withOpacity(0.2),
                        child: Icon(
                          isConnected ? Icons.wifi : Icons.wifi_off,
                          color: isConnected ? Colors.green : Colors.grey,
                        ),
                      ),
                      title: Text(d['name']?.toString() ?? 'Dispositivo'),
                      subtitle: Text(
                        '${d['type'] ?? 'iot'} · ${mode == 'real' ? 'Real' : 'Simulado'} · ${isConnected ? 'Conectado' : 'Desconectado'} · ${watts.toStringAsFixed(1)} W',
                      ),
                      trailing: Switch(
                        value: isConnected,
                        onChanged: mode == 'real'
                            ? null
                            : (v) => _iotService.setConnection(d['id'] as String, v),
                      ),
                      onLongPress: () => _iotService.removeDevice(d['id'] as String),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

