# Protocolos de Seguridad Implementados

## 1. Autenticacion y sesion
- Firebase Authentication para registro/login y gestion de sesion.
- Validacion de formato de correo en cliente (login/registro).
- Recuperacion de contrasena con respuesta uniforme para evitar enumeracion por telefono.

## 2. Autorizacion y control de acceso
- Reglas Firestore owner-based en `firestore.rules` con `request.auth.uid`.
- Aislamiento por usuario en subcolecciones (`users/{uid}/...`).
- Restricciones en colecciones compartidas (`recommendations`, `device_data_unified`, `iot_devices`).

## 3. Seguridad en backend API
- Middleware con verificacion real de JWT Firebase (`admin.auth().verifyIdToken`).
- Uso de `uid` del token en lugar de confiar en `user_id` enviado por cliente.
- Validaciones basicas de payload y campos requeridos.
- CORS restringible por lista blanca (`ALLOWED_ORIGINS`).

## 4. Seguridad en IoT/MQTT
- Broker configurado por defecto en `mqtts://` (TLS).
- Credenciales MQTT por variables de entorno (`MQTT_USERNAME`, `MQTT_PASSWORD`).
- Topics segmentados por hogar/usuario (`home/{uid}/{deviceId}/...`).
- Verificacion de token de dispositivo por hash SHA-256 en backend.
- Rechazo de mensajes con token invalido o ownership inconsistente.

## 5. Gestion de secretos
- Endurecimiento de `.gitignore` para `.env`, llaves PEM y service accounts.
- Recomendacion operativa: rotacion periodica de tokens de dispositivo.

## 6. Buenas practicas aplicadas
- Eliminacion de funcionalidades fuera del alcance residencial para reducir superficie y complejidad no requerida.
- Manejo de errores sin exponer detalles sensibles al usuario final.
- Prototipo funcional con simulacion IoT, preparado para integracion real.
