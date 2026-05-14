import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Politicas de privacidad'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Politicas de privacidad de GridWise',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '1. Datos que recopilamos\n'
              'GridWise recopila datos de registro (nombre, correo, telefono), '
              'datos de dispositivos electricos del hogar y metricas de consumo energetico.',
            ),
            const SizedBox(height: 12),
            const Text(
              '2. Finalidad del tratamiento\n'
              'Usamos los datos para autenticar usuarios, mostrar graficas de consumo, '
              'generar alertas y recomendaciones de ahorro, y habilitar integracion IoT.',
            ),
            const SizedBox(height: 12),
            const Text(
              '3. Seguridad\n'
              'Aplicamos autenticacion con Firebase, reglas de acceso por usuario en Firestore, '
              'validacion de tokens en backend y controles de acceso para proteger informacion.',
            ),
            const SizedBox(height: 12),
            const Text(
              '4. Comparticion de datos\n'
              'No compartimos datos personales con terceros fuera de los servicios tecnicos '
              'necesarios para operar la aplicacion.',
            ),
            const SizedBox(height: 12),
            const Text(
              '5. Conservacion\n'
              'Los datos se conservan mientras la cuenta este activa o mientras sea necesario '
              'para fines academicos y funcionales del prototipo.',
            ),
            const SizedBox(height: 12),
            const Text(
              '6. Derechos del usuario\n'
              'El usuario puede solicitar actualizacion o eliminacion de datos personales '
              'en cualquier momento contactando al equipo del proyecto.',
            ),
            const SizedBox(height: 12),
            const Text(
              '7. Contacto\n'
              'Correo: soporte@gridwise.app\n'
              'Telefono: +57 300 123 4567',
            ),
          ],
        ),
      ),
    );
  }
}
