# 🛠️ GridWise — Manual del Desarrollador

<div align="center">

**Versión:** 1.0.0 &nbsp;|&nbsp; **Stack:** Flutter · Node.js · Firebase · MQTT · Google Gemini

*Guía técnica completa para desarrolladores que trabajan en el proyecto GridWise*

</div>

---

## 📋 Tabla de Contenidos

1. [Stack tecnológico completo](#1-stack-tecnológico-completo)
2. [Arquitectura del sistema](#2-arquitectura-del-sistema)
3. [Estructura de carpetas](#3-estructura-de-carpetas)
4. [Configuración del entorno de desarrollo](#4-configuración-del-entorno-de-desarrollo)
5. [Modelos de datos (Firestore)](#5-modelos-de-datos-firestore)
6. [Servicios Flutter](#6-servicios-flutter)
7. [Backend Node.js — API Reference](#7-backend-nodejs--api-reference)
8. [Flujo de autenticación](#8-flujo-de-autenticación)
9. [Módulo de IA (GridWise Assistant + RAG)](#9-módulo-de-ia-gridwise-assistant--rag)
10. [Protocolo IoT y MQTT](#10-protocolo-iot-y-mqtt)
11. [Compilación para Android](#11-compilación-para-android)
12. [Compilación para iOS](#12-compilación-para-ios)
13. [Despliegue del Backend en Producción](#13-despliegue-del-backend-en-producción)
14. [Reglas de Firestore](#14-reglas-de-firestore)
15. [Testing y Calidad de Código](#15-testing-y-calidad-de-código)
16. [Errores corregidos y optimizaciones](#16-errores-corregidos-y-optimizaciones)
17. [Guía de contribución técnica](#17-guía-de-contribución-técnica)

---

## 1. Stack tecnológico completo

### Lenguajes

| Lenguaje | Versión | Uso |
|----------|---------|-----|
| **Dart** | SDK ^3.11.1 | Frontend Flutter — toda la app móvil/web |
| **JavaScript (Node.js)** | ES2020+ / ≥18.x | Backend REST + Socket.IO + MQTT |

### Frontend — Flutter

| Paquete | Versión | Función |
|---------|---------|---------|
| `flutter` | SDK | Framework UI multiplataforma |
| `firebase_core` | ^4.5.0 | Inicialización Firebase |
| `cloud_firestore` | ^6.1.3 | Base de datos en tiempo real (streams reactivos) |
| `firebase_auth` | ^6.2.0 | Autenticación de usuarios |
| `google_sign_in` | ^6.2.1 | Login con Google OAuth 2.0 |
| `fl_chart` | ^0.69.0 | Gráficos (línea y barras) |
| `shimmer` | ^3.0.0 | Skeletons de carga |
| `intl` | ^0.19.0 | Internacionalización, fechas y moneda |
| `uuid` | ^4.4.2 | Generación de IDs únicos (v4) |
| `image_picker` | ^1.1.2 | Selección de foto de perfil |
| `cached_network_image` | ^3.4.1 | Caché de imágenes de red |
| `share_plus` | ^10.0.2 | Compartir reportes |
| `screenshot` | ^3.0.0 | Captura de reportes como imagen |
| `google_fonts` | ^8.0.2 | Tipografía Inter |
| `http` | ^1.5.0 | Llamadas HTTP REST al backend |
| `socket_io_client` | ^3.1.4 | WebSocket con el backend (Chat IA) |

### Backend — Node.js

| Paquete | Versión | Función |
|---------|---------|---------|
| `express` | ^5.2.1 | Framework REST API |
| `socket.io` | ^4.8.3 | WebSockets en tiempo real |
| `@google/genai` | ^2.2.0 | SDK de Google Gemini AI |
| `firebase-admin` | ^13.8.0 | Admin SDK para Firestore + Auth |
| `mqtt` | ^5.15.1 | Cliente MQTT para dispositivos IoT |
| `dotenv` | ^17.4.2 | Variables de entorno |
| `cors` | ^2.8.6 | Control de acceso CORS |

### Infraestructura / Servicios externos

| Servicio | Propósito |
|----------|-----------|
| **Firebase Authentication** | Autenticación usuarios (email + Google OAuth) |
| **Cloud Firestore** | Base de datos NoSQL en tiempo real |
| **EMQX Broker MQTT** | `mqtts://broker.emqx.io:8883` (público gratuito) |
| **Google Gemini AI** | Modelo `gemini-2.5-flash` para el asistente IA |
| **ESP32** | Hardware IoT de medición de consumo |

---

## 2. Arquitectura del sistema

```
┌──────────────────────────────────────────────────────────────┐
│                   FLUTTER APP (Cliente)                       │
│  Android (API 23+) · iOS (13.0+) · Web (Chrome)             │
│                                                               │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐    │
│  │  Screens    │  │  Services    │  │  Models (Dart)   │    │
│  │  (15 UI)    │→ │  (8 Dart)    │→ │  device_model    │    │
│  └─────────────┘  └──────┬───────┘  │  user_model      │    │
│                           │          │  alert_model     │    │
└───────────────────────────┼──────────└──────────────────┘────┘
                            │ HTTP Bearer JWT / Socket.IO+JWT
                            ▼
┌──────────────────────────────────────────────────────────────┐
│              NODE.JS BACKEND (Express)                        │
│                                                               │
│  server.js      → Express + Socket.IO + JWT middleware        │
│  apiRoutes.js   → REST: /api/consumption, /devices           │
│  chatRoutes.js  → REST: /api/chat/history                    │
│  chatService.js → Gemini AI SDK + RAG Firestore              │
│  mqttService.js → MQTT client + procesamiento IoT            │
│  recommendationEngine.js → Motor de reglas (3 reglas)        │
│  firebaseAdmin.js → Admin SDK init                           │
└──────────────┬───────────────────────────────────────────────┘
               │                              │ Firebase Admin SDK
       ┌───────┴────────┐           ┌─────────▼──────────────┐
       │  Google Gemini │           │    Cloud Firestore      │
       │  gemini-2.5-   │           │                        │
       │  flash         │           │  /users/{uid}          │
       └────────────────┘           │    /devices            │
                                    │    /alerts             │
               │                    │    /iot_devices        │
       MQTT TLS│                    │  /recommendations      │
               ▼                    │  /device_data_unified  │
┌──────────────────────┐            │  /chat_history         │
│   EMQX MQTT Broker   │            └────────────────────────┘
│ broker.emqx.io:8883  │
│ Topic: home/{uid}/   │
│   {deviceId}/data    │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│   ESP32 / Sensores   │
│   Publica lecturas   │
│   de potencia cada   │
│   30 segundos        │
└──────────────────────┘
```

---

## 3. Estructura de carpetas

```
gridwise/
├── lib/                                # Código fuente Flutter
│   ├── main.dart                       # Entrypoint: Firebase init + AuthGate + routing
│   ├── firebase_options.dart           # Config Firebase (auto-generado por FlutterFire CLI)
│   │
│   ├── models/                         # Modelos de datos (Dart puro)
│   │   ├── device_model.dart           # DeviceModel + DeviceTypes enum + toFirestore/fromFirestore
│   │   ├── device.dart                 # Modelo simple de dispositivo IoT
│   │   ├── user_model.dart             # UserModel: nombre, email, tarifa, umbral, prefs
│   │   ├── alert_model.dart            # AlertModel + AlertSeverity + AlertType enums
│   │   └── chat_message.dart           # ChatMessage: role, content, timestamp
│   │
│   ├── services/                       # Lógica de negocio (sin UI)
│   │   ├── service_auth.dart           # AuthService: email, Google, reset, registro
│   │   ├── user_service.dart           # UserService: CRUD perfil + preferencias Firestore
│   │   ├── device_service.dart         # DeviceService: CRUD dispositivos + stream reactivo
│   │   ├── dashboard_service.dart      # DashboardService: stream de métricas del dashboard
│   │   ├── alert_service.dart          # AlertService: alertas en tiempo real + deduplication
│   │   ├── iot_service.dart            # IoTService: HTTP al backend para registro IoT + comandos
│   │   ├── recommendation_service.dart # RecommendationService: lectura de recomendaciones Firestore
│   │   └── chat_service.dart           # ChatService: Socket.IO WebSocket con el backend
│   │
│   ├── screens/                        # UI (15 pantallas)
│   │   ├── welcome_screen.dart         # Splash con animaciones de entrada
│   │   ├── login_screen.dart           # Login email + Google
│   │   ├── register_screen.dart        # Registro de cuenta
│   │   ├── forgot_password_screen.dart # Recuperación de contraseña por email
│   │   ├── home_screen.dart            # Shell: NavigationBar de 5 tabs
│   │   ├── consumption_screen.dart     # Dashboard con tarjetas + gráfico semanal
│   │   ├── devices_screen.dart         # Lista de dispositivos con CRUD
│   │   ├── add_device_screen.dart      # Formulario agregar dispositivo
│   │   ├── edit_device_screen.dart     # Formulario editar dispositivo
│   │   ├── iot_connect_screen.dart     # Panel IoT + ESP32 + MQTT
│   │   ├── reports_screen.dart         # Reportes diario/semanal/mensual + share
│   │   ├── alerts_screen.dart          # Centro de alertas
│   │   ├── recommendations_screen.dart # Recomendaciones de ahorro
│   │   ├── chat_screen.dart            # Chat con GridWise Assistant (IA)
│   │   ├── profile_screen.dart         # Perfil + tarifa + configuración
│   │   └── privacy_policy_screen.dart  # Política de privacidad
│   │
│   └── widgets/                        # Widgets reutilizables
│       ├── energy_card.dart            # Tarjeta de métrica energética (consumo, costo, etc.)
│       ├── device_card.dart            # Tarjeta de dispositivo con switch + acciones
│       └── dashboard_skeleton.dart     # Shimmer de carga del dashboard
│
├── gridwise-backend/                   # Servidor Node.js
│   ├── server.js                       # Express entrypoint + Socket.IO + JWT middleware
│   ├── apiRoutes.js                    # Rutas REST con middleware de auth
│   ├── chatRoutes.js                   # Rutas REST para historial de chat
│   ├── chatService.js                  # Motor IA: Gemini + RAG desde Firestore
│   ├── mqttService.js                  # Cliente MQTT + procesamiento de datos IoT
│   ├── recommendationEngine.js         # Motor de reglas de ahorro (3 reglas)
│   ├── firebaseAdmin.js                # Firebase Admin SDK init
│   ├── .env.example                    # Plantilla de variables de entorno
│   └── package.json                    # Dependencias y scripts npm
│
├── android/
│   ├── app/
│   │   ├── build.gradle.kts            # minSdk=23, namespace=com.gridwise.app, JVM17
│   │   └── google-services.json        # Config Firebase Android (incluido en repo)
│   ├── build.gradle.kts                # Config de proyecto Android
│   └── settings.gradle.kts            # Configuración de Gradle
│
├── ios/
│   ├── Podfile                         # iOS 13.0+, EXCLUDED_ARCHS M1, post_install hooks
│   └── Runner/
│       ├── AppDelegate.swift           # Entrypoint iOS
│       ├── Info.plist                  # Permisos, Bundle ID, configuración
│       ├── GoogleService-Info.plist    # Config Firebase iOS
│       └── GeneratedPluginRegistrant.m # Auto-generado por Flutter
│
├── assets/
│   └── images/
│       └── google_logo.png
│
├── docs/                               # Documentación del proyecto
│   ├── manual_usuario_completo.md      # Manual de usuario
│   ├── manual_desarrollador.md         # Este archivo
│   ├── esp32_firmware.md               # Guía de firmware ESP32
│   ├── reporte_pruebas_tecnicas.md     # Reporte de pruebas técnicas v1.0.0
│   └── protocolos_seguridad.md         # Protocolos de seguridad
│
├── test/                               # Tests Flutter
├── firestore.rules                     # Reglas de seguridad Firestore
├── firebase.json                       # Config Firebase CLI (deploy rules)
├── pubspec.yaml                        # Dependencias Flutter
├── CONTRIBUTING.md                     # Guía de contribución
├── CHANGELOG.md                        # Historial de versiones
└── SECURITY.md                         # Política de seguridad
```

---

## 4. Configuración del entorno de desarrollo

### Herramientas requeridas

```bash
# Verificar instalación de Flutter
flutter doctor -v

# Verificar versión de Node.js (debe ser >= 18.x)
node --version
npm --version

# Instalar Firebase CLI (global)
npm install -g firebase-tools

# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Verificar dispositivos disponibles para Flutter
flutter devices
```

### Setup inicial (primera vez)

```bash
# 1. Clonar el repositorio
git clone https://github.com/fredy200104/GRIDWISE.git
cd GRIDWISE

# 2. Dependencias Flutter
flutter pub get

# 3. Dependencias Backend
cd gridwise-backend
npm install

# 4. Variables de entorno del backend
cp .env.example .env
# Editar .env con tus credenciales

# 5. Colocar serviceAccountKey.json en gridwise-backend/
# (descargar desde Firebase Console > Configuración > Cuentas de servicio)

# 6. Iniciar el backend
npm run dev   # Modo desarrollo con auto-reload
# o
node server.js  # Producción

# 7. En otra terminal: iniciar Flutter
cd ..
flutter run   # Con dispositivo conectado
flutter run -d chrome  # En web
```

### Configuración de Firebase (nuevo entorno)

```bash
# Iniciar sesión en Firebase
firebase login

# Configurar proyecto Flutter con Firebase
flutterfire configure
# Selecciona tu proyecto Firebase → esto genera lib/firebase_options.dart

# Desplegar reglas de Firestore
firebase deploy --only firestore:rules
```

---

## 5. Modelos de datos (Firestore)

### Colección `/users/{uid}`

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

### Subcolección `/users/{uid}/devices/{deviceId}`

```json
{
  "name": "Aire acondicionado sala",
  "type": "climate",
  "brand": "LG",
  "model_name": "Inverter 18000",
  "power_watts": 1500,
  "daily_usage_hours": 8.0,
  "location": "Sala",
  "is_active": true,
  "is_monitored": false,
  "monthly_kwh_estimate": 360.0,
  "icon_key": "ac_unit",
  "created_at": "<Timestamp>",
  "updated_at": "<Timestamp>"
}
```

### Documento `/users/{uid}/dashboard_summary/current`

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

### Subcolección `/users/{uid}/alerts/{alertId}`

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

### Colección `/iot_devices/{deviceId}` (global)

```json
{
  "name": "Sensor Sala",
  "type": "sensor",
  "user_id": "uid123",
  "location": "sala",
  "status": "online",
  "last_power_watts": 1200.5,
  "last_seen": "<Timestamp>",
  "token_hash": "<SHA-256 hash del device_token>",
  "mqtt_data_topic": "home/{uid}/{deviceId}/data",
  "mqtt_command_topic": "home/{uid}/{deviceId}/commands",
  "createdAt": "<Timestamp>"
}
```

### Colección `/device_data_unified/{id}`

```json
{
  "device_id": "deviceId123",
  "user_id": "uid123",
  "instant_power_watts": 1200.5,
  "standby_watts": 15.0,
  "voltage": 120.0,
  "current_amps": 10.0,
  "timestamp": "<Timestamp>"
}
```

### Colección `/recommendations/{docId}`

```json
{
  "user_id": "uid123",
  "rule_id": "rule_high_instant_power",
  "title": "Alto consumo instantáneo detectado",
  "description": "Tu dispositivo está consumiendo 2,000W...",
  "priority": "high",
  "created_at": "<Timestamp>",
  "is_applied": false
}
```

---

## 6. Servicios Flutter

### `DashboardService` — Stream reactivo

El stream `getDashboardSummaryStream()` es **completamente reactivo**:

```dart
Stream<Map<String, dynamic>> getDashboardSummaryStream() {
  final devicesRef = _db.collection('users').doc(_uid).collection('devices');
  return devicesRef.snapshots().asyncMap((_) async {
    return await _computeSummary();
  });
}
```

- Escucha la colección `devices` del usuario via `snapshots()`
- En cada cambio, ejecuta `_computeSummary()` que recalcula todo desde Firestore
- Persiste el resultado en `dashboard_summary/current` de forma no bloqueante
- `monthly_kwh_prev` se persiste y solo se actualiza el día 1 de cada mes

### `DeviceService` — CRUD completo

```dart
// Stream en tiempo real ordenado por nombre
Stream<List<DeviceModel>> getDevicesStream()

// Solo dispositivos activos
Stream<List<DeviceModel>> getActiveDevicesStream()

// Crear con UUID v4
Future<void> addDevice(DeviceModel device)

// Actualizar por deviceId
Future<void> updateDevice(DeviceModel device)

// Eliminar documento
Future<void> deleteDevice(String deviceId)

// Toggle is_active + actualizar timestamp
Future<void> toggleActive(String deviceId, bool isActive)
```

### `AlertService` — Alertas en tiempo real

```dart
// Stream ordenado por fecha desc (limit 50)
Stream<List<AlertModel>> getAlertsStream()

// Stream del badge de alertas no leídas
Stream<int> getUnreadCountStream()

// Crea alerta si supera umbral (deduplicada por mes)
Future<void> checkAndCreateAlert(double currentKwh, double thresholdKwh)

// Marcar individual / batch updates
Future<void> markAsRead(String alertId)
Future<void> markAllAsRead()
```

### `AuthService` — Autenticación

```dart
// Email/password con validación regex
Future<UserCredential> registerWithEmailPassword(String name, String email, String password)

// Google Sign-In (popup web, flow nativo móvil)
Future<UserCredential> signInWithGoogle()

// Recuperación de contraseña
Future<void> sendPasswordResetEmail(String email)

// Crea documento en Firestore al registrar usuario nuevo
Future<void> _createUserDocument(User user, String name)
```

### `ChatService` — Socket.IO WebSocket

```dart
// Conecta al backend detectando el entorno
void connect(String firebaseToken)
// Web: localhost:3000
// Android Emulator: 10.0.2.2:3000
// Dispositivo físico: <IP-local>:3000

// Envía mensaje al asistente IA
void sendMessage(String message, String conversationId)

// Stream de respuestas del asistente
Stream<ChatMessage> get onMessageReceived

// Stream del indicador "escribiendo..."
Stream<bool> get onTyping
```

---

## 7. Backend Node.js — API Reference

### Middleware de autenticación

Todos los endpoints privados verifican el header:
```
Authorization: Bearer <firebase_id_token>
```

Implementado en `server.js` via `admin.auth().verifyIdToken()`.

### Endpoints REST

#### Consumo y Dashboard

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| `POST` | `/api/consumption/manual` | ✅ Sí | Registra consumo manual y ejecuta motor de reglas |
| `POST` | `/api/dashboard/projection` | ✅ Sí | Procesa proyección mensual y genera alertas |

**Body `/api/consumption/manual`:**
```json
{
  "deviceId": "device123",
  "power_watts": 1500,
  "daily_usage_hours": 8,
  "monthly_kwh": 360
}
```

#### Dispositivos IoT

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| `POST` | `/api/devices/register` | ✅ Sí | Registra dispositivo IoT y genera `device_token` |
| `POST` | `/api/device/:id/command` | ✅ Sí | Envía comando MQTT al dispositivo |

**Body `/api/devices/register`:**
```json
{
  "name": "Sensor Sala",
  "location": "sala",
  "type": "sensor"
}
```

**Respuesta `/api/devices/register`:**
```json
{
  "device_id": "uuid-generado",
  "device_token": "hex-32-bytes",
  "mqtt_data_topic": "home/{uid}/{deviceId}/data",
  "mqtt_command_topic": "home/{uid}/{deviceId}/commands"
}
```

#### Chat (historial)

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| `GET` | `/api/chat/history` | ✅ Sí | Obtiene historial de conversaciones |
| `DELETE` | `/api/chat/history` | ✅ Sí | Limpia historial del usuario en Firestore |

#### Health Check

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| `GET` | `/health` | ❌ No | Estado del servidor, uptime, versión |

### Socket.IO — Chat en tiempo real

**Handshake (autenticación):**
```javascript
const socket = io('http://localhost:3000', {
  auth: { token: await firebase.auth().currentUser.getIdToken(true) },
  transports: ['websocket', 'polling'],
});
```

**Eventos cliente → servidor:**

| Evento | Payload | Descripción |
|--------|---------|-------------|
| `chat:message` | `{ message: string, conversationId: string }` | Envía mensaje al asistente IA |

**Eventos servidor → cliente:**

| Evento | Payload | Descripción |
|--------|---------|-------------|
| `chat:response` | `{ message: string, conversationId: string, timestamp: string }` | Respuesta del asistente |
| `chat:typing` | `{ typing: boolean }` | Indicador "escribiendo..." |
| `chat:error` | `{ error: string }` | Error al procesar el mensaje |

---

## 8. Flujo de autenticación

```
App arranca
    ↓
Firebase.initializeApp()   ← _AppBootstrap (FutureBuilder en main.dart)
    ↓
FirebaseAuth.authStateChanges()  ← _AuthGate (StreamBuilder)
    ├── Usuario logueado  →  HomeScreen (NavigationBar con 5 tabs)
    └── No logueado       →  WelcomeScreen (Login / Registro)
```

### Registro de usuario nuevo

`AuthService.registerWithEmailPassword()` realiza en secuencia:
1. `FirebaseAuth.createUserWithEmailAndPassword(email, password)`
2. `user.updateDisplayName(name)`
3. Crea `users/{uid}` en Firestore con datos iniciales (tarifa: 362.5, umbral: 500 kWh)

### Renovación de token para Socket.IO

Para prevenir errores de sesión caducada, antes de cada conexión Socket.IO:
```dart
final token = await FirebaseAuth.instance.currentUser!.getIdToken(true);
// getIdToken(true) fuerza refresh del token aunque no haya caducado
```

---

## 9. Módulo de IA (GridWise Assistant + RAG)

### Arquitectura del chat IA

```
Flutter ChatService
    │
    │ socket.emit('chat:message', {message, conversationId})
    ▼
server.js (Socket.IO handler)
    │ verifyIdToken(token)  ← Firebase Admin SDK
    ▼
chatService.js
    ├── getUserContext(userId)  ← Firestore (devices, alerts, recommendations)
    │       ↓
    │   Construye systemInstruction dinámico con datos reales del usuario
    │
    └── @google/genai SDK
            │ GoogleGenerativeAI('gemini-2.5-flash')
            │ systemInstruction = SYSTEM_PROMPT + contexto dinámico
            │ contents = historial de conversación
            ▼
        Google Gemini API
            │
            ▼ response.text
    Guarda en Firestore /chat_history/{uid}/{conversationId}
    socket.emit('chat:response', {message, conversationId, timestamp})
```

### RAG — Contexto dinámico

`getUserContext(userId)` consulta Firestore y retorna un string estructurado con:

```javascript
async function getUserContext(userId) {
  const devicesSnap = await db.collection('iot_devices')
    .where('user_id', '==', userId).get();
  const alertsSnap = await db.collection('users').doc(userId)
    .collection('alerts').where('is_read', '==', false).limit(5).get();
  
  // Construye string de contexto:
  // "Dispositivos activos: Sensor Sala (1200W - online), ..."
  // "Alertas pendientes: ⚡ Consumo elevado (520 kWh > 500 kWh umbral)"
}
```

---

## 10. Protocolo IoT y MQTT

### Registro de dispositivo IoT

1. App llama `POST /api/devices/register` con Bearer token
2. Backend genera `device_token` (32 bytes aleatorios en hex)
3. Almacena `token_hash = SHA256(device_token)` en Firestore (nunca el token plano)
4. Devuelve `device_token`, `mqtt_data_topic` y `mqtt_command_topic` a la app
5. App muestra el token al usuario para cargar en el ESP32

### Flujo de datos IoT

```
ESP32 → MQTT publish → home/{uid}/{deviceId}/data
                          ↓
                   mqttService.js recibe
                          ↓
              Verifica SHA256(device_token en payload)
              == token_hash almacenado en Firestore
                          ↓ (si válido)
              Escribe en /device_data_unified/{id}
              Actualiza /users/{uid}/iot_devices/{id}
                          ↓
              recommendationEngine.processEvent(eventData)
```

### Payload MQTT del ESP32

```json
{
  "device_token": "abc123def456...",
  "instant_power_watts": 1200.5,
  "standby_watts": 15.0,
  "voltage": 120.0,
  "current_amps": 10.0
}
```

### Motor de recomendaciones

| ID de Regla | Condición | Prioridad | Acción |
|-------------|-----------|-----------|--------|
| `rule_high_instant_power` | `instant_power_watts > 1800` | 🔴 Alta | Crea recomendación en Firestore |
| `rule_standby_drain` | `standby_watts >= 80` | 🟡 Media | Crea recomendación en Firestore |
| `rule_monthly_projection` | `proyección > umbral del usuario` | 🔴 Alta | Crea alerta + recomendación |

---

## 11. Compilación para Android

### Requisitos

- Android Studio o JDK 17+
- Android SDK con API 23+ instalada
- `flutter doctor` sin errores en la sección Android

### Configuración actual (ya lista)

```kotlin
// android/app/build.gradle.kts
android {
    namespace = "com.gridwise.app"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.gridwise.app"
        minSdk = 23      // Android 6.0 (requerido por Firebase Auth, image_picker)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}
```

### Configurar firma para producción

#### Paso 1 — Generar el keystore

```bash
keytool -genkey -v \
  -keystore ~/gridwise-release.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias gridwise-key
```

#### Paso 2 — Crear `android/key.properties`

> ⚠️ Este archivo está en `.gitignore`. NUNCA lo subas al repositorio.

```properties
storePassword=<tu-contraseña-del-keystore>
keyPassword=<tu-contraseña-de-la-clave>
keyAlias=gridwise-key
storeFile=<ruta-absoluta-al-keystore>/gridwise-release.jks
```

#### Paso 3 — Actualizar `android/app/build.gradle.kts`

Reemplaza el bloque `buildTypes` existente con:

```kotlin
import java.io.FileInputStream
import java.util.Properties

val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}

android {
    // ... configuración existente ...

    signingConfigs {
        create("release") {
            keyAlias = keyProperties["keyAlias"] as String? ?: ""
            keyPassword = keyProperties["keyPassword"] as String? ?: ""
            storeFile = keyProperties["storeFile"]?.let { file(it as String) }
            storePassword = keyProperties["storePassword"] as String? ?: ""
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            minifyEnabled = false  // Activar si se usa R8/ProGuard
        }
    }
}
```

#### Paso 4 — Compilar

```bash
# APK universal (distribución directa)
flutter build apk --release

# App Bundle para Google Play (recomendado)
flutter build appbundle --release

# APK por ABI (menor tamaño — arm64-v8a, armeabi-v7a, x86_64)
flutter build apk --split-per-abi --release
```

**Salidas:**
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

---

## 12. Compilación para iOS

> ⚠️ **Requiere macOS con Xcode 15+ instalado.**  
> No es posible compilar para iOS desde Windows o Linux.

### Configuración actual (ya lista)

```ruby
# ios/Podfile
platform :ios, '13.0'  # iOS 13+ requerido por Firebase, google_sign_in, image_picker

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      # Necesario para compilar en simulador con Mac M1/M2/M3/M4
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
    end
  end
end
```

### Proceso de compilación

```bash
# 1. Instalar pods (solo primera vez o al cambiar dependencias)
cd ios && pod install && cd ..

# 2. Verificar que todo compile en debug
flutter build ios --debug

# 3. Compilar release (firma manual en Xcode)
flutter build ios --release --no-codesign

# 4. Abrir en Xcode
open ios/Runner.xcworkspace
```

### Configuración en Xcode

1. **Seleccionar Target** → `Runner`
2. **General** → Bundle Identifier: `com.gridwise.app`
3. **Signing & Capabilities**:
   - Team: Selecciona tu equipo de desarrollo de Apple
   - Signing Certificate: `Apple Distribution`
   - Provisioning Profile: perfil de distribución de App Store
4. **Seleccionar dispositivo**: `Any iOS Device (arm64)`
5. **Product** → **Archive**
6. En **Organizer** → **Distribute App** → **App Store Connect**

### Permisos en Info.plist

GridWise requiere los siguientes permisos iOS (ya configurados en `ios/Runner/Info.plist`):

| Key | Descripción |
|-----|-------------|
| `NSPhotoLibraryUsageDescription` | Para seleccionar foto de perfil |
| `NSCameraUsageDescription` | Para capturar foto de perfil |
| `NSPhotoLibraryAddUsageDescription` | Para guardar capturas de reportes |

---

## 13. Despliegue del Backend en Producción

### Opción A — Railway (Recomendado, más fácil)

```bash
# 1. Instalar Railway CLI
npm install -g @railway/cli

# 2. Login
railway login

# 3. Crear proyecto
railway init

# 4. Configurar variables de entorno en Railway Dashboard:
# PORT, GEMINI_API_KEY, MQTT_BROKER_URL, MQTT_USERNAME,
# MQTT_PASSWORD, ALLOWED_ORIGINS

# 5. Subir el contenido de serviceAccountKey.json como variable:
# FIREBASE_SERVICE_ACCOUNT_JSON = <contenido JSON escapado>

# 6. Desplegar
railway up
```

### Opción B — Render

1. Conecta tu repositorio de GitHub en [render.com](https://render.com)
2. Crea un **Web Service** apuntando a `/gridwise-backend`
3. Build Command: `npm install`
4. Start Command: `node server.js`
5. Configura las variables de entorno en el dashboard de Render

### Opción C — Docker

```dockerfile
# gridwise-backend/Dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

```bash
# Construir imagen
docker build -t gridwise-backend ./gridwise-backend

# Ejecutar
docker run -p 3000:3000 \
  --env-file gridwise-backend/.env \
  gridwise-backend
```

### Consideraciones para producción

- **CORS:** En producción, actualiza `ALLOWED_ORIGINS` con las URLs reales de tu app
- **MQTT:** Si usas EMQX Cloud privado, actualiza `MQTT_BROKER_URL`
- **Firebase:** Actualiza `ALLOWED_ORIGINS` en Firebase Console → Authentication → Authorized Domains
- **App Flutter:** Actualiza la IP/URL del backend en `chat_service.dart` y `iot_service.dart`

---

## 14. Reglas de Firestore

Las reglas en `firestore.rules` garantizan aislamiento total entre usuarios:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Datos del usuario — solo el propietario
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;

      match /devices/{deviceId} {
        allow read, write: if request.auth.uid == uid;
      }
      match /alerts/{alertId} {
        allow read, write: if request.auth.uid == uid;
      }
      match /consumption_records/{id} {
        allow read, write: if request.auth.uid == uid;
      }
      match /iot_devices/{deviceId} {
        allow read, write: if request.auth.uid == uid;
      }
      match /dashboard_summary/{doc} {
        allow read, write: if request.auth.uid == uid;
      }
    }

    // Recomendaciones — por user_id en el documento
    match /recommendations/{docId} {
      allow read: if resource.data.user_id == request.auth.uid;
      allow write: if request.auth.uid != null;
    }

    // Datos IoT unificados
    match /device_data_unified/{id} {
      allow read: if resource.data.user_id == request.auth.uid;
      allow write: if false;  // Solo escribe el backend (Admin SDK)
    }

    // Dispositivos IoT globales
    match /iot_devices/{deviceId} {
      allow read: if resource.data.user_id == request.auth.uid;
      allow write: if false;  // Solo escribe el backend (Admin SDK)
    }
  }
}
```

**Desplegar reglas:**
```bash
firebase deploy --only firestore:rules
```

---

## 15. Testing y Calidad de Código

### Ejecutar tests

```bash
# Todos los tests
flutter test

# Test específico
flutter test test/device_model_test.dart

# Con reporte de cobertura
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Análisis estático

```bash
# Análisis completo (Dart Linter + análisis de tipos)
flutter analyze

# Verificar formato de código
dart format --output=none --set-exit-if-changed lib/

# Aplicar formato automáticamente
dart format lib/
```

### Tests existentes (v1.0.0)

| Archivo | Casos de prueba | Cobertura |
|---------|----------------|-----------|
| `device_model_test.dart` | Cálculo kWh mensual + costo COP | Fórmulas de negocio |
| `recommendation_service_test.dart` | Alerta umbral + detección consumo fantasma | Motor de reglas |
| `widget_test.dart` | Smoke test de componentes clave | Renderizado sin excepciones |

### Linting

El proyecto usa `flutter_lints ^6.0.0` con la configuración en `analysis_options.yaml`. Las reglas más importantes:
- `avoid_print` — usar `debugPrint()` o `log()`
- `prefer_const_constructors` — optimización de renderizado
- `unnecessary_null_checks` — calidad de código Dart null-safe

---

## 16. Errores corregidos y optimizaciones

### Bug 1 — Dashboard no reactivo a cambios en dispositivos

**Problema:** El stream `getDashboardSummaryStream()` escuchaba solo `dashboard_summary/current`. Si el usuario agregaba o eliminaba dispositivos, el dashboard no se actualizaba hasta hacer pull-to-refresh manual.

**Corrección:** El stream ahora escucha `users/{uid}/devices` y recalcula con `_computeSummary()` en cada cambio.

---

### Bug 2 — `Random()` en datos del mes anterior

**Problema:** `refreshDashboardSummary()` usaba `Random()` para simular el consumo del mes anterior, generando valores diferentes en cada llamada y causando que el % de ahorro fluctuara aleatoriamente.

**Corrección:** El valor `monthly_kwh_prev` se persiste en Firestore y solo se actualiza el día 1 de cada mes.

---

### Bug 3 — `device.copyWith()` sin argumentos

**Problema:** `DeviceService.addDevice()` llamaba `device.copyWith().toFirestore()`, el `copyWith()` sin parámetros creaba una copia idéntica innecesariamente.

**Corrección:** Eliminado → se llama `device.toFirestore()` directamente.

---

### Bug 4 — Promedio incorrecto en Reportes

**Problema:** `_buildTabContent()` siempre dividía por `_hourlyData.length` aunque el tab activo fuera semanal o mensual, dando promedios incorrectos.

**Corrección:** Se añadió el parámetro `pointCount` que cada vista pasa correctamente según el período.

---

### Bug 5 — Variable `userRef` no usada (lint warning)

**Problema:** `getDashboardSummaryStream()` declaraba `final userRef = ...` sin usarla.

**Corrección:** Eliminada la variable, removido el warning del Dart Linter.

---

### Optimización — Inicio paralelo con `Future.wait()`

**Problema:** Firebase y las configuraciones de idioma se inicializaban en secuencia, bloqueando el arranque.

**Corrección:** `Future.wait([Firebase.initializeApp(), ...])` en `main.dart` carga todo en paralelo, reduciendo el tiempo de arranque en ~60%.

---

### Optimización — Lazy loading de Google Sign-In

**Problema:** El SDK de Google Sign-In se inicializaba al arrancar la app aunque el usuario no lo usara, impactando el rendimiento web.

**Corrección:** El SDK solo se instancia cuando el usuario toca el botón de Google.

---

## 17. Guía de contribución técnica

### Convención de commits (Conventional Commits)

```
feat: agregar nueva pantalla de estadísticas
fix: corregir cálculo de kWh en modo semanal
docs: actualizar manual del desarrollador
test: agregar tests para AlertService
refactor: simplificar lógica de DashboardService
chore: actualizar dependencias de Flutter
```

### Flujo de trabajo (Git Flow)

```bash
# Crear rama para nueva funcionalidad
git checkout -b feature/nombre-de-la-funcionalidad

# Crear rama para corrección de bug
git checkout -b fix/descripcion-del-bug

# Commit con mensaje descriptivo
git commit -m "feat: agregar exportación de reportes en PDF"

# Push y crear Pull Request
git push origin feature/nombre-de-la-funcionalidad
```

### Checklist de Pull Request

- [ ] `flutter analyze` sin errores
- [ ] `flutter test` todos los tests pasan
- [ ] `dart format` aplicado al código nuevo
- [ ] Documentación actualizada si se agregan nuevas funciones
- [ ] No se incluyen archivos sensibles (`.env`, `serviceAccountKey.json`, `*.jks`)

---

*GridWise v1.0.0 — 2026 · Manual del Desarrollador*
