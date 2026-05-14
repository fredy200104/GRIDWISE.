# GridWise Residencial - Resumen Tecnico

## Arquitectura
- Frontend: Flutter (Dart), arquitectura modular por pantallas, modelos y servicios.
- Backend: Node.js + Express + Firebase Admin.
- Base de datos: Firestore (NoSQL JSON) con reglas por usuario.
- Autenticacion: Firebase Authentication.

## Modulos implementados
- Dashboard: resumen de consumo, costo, tendencia y estado de alertas.
- Dispositivos: CRUD por usuario y consumo estimado por dispositivo.
- Reportes: vistas diaria/semanal/mensual con graficas.
- Alertas: umbrales de consumo y gestion de lectura.
- Recomendaciones: generacion de sugerencias segun consumo y carga.
- IoT: vinculacion simulada + actualizacion semi-real.
- Perfil: datos personales y preferencias energeticas.

## Modelo de datos (Firestore)
- `users/{uid}`: perfil y preferencias.
- `users/{uid}/devices/{deviceId}`: inventario de dispositivos electricos.
- `users/{uid}/dashboard_summary/current`: resumen agregado.
- `users/{uid}/alerts/{alertId}`: alertas del usuario.
- `users/{uid}/consumption_records/{recordId}`: historico de consumo.
- `users/{uid}/iot_devices/{deviceId}`: dispositivos IoT simulados.
- `recommendations/{id}`: recomendaciones generadas por motor backend.
- `iot_devices/{id}`: registro backend de dispositivos fisicos/simulados autenticados.
- `device_data_unified/{id}`: eventos unificados para analitica/recomendaciones.

## Flujo funcional resumido
1. Usuario inicia sesion (Firebase Auth).
2. Frontend consume Firestore por subcolecciones del usuario.
3. Dashboard recalcula resumen y evalua alertas.
4. Backend recibe eventos manuales o IoT autenticados.
5. Motor backend genera recomendaciones y las guarda en Firestore.
