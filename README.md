<div align="center">

# ⚡ GridWise

### Plataforma Inteligente de Monitoreo y Gestión Energética

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Node.js](https://img.shields.io/badge/Node.js-Express-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org)
[![Google Gemini](https://img.shields.io/badge/Google-Gemini_AI-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://ai.google.dev)
[![MQTT](https://img.shields.io/badge/MQTT-IoT-660066?style=for-the-badge&logo=eclipsemosquitto&logoColor=white)](https://mqtt.org)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

*Monitorea, analiza y optimiza el consumo energético de tus dispositivos IoT con el poder de la Inteligencia Artificial.*

</div>

---

## 📋 Tabla de Contenidos

- [Descripción General](#-descripción-general)
- [Características Principales](#-características-principales)
- [Arquitectura del Sistema](#-arquitectura-del-sistema)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Tecnologías Utilizadas](#-tecnologías-utilizadas)
- [Requisitos Previos](#-requisitos-previos)
- [Instalación y Configuración](#-instalación-y-configuración)
  - [Backend (Node.js)](#1-backend-nodejs)
  - [Frontend (Flutter)](#2-frontend-flutter)
  - [Firebase](#3-configuración-de-firebase)
- [Variables de Entorno](#-variables-de-entorno)
- [Pantallas de la Aplicación](#-pantallas-de-la-aplicación)
- [Módulo de IA - GridWise Assistant](#-módulo-de-ia---gridwise-assistant)
- [Integración IoT y MQTT](#-integración-iot-y-mqtt)
- [Seguridad y Reglas de Firestore](#-seguridad-y-reglas-de-firestore)
- [Contribución](#-contribución)

---

## 🌐 Descripción General

**GridWise** es una aplicación móvil y web multiplataforma desarrollada con **Flutter** que permite a los usuarios monitorear en tiempo real el consumo energético de sus dispositivos IoT. La plataforma integra un **asistente de inteligencia artificial** (GridWise Assistant, impulsado por Google Gemini) que analiza el contexto de consumo del usuario para ofrecer recomendaciones personalizadas, alertas inteligentes y reportes detallados.

El sistema opera bajo una arquitectura de tres capas:
1. **App Flutter** (cliente multiplataforma: Android, iOS, Web)
2. **Backend Node.js + Express + Socket.IO** (orquestador y middleware de IA)
3. **Firebase** (autenticación, base de datos en tiempo real con Firestore)

---

## ✨ Características Principales

| Categoría | Característica |
|-----------|----------------|
| 📊 **Dashboard** | Resumen en tiempo real del consumo total, dispositivos activos y alertas pendientes |
| 🔌 **Dispositivos IoT** | Registro, edición y monitoreo de dispositivos con consumo en watts |
| 📈 **Consumo** | Gráficos históricos de consumo por dispositivo y por período |
| 📑 **Reportes** | Generación y exportación de reportes energéticos detallados con screenshots |
| 🔔 **Alertas** | Sistema de alertas automáticas basado en umbrales de consumo configurables |
| 💡 **Recomendaciones** | Sugerencias de ahorro energético generadas por reglas y por IA |
| 🤖 **Chat con IA** | Asistente conversacional con contexto de consumo en tiempo real (RAG simplificado) |
| 📡 **MQTT / IoT** | Conexión directa con dispositivos físicos vía protocolo MQTT |
| 👤 **Perfil** | Gestión de cuenta de usuario con foto de perfil y datos personales |
| 🔐 **Autenticación** | Login con Email/Password y Login con Google (OAuth 2.0) |

---

## 🏗️ Arquitectura del Sistema

```
┌──────────────────────────────────────────────────────────┐
│                  CLIENTE (Flutter App)                    │
│  Android │ iOS │ Web (Chrome)                             │
│                                                          │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────┐  │
│  │  Screens &  │  │   Services   │  │    Models       │  │
│  │  Widgets    │  │  (Dart)      │  │  (Dart)         │  │
│  └──────┬──────┘  └──────┬───────┘  └────────┬────────┘  │
└─────────┼────────────────┼───────────────────┼───────────┘
          │  HTTP / WS     │                   │
          ▼                ▼                   │
┌──────────────────────────────────────┐       │
│        BACKEND (Node.js)             │       │
│                                      │       │
│  server.js ──► Express + Socket.IO   │       │
│  apiRoutes.js ──► REST endpoints     │       │
│  chatRoutes.js ──► Chat endpoints    │       │
│  chatService.js ──► Gemini AI SDK    │       │
│  mqttService.js ──► MQTT Broker      │       │
│  recommendationEngine.js             │       │
│  firebaseAdmin.js ──► Firebase SDK   │       │
└───────────┬──────────────────────────┘       │
            │                                  │
    ┌───────┴────────┐          ┌──────────────▼──────┐
    │  Google Gemini │          │       Firebase       │
    │  (gemini-2.5-  │          │                     │
    │   flash)       │          │  ► Firestore DB     │
    └────────────────┘          │  ► Auth             │
                                └─────────────────────┘
                                          ▲
                                          │ MQTT
                                ┌─────────┴────────┐
                                │  Dispositivos IoT │
                                │  (sensores, etc.) │
                                └──────────────────┘
```

---

## 📁 Estructura del Proyecto

```
gridwise/
│
├── 📂 lib/                          # Código fuente Flutter
│   ├── main.dart                    # Punto de entrada y configuración de rutas
│   ├── firebase_options.dart        # Opciones de Firebase (auto-generado)
│   │
│   ├── 📂 models/                   # Modelos de datos
│   │   ├── alert_model.dart         # Modelo de alertas
│   │   ├── chat_message.dart        # Modelo de mensajes del chat
│   │   ├── device.dart              # Modelo base de dispositivo
│   │   ├── device_model.dart        # Modelo completo de dispositivo IoT
│   │   └── user_model.dart          # Modelo de usuario
│   │
│   ├── 📂 screens/                  # Pantallas de la aplicación
│   │   ├── welcome_screen.dart      # Pantalla de bienvenida / splash
│   │   ├── login_screen.dart        # Inicio de sesión
│   │   ├── register_screen.dart     # Registro de usuario
│   │   ├── forgot_password_screen.dart # Recuperación de contraseña
│   │   ├── home_screen.dart         # Dashboard principal
│   │   ├── devices_screen.dart      # Lista de dispositivos
│   │   ├── add_device_screen.dart   # Agregar nuevo dispositivo
│   │   ├── edit_device_screen.dart  # Editar dispositivo
│   │   ├── iot_connect_screen.dart  # Conexión con dispositivos IoT físicos
│   │   ├── consumption_screen.dart  # Gráficos de consumo energético
│   │   ├── reports_screen.dart      # Reportes y exportación
│   │   ├── alerts_screen.dart       # Centro de alertas
│   │   ├── recommendations_screen.dart # Recomendaciones de ahorro
│   │   ├── chat_screen.dart         # Chat con GridWise Assistant (IA)
│   │   ├── profile_screen.dart      # Perfil de usuario
│   │   └── privacy_policy_screen.dart  # Política de privacidad
│   │
│   ├── 📂 services/                 # Capa de servicios (lógica de negocio)
│   │   ├── service_auth.dart        # Autenticación con Firebase (Email + Google)
│   │   ├── user_service.dart        # CRUD de datos de usuario en Firestore
│   │   ├── device_service.dart      # Gestión de dispositivos en Firestore
│   │   ├── iot_service.dart         # Comunicación con backend IoT/MQTT
│   │   ├── dashboard_service.dart   # Datos para el dashboard y resúmenes
│   │   ├── alert_service.dart       # Gestión de alertas de consumo
│   │   ├── recommendation_service.dart # Obtención de recomendaciones
│   │   └── chat_service.dart        # Integración WebSocket con backend (Socket.IO)
│   │
│   └── 📂 widgets/                  # Widgets reutilizables
│       └── ...
│
├── 📂 gridwise-backend/             # Servidor Node.js (Backend)
│   ├── server.js                    # Entrada principal, Express + Socket.IO
│   ├── apiRoutes.js                 # Rutas REST: dispositivos, consumo, alertas
│   ├── chatRoutes.js                # Rutas REST: historial de chat
│   ├── chatService.js               # Lógica de IA con Google Gemini + RAG
│   ├── mqttService.js               # Cliente MQTT para dispositivos IoT
│   ├── recommendationEngine.js      # Motor de reglas para recomendaciones
│   ├── firebaseAdmin.js             # Inicialización de Firebase Admin SDK
│   ├── serviceAccountKey.json       # 🔒 Credenciales de Firebase (NO subir a git)
│   ├── .env                         # 🔒 Variables de entorno (NO subir a git)
│   └── .env.example                 # Plantilla de variables de entorno
│
├── 📂 assets/
│   └── 📂 images/
│       └── google_logo.png          # Logo de Google para el botón de login
│
├── 📂 docs/                         # Documentación adicional
├── firestore.rules                  # Reglas de seguridad de Firestore
├── firebase.json                    # Configuración de Firebase CLI
├── pubspec.yaml                     # Dependencias y configuración de Flutter
└── README.md                        # Este archivo
```

---

## 🛠️ Tecnologías Utilizadas

### Frontend (Flutter App)
| Paquete | Versión | Uso |
|---------|---------|-----|
| `flutter` | SDK | Framework principal multiplataforma |
| `firebase_core` | ^4.5.0 | Inicialización de Firebase |
| `firebase_auth` | ^6.2.0 | Autenticación de usuarios |
| `cloud_firestore` | ^6.1.3 | Base de datos NoSQL en tiempo real |
| `google_sign_in` | ^6.2.1 | Autenticación con Google OAuth |
| `fl_chart` | ^0.69.0 | Gráficos de consumo energético |
| `socket_io_client` | ^3.1.4 | Comunicación en tiempo real con el backend |
| `http` | ^1.5.0 | Peticiones HTTP REST al backend |
| `google_fonts` | ^8.0.2 | Tipografías premium de Google |
| `shimmer` | ^3.0.0 | Efecto de carga animado |
| `image_picker` | ^1.1.2 | Selección de foto de perfil |
| `cached_network_image` | ^3.4.1 | Caché de imágenes de red |
| `share_plus` | ^10.0.2 | Compartir reportes |
| `screenshot` | ^3.0.0 | Captura de reportes como imagen |
| `intl` | ^0.19.0 | Formateo de fechas y números |
| `uuid` | ^4.4.2 | Generación de IDs únicos |

### Backend (Node.js)
| Paquete | Versión | Uso |
|---------|---------|-----|
| `express` | ^5.2.1 | Framework HTTP REST |
| `socket.io` | ^4.8.3 | WebSockets en tiempo real |
| `@google/genai` | ^2.2.0 | SDK de Google Gemini AI |
| `firebase-admin` | ^13.8.0 | Administración de Firebase desde el servidor |
| `mqtt` | ^5.15.1 | Protocolo MQTT para IoT |
| `dotenv` | ^17.4.2 | Gestión de variables de entorno |
| `cors` | ^2.8.6 | Control de acceso entre orígenes |

---

## 📦 Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:

- **Flutter SDK** `>= 3.11.1` — [Instalar Flutter](https://docs.flutter.dev/get-started/install)
- **Node.js** `>= 18.x` y **npm** — [Instalar Node.js](https://nodejs.org)
- **Firebase CLI** — `npm install -g firebase-tools`
- **Cuenta de Firebase** con un proyecto configurado
- **API Key de Google Gemini** — [Google AI Studio](https://aistudio.google.com)
- Un **broker MQTT** accesible (p. ej. Mosquitto, HiveMQ Cloud)

---

## 🚀 Instalación y Configuración

### 1. Backend (Node.js)

```bash
# Clonar el repositorio
git clone https://github.com/fredy200104/GRIDWISE.git
cd gridwise/gridwise-backend

# Instalar dependencias
npm install

# Crear el archivo de variables de entorno
cp .env.example .env
# Editar .env con tus credenciales (ver sección de Variables de Entorno)

# Iniciar en modo desarrollo
npm run dev

# Iniciar en producción
npm start
```

El servidor quedará disponible en `http://localhost:3000` (o el puerto configurado).

### 2. Frontend (Flutter)

```bash
# Desde la raíz del proyecto
cd gridwise

# Obtener dependencias de Flutter
flutter pub get

# Verificar configuración del entorno
flutter doctor

# Ejecutar en modo debug (selecciona un dispositivo)
flutter run

# Ejecutar en Chrome (modo web)
flutter run -d chrome

# Compilar para Android
flutter build apk --release

# Compilar para iOS
flutter build ios --release
```

### 3. Configuración de Firebase

1. Crea un proyecto en [Firebase Console](https://console.firebase.google.com).
2. Habilita **Authentication** con los proveedores: `Email/Password` y `Google`.
3. Crea una base de datos **Firestore** en modo producción.
4. Descarga el archivo `google-services.json` (Android) y `GoogleService-Info.plist` (iOS).
5. Colócalos en `android/app/` e `ios/Runner/` respectivamente.
6. Ejecuta `flutterfire configure` para generar `firebase_options.dart`.
7. Para el backend, descarga la **clave de cuenta de servicio** desde Firebase Console → Configuración → Cuentas de servicio → Generar nueva clave privada. Guárdala como `gridwise-backend/serviceAccountKey.json`.

> ⚠️ **IMPORTANTE**: Nunca subas `serviceAccountKey.json` ni `.env` al repositorio. Ya están incluidos en `.gitignore`.

---

## 🔑 Variables de Entorno

Crea el archivo `gridwise-backend/.env` basándote en `.env.example`:

```env
# Puerto del servidor
PORT=3000

# Clave de API de Google Gemini
GEMINI_API_KEY=tu_api_key_de_gemini_aqui

# Configuración del Broker MQTT
MQTT_BROKER_URL=mqtt://tu_broker_mqtt:1883
MQTT_USERNAME=tu_usuario_mqtt
MQTT_PASSWORD=tu_password_mqtt
MQTT_TOPIC=gridwise/devices/#

# Firebase Admin SDK
FIREBASE_SERVICE_ACCOUNT_PATH=./serviceAccountKey.json
```

---

## 📱 Pantallas de la Aplicación

| Pantalla | Archivo | Descripción |
|----------|---------|-------------|
| 🏠 **Bienvenida** | `welcome_screen.dart` | Splash screen con animación de entrada |
| 🔐 **Login** | `login_screen.dart` | Inicio de sesión con Email o Google |
| 📝 **Registro** | `register_screen.dart` | Creación de cuenta nueva |
| 🔑 **Contraseña** | `forgot_password_screen.dart` | Recuperación de contraseña por email |
| 📊 **Dashboard** | `home_screen.dart` | Panel principal con métricas en tiempo real |
| 🔌 **Dispositivos** | `devices_screen.dart` | Lista y gestión de dispositivos registrados |
| ➕ **Agregar** | `add_device_screen.dart` | Formulario para registrar nuevo dispositivo |
| ✏️ **Editar** | `edit_device_screen.dart` | Modificar datos de un dispositivo existente |
| 📡 **IoT Conectar** | `iot_connect_screen.dart` | Vincular dispositivos físicos vía MQTT |
| 📈 **Consumo** | `consumption_screen.dart` | Gráficos históricos de consumo por dispositivo |
| 📑 **Reportes** | `reports_screen.dart` | Generación y exportación de reportes energéticos |
| 🔔 **Alertas** | `alerts_screen.dart` | Centro de alertas y notificaciones de consumo |
| 💡 **Recomendaciones** | `recommendations_screen.dart` | Sugerencias de ahorro energético |
| 🤖 **Chat IA** | `chat_screen.dart` | Chat con GridWise Assistant (Gemini AI) |
| 👤 **Perfil** | `profile_screen.dart` | Gestión del perfil y configuración de cuenta |

---

## 🤖 Módulo de IA - GridWise Assistant

GridWise Assistant es el asistente conversacional integrado, impulsado por **Google Gemini 2.5 Flash**. Su implementación va más allá de un simple chatbot:

### Identidad Institucional

El asistente ha sido dotado de una filosofía orientada al crecimiento humano, integrada en todos los niveles del sistema:

> *"Soy LIBRE, AUTÓNOMO Y RESPONSABLE a través del diálogo y la construcción, como ideal regulativo; me dirijo, controlo y dicto mis propias leyes."*

Esta declaración aparece al inicio de cada conversación y orienta el `SYSTEM_PROMPT` que inyecta al modelo Gemini sus directrices de actuación ética y responsabilidad social.

### RAG — Contexto de Consumo en Tiempo Real

Antes de cada llamada a la API de Gemini, el backend ejecuta `getUserContext(userId)` que consulta Firestore y extrae:
- Todos los dispositivos IoT activos del usuario
- Consumo instantáneo en watts (`last_power_watts`)
- Estado de conexión de cada dispositivo
- Alertas y recomendaciones pendientes

Esta información se inyecta dinámicamente al `systemInstruction` de Gemini, permitiéndole responder con contexto real:

> *"Tu ventilador de sala está consumiendo 450W ahora mismo, que es un 20% más que el promedio. ¿Quieres que te explique cómo reducirlo?"*

### Flujo de Comunicación (WebSocket)

```
Flutter App ──Socket.IO──► Backend Node.js ──HTTP──► Google Gemini API
     ▲                           │                         │
     │                      Firestore                      │
     │                    (Historial de chat)               │
     └──────────────── Respuesta en streaming ◄────────────┘
```

La conexión Socket.IO detecta automáticamente el entorno de ejecución:
- **Web (Chrome)**: usa `localhost`
- **Android Emulator**: usa `10.0.2.2`
- **Dispositivo físico real**: usa la IP local de la máquina

---

## 📡 Integración IoT y MQTT

GridWise se conecta con dispositivos físicos a través del protocolo **MQTT**:

- **`mqttService.js`** gestiona la suscripción a los topics configurados
- Los datos llegan en tiempo real y se almacenan en Firestore bajo `device_data_unified`
- El **motor de reglas** (`recommendationEngine.js`) evalúa los datos recibidos y genera alertas automáticas cuando se superan umbrales de consumo
- Los datos IoT se muestran en la pantalla `iot_connect_screen.dart` y se integran al contexto del asistente de IA

---

## 🔒 Seguridad y Reglas de Firestore

Las reglas de Firestore (`firestore.rules`) garantizan que cada usuario solo pueda acceder a sus propios datos:

```
/users/{userId}          → Solo el propietario puede leer/editar
  /devices/{deviceId}    → Solo el propietario
  /alerts/{alertId}      → Solo el propietario
  /consumption_records/  → Solo el propietario
  /iot_devices/          → Solo el propietario

/recommendations/        → Acceso por coincidencia de user_id
/device_data_unified/    → Acceso por coincidencia de user_id
```

Adicionalmente, el backend valida cada conexión WebSocket mediante **JWT tokens de Firebase**, forzando la renovación del token (`getIdToken(true)`) antes de cada conexión para prevenir errores por sesiones caducadas.

---

## 🤝 Contribución

1. **Fork** el repositorio
2. Crea una rama para tu feature: `git checkout -b feature/nueva-funcionalidad`
3. Realiza tus cambios y haz commit: `git commit -m 'feat: agrega nueva funcionalidad'`
4. Sube los cambios: `git push origin feature/nueva-funcionalidad`
5. Abre un **Pull Request**

---

<div align="center">

**GridWise** — *Energía Inteligente para un Futuro Sostenible* ⚡

Desarrollado con ❤️ usando Flutter, Node.js y Google Gemini AI

</div>
