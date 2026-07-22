<div align="center">

# GridWise

### Plataforma Inteligente de Monitoreo y Gestion Energetica

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Node.js](https://img.shields.io/badge/Node.js-Express-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org)
[![Google Gemini](https://img.shields.io/badge/Google-Gemini_AI-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://ai.google.dev)
[![MQTT](https://img.shields.io/badge/MQTT-IoT-660066?style=for-the-badge&logo=eclipsemosquitto&logoColor=white)](https://mqtt.org)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

*Monitorea, analiza y optimiza el consumo energetico de tus dispositivos IoT con el poder de la Inteligencia Artificial.*

</div>

---

## Tabla de Contenidos

- [Descripcion General](#descripcion-general)
- [Caracteristicas Principales](#caracteristicas-principales)
- [Arquitectura del Sistema](#arquitectura-del-sistema)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Tecnologias Utilizadas](#tecnologias-utilizadas)
- [Requisitos Previos](#requisitos-previos)
- [Instalacion y Configuracion](#instalacion-y-configuracion)
  - [Backend (Node.js)](#1-backend-nodejs)
  - [Frontend (Flutter)](#2-frontend-flutter)
  - [Firebase](#3-configuracion-de-firebase)
- [Variables de Entorno](#variables-de-entorno)
- [Pantallas de la Aplicacion](#pantallas-de-la-aplicacion)
- [Modulo de IA - GridWise Assistant](#modulo-de-ia---gridwise-assistant)
- [Integracion IoT y MQTT](#integracion-iot-y-mqtt)
- [Seguridad y Reglas de Firestore](#seguridad-y-reglas-de-firestore)
- [Contribucion](#contribucion)

---

## Descripcion General

**GridWise** es una aplicacion movil y web multiplataforma desarrollada con **Flutter** que permite a los usuarios monitorear en tiempo real el consumo energetico de sus dispositivos IoT. La plataforma integra un **asistente de inteligencia artificial** (GridWise Assistant, impulsado por Google Gemini) que analiza el contexto de consumo del usuario para ofrecer recomendaciones personalizadas, alertas inteligentes y reportes detallados.

El sistema opera bajo una arquitectura de tres capas:

1. **App Flutter** — cliente multiplataforma: Android, iOS y Web.
2. **Backend Node.js + Express + Socket.IO** — orquestador y middleware de IA.
3. **Firebase** — autenticacion, base de datos en tiempo real con Firestore.

---

## Caracteristicas Principales

| Categoria | Caracteristica |
|-----------|----------------|
| Dashboard | Resumen en tiempo real del consumo total, dispositivos activos y alertas pendientes |
| Dispositivos IoT | Registro, edicion y monitoreo de dispositivos con consumo en watts |
| Consumo | Graficos historicos de consumo por dispositivo y por periodo |
| Reportes | Generacion y exportacion de reportes energeticos detallados |
| Alertas | Sistema de alertas automaticas basado en umbrales de consumo configurables |
| Recomendaciones | Sugerencias de ahorro energetico generadas por reglas y por IA |
| Chat con IA | Asistente conversacional con contexto de consumo en tiempo real (RAG) |
| MQTT / IoT | Conexion directa con dispositivos fisicos via protocolo MQTT |
| Perfil | Gestion de cuenta de usuario con foto de perfil y datos personales |
| Autenticacion | Login con Email/Password y Login con Google (OAuth 2.0) |

---

## Arquitectura del Sistema

```
+----------------------------------------------------------+
|                  CLIENTE (Flutter App)                    |
|  Android | iOS | Web (Chrome)                             |
|                                                           |
|  +---------------+  +--------------+  +---------------+  |
|  |  Screens &    |  |   Services   |  |    Models     |  |
|  |  Widgets      |  |   (Dart)     |  |   (Dart)      |  |
|  +-------+-------+  +------+-------+  +-------+-------+  |
+----------+-----------------+-----------------+-----------+
           |  HTTP / WS      |                 |
           v                 v                 |
+------------------------------------------+  |
|        BACKEND (Node.js)                 |  |
|                                          |  |
|  server.js      -> Express + Socket.IO   |  |
|  apiRoutes.js   -> REST endpoints        |  |
|  chatRoutes.js  -> Chat endpoints        |  |
|  chatService.js -> Gemini AI SDK         |  |
|  mqttService.js -> MQTT Broker           |  |
|  recommendationEngine.js                 |  |
|  firebaseAdmin.js -> Firebase SDK        |  |
+----------+---------------------------------+  |
           |                                   |
   +-------+--------+          +--------------v------+
   |  Google Gemini |          |       Firebase       |
   |  gemini-2.5-   |          |                      |
   |  flash         |          |  > Firestore DB      |
   +----------------+          |  > Authentication    |
                               +----------+-----------+
                                          |
                                          | MQTT
                               +----------+----------+
                               |  Dispositivos IoT   |
                               |  (sensores, etc.)   |
                               +---------------------+
```

---

## Estructura del Proyecto

```
gridwise/
|
+-- lib/                              # Codigo fuente Flutter
|   +-- main.dart                     # Punto de entrada y configuracion de rutas
|   +-- firebase_options.dart         # Opciones de Firebase (auto-generado)
|   |
|   +-- models/                       # Modelos de datos
|   |   +-- alert_model.dart          # Modelo de alertas
|   |   +-- chat_message.dart         # Modelo de mensajes del chat
|   |   +-- device.dart               # Modelo base de dispositivo
|   |   +-- device_model.dart         # Modelo completo de dispositivo IoT
|   |   +-- user_model.dart           # Modelo de usuario
|   |
|   +-- screens/                      # Pantallas de la aplicacion
|   |   +-- welcome_screen.dart       # Pantalla de bienvenida / splash
|   |   +-- login_screen.dart         # Inicio de sesion
|   |   +-- register_screen.dart      # Registro de usuario
|   |   +-- forgot_password_screen.dart  # Recuperacion de contrasena
|   |   +-- home_screen.dart          # Dashboard principal
|   |   +-- devices_screen.dart       # Lista de dispositivos
|   |   +-- add_device_screen.dart    # Agregar nuevo dispositivo
|   |   +-- edit_device_screen.dart   # Editar dispositivo existente
|   |   +-- iot_connect_screen.dart   # Conexion con dispositivos IoT fisicos
|   |   +-- consumption_screen.dart   # Graficos de consumo energetico
|   |   +-- reports_screen.dart       # Reportes y exportacion
|   |   +-- alerts_screen.dart        # Centro de alertas
|   |   +-- recommendations_screen.dart  # Recomendaciones de ahorro
|   |   +-- chat_screen.dart          # Chat con GridWise Assistant (IA)
|   |   +-- profile_screen.dart       # Perfil de usuario
|   |   +-- privacy_policy_screen.dart   # Politica de privacidad
|   |
|   +-- services/                     # Capa de servicios (logica de negocio)
|   |   +-- service_auth.dart         # Autenticacion con Firebase (Email + Google)
|   |   +-- user_service.dart         # CRUD de datos de usuario en Firestore
|   |   +-- device_service.dart       # Gestion de dispositivos en Firestore
|   |   +-- iot_service.dart          # Comunicacion con backend IoT/MQTT
|   |   +-- dashboard_service.dart    # Datos para el dashboard y resumenes
|   |   +-- alert_service.dart        # Gestion de alertas de consumo
|   |   +-- recommendation_service.dart  # Obtencion de recomendaciones
|   |   +-- chat_service.dart         # Integracion WebSocket con backend
|   |
|   +-- widgets/                      # Widgets reutilizables
|
+-- gridwise-backend/                 # Servidor Node.js
|   +-- server.js                     # Entrada principal, Express + Socket.IO
|   +-- apiRoutes.js                  # Rutas REST: dispositivos, consumo, alertas
|   +-- chatRoutes.js                 # Rutas REST: historial de chat
|   +-- chatService.js                # Logica de IA con Google Gemini + RAG
|   +-- mqttService.js                # Cliente MQTT para dispositivos IoT
|   +-- recommendationEngine.js       # Motor de reglas para recomendaciones
|   +-- firebaseAdmin.js              # Inicializacion de Firebase Admin SDK
|   +-- serviceAccountKey.json        # [PRIVADO] Credenciales de Firebase
|   +-- .env                          # [PRIVADO] Variables de entorno
|   +-- .env.example                  # Plantilla de variables de entorno
|
+-- assets/
|   +-- images/
|       +-- google_logo.png           # Logo de Google para el boton de login
|
+-- docs/                             # Documentacion adicional
+-- firestore.rules                   # Reglas de seguridad de Firestore
+-- firebase.json                     # Configuracion de Firebase CLI
+-- pubspec.yaml                      # Dependencias y configuracion de Flutter
+-- README.md                         # Este archivo
```

---

## Tecnologias Utilizadas

### Frontend (Flutter App)

| Paquete | Version | Uso |
|---------|---------|-----|
| `flutter` | SDK | Framework principal multiplataforma |
| `firebase_core` | ^4.5.0 | Inicializacion de Firebase |
| `firebase_auth` | ^6.2.0 | Autenticacion de usuarios |
| `cloud_firestore` | ^6.1.3 | Base de datos NoSQL en tiempo real |
| `google_sign_in` | ^6.2.1 | Autenticacion con Google OAuth |
| `fl_chart` | ^0.69.0 | Graficos de consumo energetico |
| `socket_io_client` | ^3.1.4 | Comunicacion en tiempo real con el backend |
| `http` | ^1.5.0 | Peticiones HTTP REST al backend |
| `google_fonts` | ^8.0.2 | Tipografias de Google |
| `shimmer` | ^3.0.0 | Efecto de carga animado |
| `image_picker` | ^1.1.2 | Seleccion de foto de perfil |
| `cached_network_image` | ^3.4.1 | Cache de imagenes de red |
| `share_plus` | ^10.0.2 | Compartir reportes |
| `screenshot` | ^3.0.0 | Captura de reportes como imagen |
| `intl` | ^0.19.0 | Formateo de fechas y numeros |
| `uuid` | ^4.4.2 | Generacion de IDs unicos |

### Backend (Node.js)

| Paquete | Version | Uso |
|---------|---------|-----|
| `express` | ^5.2.1 | Framework HTTP REST |
| `socket.io` | ^4.8.3 | WebSockets en tiempo real |
| `@google/genai` | ^2.2.0 | SDK de Google Gemini AI |
| `firebase-admin` | ^13.8.0 | Administracion de Firebase desde el servidor |
| `mqtt` | ^5.15.1 | Protocolo MQTT para IoT |
| `dotenv` | ^17.4.2 | Gestion de variables de entorno |
| `cors` | ^2.8.6 | Control de acceso entre origenes |

---

## Requisitos Previos

Antes de comenzar, asegurate de tener instalado:

- **Flutter SDK** `>= 3.11.1` — [Instalar Flutter](https://docs.flutter.dev/get-started/install)
- **Node.js** `>= 18.x` y **npm** — [Instalar Node.js](https://nodejs.org)
- **Firebase CLI** — `npm install -g firebase-tools`
- **Cuenta de Firebase** con un proyecto configurado
- **API Key de Google Gemini** — [Google AI Studio](https://aistudio.google.com)
- Un **broker MQTT** accesible (por ejemplo: Mosquitto, HiveMQ Cloud)

---

## Instalacion y Configuracion

### 1. Backend (Node.js)

```bash
# Clonar el repositorio
git clone https://github.com/fredy200104/GRIDWISE.git
cd gridwise/gridwise-backend

# Instalar dependencias
npm install

# Crear el archivo de variables de entorno
cp .env.example .env
# Editar .env con tus credenciales (ver seccion Variables de Entorno)

# Iniciar en modo desarrollo
npm run dev

# Iniciar en produccion
npm start
```

El servidor quedara disponible en `http://localhost:3000` (o el puerto configurado en `.env`).

### 2. Frontend (Flutter)

```bash
# Desde la raiz del proyecto
cd gridwise

# Obtener dependencias de Flutter
flutter pub get

# Verificar configuracion del entorno
flutter doctor

# Ejecutar en modo debug (selecciona un dispositivo conectado)
flutter run

# Ejecutar en Chrome (modo web)
flutter run -d chrome

# Compilar para Android
flutter build apk --release

# Compilar para iOS
flutter build ios --release
```

### 3. Configuracion de Firebase

1. Crea un proyecto en [Firebase Console](https://console.firebase.google.com).
2. Habilita **Authentication** con los proveedores: `Email/Password` y `Google`.
3. Crea una base de datos **Firestore** en modo produccion.
4. Descarga el archivo `google-services.json` (Android) y `GoogleService-Info.plist` (iOS).
5. Colocalos en `android/app/` e `ios/Runner/` respectivamente.
6. Ejecuta `flutterfire configure` para generar `firebase_options.dart`.
7. Para el backend, descarga la **clave de cuenta de servicio** desde Firebase Console > Configuracion > Cuentas de servicio > Generar nueva clave privada. Guardala como `gridwise-backend/serviceAccountKey.json`.

> **IMPORTANTE**: Nunca subas `serviceAccountKey.json` ni `.env` al repositorio. Ya estan incluidos en `.gitignore`.

---

## Variables de Entorno

Crea el archivo `gridwise-backend/.env` basandote en `.env.example`:

```env
# Puerto del servidor
PORT=3000

# Clave de API de Google Gemini
GEMINI_API_KEY=tu_api_key_de_gemini_aqui

# Configuracion del Broker MQTT
MQTT_BROKER_URL=mqtt://tu_broker_mqtt:1883
MQTT_USERNAME=tu_usuario_mqtt
MQTT_PASSWORD=tu_password_mqtt
MQTT_TOPIC=gridwise/devices/#

# Firebase Admin SDK
FIREBASE_SERVICE_ACCOUNT_PATH=./serviceAccountKey.json
```

---

## Pantallas de la Aplicacion

| Pantalla | Archivo | Descripcion |
|----------|---------|-------------|
| Bienvenida | `welcome_screen.dart` | Splash screen con animacion de entrada |
| Login | `login_screen.dart` | Inicio de sesion con Email o Google |
| Registro | `register_screen.dart` | Creacion de cuenta nueva |
| Recuperar Contrasena | `forgot_password_screen.dart` | Recuperacion de contrasena por email |
| Dashboard | `home_screen.dart` | Panel principal con metricas en tiempo real |
| Dispositivos | `devices_screen.dart` | Lista y gestion de dispositivos registrados |
| Agregar Dispositivo | `add_device_screen.dart` | Formulario para registrar nuevo dispositivo |
| Editar Dispositivo | `edit_device_screen.dart` | Modificar datos de un dispositivo existente |
| Conectar IoT | `iot_connect_screen.dart` | Vincular dispositivos fisicos via MQTT |
| Consumo | `consumption_screen.dart` | Graficos historicos de consumo por dispositivo |
| Reportes | `reports_screen.dart` | Generacion y exportacion de reportes energeticos |
| Alertas | `alerts_screen.dart` | Centro de alertas y notificaciones de consumo |
| Recomendaciones | `recommendations_screen.dart` | Sugerencias de ahorro energetico |
| Chat IA | `chat_screen.dart` | Chat con GridWise Assistant (Gemini AI) |
| Perfil | `profile_screen.dart` | Gestion del perfil y configuracion de cuenta |

---

## Modulo de IA - GridWise Assistant

GridWise Assistant es el asistente conversacional integrado, impulsado por **Google Gemini 2.5 Flash**. Su implementacion combina capacidades de lenguaje natural con datos de consumo en tiempo real.

### Identidad Institucional

El asistente ha sido dotado de una filosofia orientada al crecimiento humano, integrada en todos los niveles del sistema mediante el `SYSTEM_PROMPT`:

> *"Soy LIBRE, AUTONOMO Y RESPONSABLE a traves del dialogo y la construccion, como ideal regulativo; me dirijo, controlo y dicto mis propias leyes."*

Esta declaracion aparece al inicio de cada conversacion y orienta al modelo Gemini en sus principios de actuacion etica y responsabilidad social.

### RAG — Contexto de Consumo en Tiempo Real

Antes de cada llamada a la API de Gemini, el backend ejecuta `getUserContext(userId)`, que consulta Firestore y extrae:

- Todos los dispositivos IoT activos del usuario
- Consumo instantaneo en watts (`last_power_watts`)
- Estado de conexion de cada dispositivo
- Alertas y recomendaciones pendientes

Esta informacion se inyecta dinamicamente al `systemInstruction` de Gemini, permitiendole responder con datos reales del usuario en lugar de respuestas genericas.

### Flujo de Comunicacion

```
Flutter App --Socket.IO--> Backend Node.js --HTTP--> Google Gemini API
     ^                           |
     |                      Firestore
     |                    (Historial de chat)
     +-------------- Respuesta <-----------------+
```

La conexion Socket.IO detecta automaticamente el entorno de ejecucion:

- **Web (Chrome)**: usa `localhost`
- **Android Emulator**: usa `10.0.2.2`
- **Dispositivo fisico real**: usa la IP local de la maquina de desarrollo

---

## Integracion IoT y MQTT

GridWise se conecta con dispositivos fisicos a traves del protocolo **MQTT**:

- `mqttService.js` gestiona la suscripcion a los topics configurados.
- Los datos llegan en tiempo real y se almacenan en Firestore bajo la coleccion `device_data_unified`.
- El motor de reglas (`recommendationEngine.js`) evalua los datos recibidos y genera alertas automaticas cuando se superan los umbrales de consumo configurados.
- Los datos IoT se visualizan en `iot_connect_screen.dart` y se integran al contexto del asistente de IA.

---

## Seguridad y Reglas de Firestore

Las reglas de Firestore (`firestore.rules`) garantizan que cada usuario solo pueda acceder a sus propios datos:

```
/users/{userId}           Solo el propietario puede leer y editar
  /devices/{deviceId}     Solo el propietario
  /alerts/{alertId}       Solo el propietario
  /consumption_records/   Solo el propietario
  /iot_devices/           Solo el propietario

/recommendations/         Acceso por coincidencia de user_id
/device_data_unified/     Acceso por coincidencia de user_id
```

Adicionalmente, el backend valida cada conexion WebSocket mediante **JWT tokens de Firebase**, forzando la renovacion del token (`getIdToken(true)`) antes de cada conexion para prevenir errores por sesiones caducadas.

---

## Contribucion

1. Realiza un fork del repositorio.
2. Crea una rama para tu feature: `git checkout -b feature/nueva-funcionalidad`
3. Realiza tus cambios y haz commit: `git commit -m 'feat: agrega nueva funcionalidad'`
4. Sube los cambios: `git push origin feature/nueva-funcionalidad`
5. Abre un Pull Request describiendo los cambios realizados.

---

<div align="center">

GridWise — Energia Inteligente para un Futuro Sostenible

Desarrollado con Flutter, Node.js y Google Gemini AI

</div>
