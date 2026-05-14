# 🛠️ GridWise — Manual del Desarrollador

**Versión:** 1.0.0 | **Stack:** Flutter · Node.js · Firebase · MQTT

---

## Tabla de Contenidos

1. [Stack tecnológico completo](#1-stack-tecnológico-completo)
2. [Arquitectura del sistema](#2-arquitectura-del-sistema)
3. [Estructura de carpetas](#3-estructura-de-carpetas)
4. [Modelos de datos (Firestore)](#4-modelos-de-datos-firestore)
5. [Servicios Flutter](#5-servicios-flutter)
6. [Backend Node.js](#6-backend-nodejs)
7. [Flujo de autenticación](#7-flujo-de-autenticación)
8. [Protocolo IoT y MQTT](#8-protocolo-iot-y-mqtt)
9. [Errores corregidos y optimizaciones](#9-errores-corregidos-y-optimizaciones)
10. [Reglas de Firestore](#10-reglas-de-firestore)
11. [Cómo ejecutar el proyecto](#11-cómo-ejecutar-el-proyecto)

---

## 1. Stack tecnológico completo

### Lenguajes

| Lenguaje | Versión | Uso |
|----------|---------|-----|
| **Dart** | SDK ^3.11.1 | Frontend Flutter (toda la app móvil/web) |
| **JavaScript (Node.js)** | ES2020+ | Backend REST + MQTT service |

### Frontend — Flutter

| Paquete | Versión | Función |
|---------|---------|---------|
| `flutter` | SDK | Framework UI multiplataforma |
| `firebase_core` | ^4.5.0 | Inicialización Firebase |
| `cloud_firestore` | ^6.1.3 | Base de datos en tiempo real |
| `firebase_auth` | ^6.2.0 | Autenticación de usuarios |
| `google_sign_in` | ^6.2.1 | Login con Google |
| `fl_chart` | ^0.69.0 | Gráficos (línea y barras) |
| `shimmer` | ^3.0.0 | Skeletons de carga |
| `intl` | ^0.19.0 | Internacionalización y fechas |
| `uuid` | ^4.4.2 | Generación de IDs únicos |
| `image_picker` | ^1.1.2 | Selección de foto de perfil |
| `cached_network_image` | ^3.4.1 | Caché de imágenes de red |
| `share_plus` | ^10.0.2 | Compartir reportes |
| `screenshot` | ^3.0.0 | Captura de reportes |
| `google_fonts` | ^8.0.2 | Tipografía (Inter) |
| `http` | ^1.5.0 | Llamadas HTTP al backend |

### Backend — Node.js

| Paquete | Función |
|---------|---------|
| `express` | Framework REST API |
| `cors` | Control de acceso CORS |
| `mqtt` | Cliente MQTT para ESP32 |
| `firebase-admin` | Verificación de tokens + acceso a Firestore |
| `dotenv` | Variables de entorno |
| `crypto` | Hash SHA-256 para tokens de dispositivos |

### Infraestructura / Servicios externos

| Servicio | Uso |
|----------|-----|
| **Firebase Authentication** | Autenticación usuarios |
| **Cloud Firestore** | Base de datos NoSQL en tiempo real |
| **EMQX broker MQTT** | `mqtts://broker.emqx.io:8883` |
| **ESP32** | Hardware IoT de medición |

---

## 2. Arquitectura del sistema

```
┌──────────────────────────────────────────────────────┐
│                   FLUTTER APP                         │
│  Screens → Services → Firebase SDK (Auth/Firestore)  │
└───────────────────────┬──────────────────────────────┘
                        │ HTTP (Bearer Token)
                        ▼
┌──────────────────────────────────────────────────────┐
│              NODE.JS BACKEND (Express)                │
│  apiRoutes.js → firebaseAdmin.js → recommendationEngine│
│                  ↕ MQTT                               │
│              mqttService.js                           │
└───────────────────────┬──────────────────────────────┘
                        │ MQTT TLS
                        ▼
┌──────────────────────────────────────────────────────┐
│            EMQX BROKER (broker.emqx.io:8883)         │
│         Topic: home/{userId}/{deviceId}/data          │
└───────────────────────┬──────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────┐
│              ESP32 (Hardware IoT)                     │
│    Publica lecturas de potencia vía MQTT              │
└──────────────────────────────────────────────────────┘
                        │
             ┌──────────┘ Ambos escriben en
             ▼
┌──────────────────────────────────────────────────────┐
│                CLOUD FIRESTORE                        │
│  /users/{uid}/devices        → dispositivos manuales  │
│  /users/{uid}/alerts         → alertas del usuario    │
│  /users/{uid}/dashboard_summary → resumen del dash   │
│  /users/{uid}/iot_devices    → dispositivos IoT       │
│  /iot_devices/{deviceId}     → metadata global IoT   │
│  /recommendations/{docId}    → recomendaciones        │
│  /device_data_unified/{id}   → datos crudos IoT      │
└──────────────────────────────────────────────────────┘
```

---

## 3. Estructura de carpetas

```
gridwise/
├── lib/
│   ├── main.dart                    # Entrypoint: Firebase init, AuthGate, routing
│   ├── firebase_options.dart        # Config Firebase (auto-generado)
│   ├── models/
│   │   ├── device_model.dart        # DeviceModel + DeviceTypes
│   │   ├── device.dart              # Modelo simple de dispositivo
│   │   ├── user_model.dart          # UserModel con preferencias
│   │   └── alert_model.dart         # AlertModel + enums
│   ├── services/
│   │   ├── service_auth.dart        # AuthService (email, Google, reset)
│   │   ├── user_service.dart        # UserService (CRUD perfil + prefs)
│   │   ├── device_service.dart      # DeviceService (CRUD dispositivos)
│   │   ├── dashboard_service.dart   # DashboardService (stream reactivo)
│   │   ├── alert_service.dart       # AlertService (alertas en tiempo real)
│   │   ├── iot_service.dart         # IoTService (conexión ESP32)
│   │   └── recommendation_service.dart # RecommendationService
│   ├── screens/
│   │   ├── welcome_screen.dart      # Pantalla de bienvenida
│   │   ├── login_screen.dart        # Login email/Google
│   │   ├── register_screen.dart     # Registro de usuario
│   │   ├── forgot_password_screen.dart
│   │   ├── home_screen.dart         # Shell con NavigationBar
│   │   ├── consumption_screen.dart  # Dashboard (DashboardTab)
│   │   ├── devices_screen.dart      # Lista/CRUD dispositivos
│   │   ├── add_device_screen.dart   # Formulario agregar
│   │   ├── edit_device_screen.dart  # Formulario editar
│   │   ├── reports_screen.dart      # Reportes diario/semanal/mensual
│   │   ├── alerts_screen.dart       # Lista de alertas
│   │   ├── recommendations_screen.dart
│   │   ├── iot_connect_screen.dart  # Panel IoT / ESP32
│   │   ├── profile_screen.dart      # Perfil y configuración
│   │   └── privacy_policy_screen.dart
│   └── widgets/
│       ├── energy_card.dart         # Tarjeta de métrica
│       ├── device_card.dart         # Tarjeta de dispositivo
│       └── dashboard_skeleton.dart  # Shimmer de carga
├── gridwise-backend/
│   ├── server.js                    # Express entrypoint
│   ├── apiRoutes.js                 # Rutas REST con auth middleware
│   ├── mqttService.js               # Cliente MQTT + procesamiento IoT
│   ├── recommendationEngine.js      # Motor de reglas de ahorro
│   └── firebaseAdmin.js             # Admin SDK inicialización
├── firestore.rules                  # Reglas de seguridad
├── firebase.json                    # Config Firebase CLI
└── pubspec.yaml                     # Dependencias Flutter
```

---

## 4. Modelos de datos (Firestore)

### `/users/{uid}`

```json
{
  "name": "Juan Pérez",
  "email": "juan@email.com",
  "phone": "+573001234567",
  "photo_url": null,
  "tariff_rate_kwh": 362.5,
  "alert_threshold_kwh": 500.0,
  "notifications_enabled": true,
  "theme_mode": "dark",
  "createdAt": "<Timestamp>"
}
```

### `/users/{uid}/devices/{deviceId}`

```json
{
  "name": "Aire acondicionado sala",
  "type": "climate",
  "brand": "LG",
  "model_name": "Inverter 18000",
  "power_watts": 1500,
  "daily_usage_hours": 8,
  "location": "Sala",
  "is_active": true,
  "is_monitored": false,
  "monthly_kwh_estimate": 360.0,
  "icon_key": "ac_unit",
  "created_at": "<Timestamp>",
  "updated_at": "<Timestamp>"
}
```

### `/users/{uid}/dashboard_summary/current`

```json
{
  "daily_kwh": 12.0,
  "monthly_kwh": 360.0,
  "monthly_kwh_prev": 396.0,
  "monthly_saving_pct": 9.09,
  "active_devices": 3,
  "cost_estimate": 4350.0,
  "alert_threshold_kwh": 500.0,
  "alert_triggered": false,
  "last_updated": "<Timestamp>"
}
```

### `/users/{uid}/alerts/{alertId}`

```json
{
  "type": "thresholdExceeded",
  "title": "⚡ Consumo elevado detectado",
  "message": "Tu consumo mensual (520 kWh) superó el umbral de 500 kWh.",
  "severity": "high",
  "is_read": false,
  "triggered_at": "<Timestamp>",
  "threshold_kwh": 500.0,
  "actual_kwh": 520.0
}
```

### `/iot_devices/{deviceId}` (global)

```json
{
  "name": "Sensor Sala",
  "type": "sensor",
  "user_id": "uid123",
  "location": "sala",
  "status": "online",
  "token_hash": "<SHA-256 hash>",
  "createdAt": "<Timestamp>"
}
```

---

## 5. Servicios Flutter

### `DashboardService` (optimizado)

El stream `getDashboardSummaryStream()` ahora es **completamente reactivo**:
- Escucha la colección `devices` del usuario via `snapshots()`
- En cada cambio, ejecuta `_computeSummary()` que recalcula todo desde Firestore
- Persiste el resultado en `dashboard_summary/current` de forma no bloqueante
- Elimina el uso de `Random()` para el mes anterior (era no determinista)

```dart
Stream<Map<String, dynamic>> getDashboardSummaryStream() {
  final devicesRef = _db.collection('users').doc(_uid).collection('devices');
  return devicesRef.snapshots().asyncMap((_) async {
    return await _computeSummary();
  });
}
```

### `DeviceService`

CRUD completo sobre `users/{uid}/devices`:
- `getDevicesStream()` → Stream en tiempo real ordenado por nombre
- `getActiveDevicesStream()` → Solo dispositivos activos
- `addDevice()` → Crea con UUID v4
- `updateDevice()` → Actualiza por deviceId
- `deleteDevice()` → Elimina documento
- `toggleActive()` → Switch is_active + timestamp

### `AlertService`

- `getAlertsStream()` → Stream ordenado por fecha desc (limit 50)
- `getUnreadCountStream()` → Stream del badge de alertas
- `checkAndCreateAlert()` → Crea alerta si supera umbral (deduplicada por mes)
- `markAsRead()` / `markAllAsRead()` → Batch updates

### `AuthService`

- Email/password con validación regex
- Google Sign-In (popup en web, flow nativo en móvil)
- `sendPasswordResetEmail()` / `sendPasswordResetByPhone()`
- Crea documento en Firestore al registrar usuario nuevo

---

## 6. Backend Node.js

### Rutas API (`/api`)

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/consumption/manual` | Registra consumo manual y ejecuta motor |
| POST | `/device/:id/command` | Envía comando MQTT a un dispositivo |
| POST | `/devices/register` | Registra nuevo dispositivo IoT + genera token |
| POST | `/dashboard/projection` | Procesa proyección mensual en el motor |
| GET | `/health` | Health check del servidor |

### Middleware de autenticación

Verifica `Bearer <Firebase ID Token>` en cada request privado via `admin.auth().verifyIdToken()`.

### Motor de recomendaciones

Evalúa 3 reglas sobre los eventos IoT/manual:

| Regla | Condición | Prioridad |
|-------|-----------|-----------|
| `rule_high_instant_power` | Potencia > 1800W | Alta |
| `rule_standby_drain` | Standby >= 80W | Media |
| `rule_monthly_projection` | Proyección > umbral | Alta |

---

## 7. Flujo de autenticación

```
App arranca
    ↓
Firebase.initializeApp()   ← _AppBootstrap (FutureBuilder)
    ↓
FirebaseAuth.authStateChanges()  ← _AuthGate (StreamBuilder)
    ├── Usuario logueado  →  HomeScreen()
    └── No logueado       →  WelcomeScreen()
```

Al registrar un usuario nuevo, `AuthService.registerWithEmailPassword()`:
1. Crea el usuario en Firebase Auth
2. Llama `user.updateDisplayName(name)`
3. Crea el documento en `users/{uid}` en Firestore

---

## 8. Protocolo IoT y MQTT

### Registro de dispositivo

1. App llama `POST /api/devices/register` con Bearer token
2. Backend genera `device_token` aleatorio (32 bytes hex)
3. Almacena `token_hash = SHA256(device_token)` en Firestore
4. Devuelve `device_token`, `mqtt_data_topic` y `mqtt_command_topic` a la app
5. App muestra el token al usuario para cargar en el ESP32

### Flujo de datos IoT

```
ESP32 → MQTT publish → home/{uid}/{deviceId}/data
                          ↓
                    mqttService.js (recibe)
                          ↓
                  Verifica token hash SHA-256
                          ↓
                  Escribe en device_data_unified
                  Actualiza users/{uid}/iot_devices/{id}
                          ↓
                  recommendationEngine.processEvent()
```

### Payload MQTT esperado (ESP32 → broker)

```json
{
  "device_token": "abc123...",
  "instant_power_watts": 1200,
  "standby_watts": 15,
  "voltage": 120,
  "current_amps": 10
}
```

---

## 9. Errores corregidos y optimizaciones

### Bug 1 — Dashboard no reactivo a cambios en dispositivos

**Problema:** El stream `getDashboardSummaryStream()` escuchaba solo `dashboard_summary/current`. Si el usuario agregaba o eliminaba dispositivos, el dashboard no se actualizaba hasta hacer pull-to-refresh manual.

**Corrección:** El stream ahora escucha `users/{uid}/devices` y recalcula con `_computeSummary()` en cada cambio.

### Bug 2 — Random() en datos del mes anterior

**Problema:** `refreshDashboardSummary()` usaba `Random()` para simular el consumo del mes anterior, generando valores diferentes en cada llamada y causando que el % de ahorro fluctuara aleatoriamente.

**Corrección:** El valor `monthly_kwh_prev` se persiste en Firestore y solo se actualiza el día 1 de cada mes.

### Bug 3 — `device.copyWith()` sin argumentos en `addDevice`

**Problema:** `DeviceService.addDevice()` llamaba `device.copyWith().toFirestore()`, el `copyWith()` sin parámetros creaba una copia idéntica innecesariamente.

**Corrección:** Eliminado → `device.toFirestore()` directamente.

### Bug 4 — Promedio incorrecto en Reportes

**Problema:** `_buildTabContent()` siempre dividía por `_hourlyData.length` aunque el tab activo fuera semanal o mensual, dando promedios incorrectos.

**Corrección:** Se añadió el parámetro `pointCount` que cada vista pasa correctamente.

### Bug 5 — Variable `userRef` no usada (lint)

**Problema:** `getDashboardSummaryStream()` declaraba `final userRef = ...` sin usarla.

**Corrección:** Eliminada la variable, elimina el warning de Dart Linter.

### Optimización — `import 'dart:math'` eliminado

La eliminación del uso de `Random()` permite quitar el import de `dart:math` de `dashboard_service.dart`.

---

## 10. Reglas de Firestore

Las reglas en `firestore.rules` garantizan aislamiento entre usuarios:

- `users/{uid}/**` → solo el propietario (`request.auth.uid == uid`)
- `recommendations/{docId}` → lectura/escritura solo si `user_id == auth.uid`
- `iot_devices/{deviceId}` → solo el propietario
- `device_data_unified/{id}` → solo el propietario

---

## 11. Cómo ejecutar el proyecto

### Flutter (app)

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en modo debug (seleccionar dispositivo)
flutter run

# Ejecutar en Chrome (web)
flutter run -d chrome
```

### Backend Node.js

```bash
cd gridwise-backend

# Instalar dependencias
npm install

# Crear archivo .env con:
# MQTT_BROKER_URL=mqtts://broker.emqx.io:8883
# MQTT_USERNAME=...
# MQTT_PASSWORD=...
# ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
# PORT=3000

# Iniciar servidor
node server.js
# o con nodemon para desarrollo:
npx nodemon server.js
```

### Variables de entorno requeridas

| Variable | Descripción |
|----------|-------------|
| `MQTT_BROKER_URL` | URL del broker MQTT |
| `MQTT_USERNAME` | Usuario MQTT |
| `MQTT_PASSWORD` | Contraseña MQTT |
| `ALLOWED_ORIGINS` | Orígenes CORS permitidos |
| `PORT` | Puerto del servidor (default: 3000) |
| `GOOGLE_APPLICATION_CREDENTIALS` | Path al serviceAccountKey.json |

---

*GridWise v1.0.0 — Documentación técnica*
