# 📋 Changelog — GridWise

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es/1.0.0/),
y este proyecto sigue [Semantic Versioning](https://semver.org/lang/es/).

---

## [1.0.0] — 2026-09-17

### Versión inicial de producción

Esta es la primera versión estable de **GridWise**, una plataforma multiplataforma de monitoreo y gestión energética inteligente con IA, IoT y Firebase.

### ✨ Agregado

#### App Flutter (Android · iOS · Web)

- **Autenticación completa:**
  - Registro con email y contraseña (validación regex)
  - Login con Google OAuth 2.0
  - Recuperación de contraseña por email
  - Persistencia de sesión automática con Firebase Auth

- **Dashboard en tiempo real:**
  - Tarjetas de métricas: consumo diario (kWh), consumo mensual, costo estimado (COP), porcentaje de ahorro
  - Gráfico de barras de tendencia semanal (últimos 7 días)
  - Stream reactivo de Firestore — se actualiza instantáneamente al modificar dispositivos
  - Indicador visual de alerta cuando se supera el umbral configurado

- **Gestión de dispositivos:**
  - CRUD completo de dispositivos del hogar (nombre, tipo, potencia, horas de uso, ubicación)
  - Catálogo de 7 tipos de dispositivos con íconos descriptivos
  - Switch de activación/desactivación por dispositivo
  - Cálculo automático de `monthly_kwh_estimate` al guardar

- **Reportes de consumo:**
  - Vista diaria (gráfico de línea — últimas 24 horas)
  - Vista semanal (gráfico de barras — últimos 7 días)
  - Vista mensual (gráfico de barras — mes actual)
  - Panel de estadísticas: total, promedio, máximo, mínimo, CO₂ evitado, costo COP
  - Exportación de reportes como imagen via `share_plus`

- **Centro de alertas:**
  - Alertas automáticas cuando el consumo mensual supera el umbral configurado
  - Deduplicación de alertas (máximo 1 alerta del mismo tipo por mes)
  - Marcar como leída individualmente o todas a la vez
  - Badge con conteo de alertas no leídas en la navegación

- **Recomendaciones de ahorro:**
  - Recomendaciones por motor de reglas: consumo alto, consumo fantasma, proyección elevada
  - Prioridades: Alta 🔴, Media 🟡, Baja 🟢

- **GridWise Assistant — Chat con IA:**
  - Asistente conversacional con Google Gemini 2.5 Flash
  - RAG: contexto dinámico de dispositivos, alertas y consumo real del usuario
  - Historial persistente en Firestore
  - Indicador "escribiendo..." en tiempo real via Socket.IO
  - Borrado de historial por conversación

- **Conexión IoT (ESP32 / MQTT):**
  - Registro de dispositivos físicos con generación de `device_token` (32 bytes hex)
  - Almacenamiento seguro: solo el hash SHA-256 del token en Firestore
  - Visualización de estado online/offline por dispositivo
  - Control remoto de dispositivos vía MQTT (publicación de comandos)
  - Integración con broker EMQX Cloud (TLS 8883)

- **Perfil y configuración:**
  - Edición de nombre y teléfono
  - Foto de perfil con `image_picker` y `cached_network_image`
  - Configuración de tarifa eléctrica (COP/kWh)
  - Configuración de umbral de alertas (kWh/mes)
  - Toggle de notificaciones in-app

#### Backend Node.js

- **REST API** con Express 5.x:
  - `POST /api/consumption/manual` — registro de consumo manual
  - `POST /api/devices/register` — registro de dispositivo IoT
  - `POST /api/device/:id/command` — comandos MQTT
  - `POST /api/dashboard/projection` — proyección mensual
  - `GET /api/chat/history` — historial de chat
  - `DELETE /api/chat/history` — limpieza de historial
  - `GET /health` — health check

- **Socket.IO** para chat en tiempo real con autenticación JWT
- **Motor de IA** con Google Gemini SDK (`@google/genai`)
- **Motor de reglas** (`recommendationEngine.js`) con 3 reglas automáticas
- **Cliente MQTT** con verificación de tokens SHA-256

#### Plataformas

- **Android:** `minSdk = 23` (Android 6.0+), `applicationId = "com.gridwise.app"`
- **iOS:** `platform :ios, '13.0'`, configuración para Mac M1/M2 (`EXCLUDED_ARCHS`)
- **Web:** Soporte para Chrome con detección automática de entorno backend

### 🔒 Seguridad

- Reglas de Firestore: aislamiento total entre usuarios (`request.auth.uid == uid`)
- Tokens de dispositivos IoT almacenados como hash SHA-256
- Validación JWT en cada request HTTP y Socket.IO al backend
- Renovación forzada de token Firebase antes de conexiones Socket.IO
- Variables de entorno excluidas del repositorio vía `.gitignore`

### 🐛 Bugs corregidos durante el desarrollo

- **Dashboard no reactivo:** el stream ahora escucha `devices/` en vez de `dashboard_summary/current`
- **`Random()` en mes anterior:** reemplazado por valor persistente en Firestore, actualizado solo el día 1
- **`device.copyWith()` sin parámetros:** eliminado, se usa `device.toFirestore()` directamente
- **Promedio incorrecto en reportes:** corregido con parámetro `pointCount` por tipo de vista
- **Variable `userRef` no usada:** eliminada (limpieza de lint warning)

### ⚡ Optimizaciones de rendimiento

- Inicialización paralela con `Future.wait()` en `main.dart` (~60% reducción de tiempo de arranque)
- Lazy loading del SDK de Google Sign-In (solo se inicializa cuando el usuario lo usa)
- `GoogleFonts.config.allowRuntimeFetching = false` en web (tipografía local instantánea)
- `addPostFrameCallback` para diferir la verificación de perfil de Firestore hasta después del primer frame
- Paralelización del cálculo de dashboard con `Future.wait()` en `DashboardService`

---

## [Unreleased]

### En desarrollo

- Soporte para múltiples hogares por cuenta
- Integración con paneles solares (medición de generación vs. consumo)
- Modo oscuro / claro configurable por el usuario
- Exportación de reportes en formato PDF
- Notificaciones push (Firebase Cloud Messaging)
- Internacionalización (i18n) — inglés / español

---

*Formato basado en [Keep a Changelog](https://keepachangelog.com/es/1.0.0/)*
