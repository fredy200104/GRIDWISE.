# 📱 GridWise — Manual de Usuario

**Versión:** 1.0.0 | **Idioma:** Español | **Plataformas:** Android · iOS · Web

---

## Tabla de Contenidos

1. [¿Qué es GridWise?](#1-qué-es-gridwise)
2. [Primeros pasos](#2-primeros-pasos)
3. [Dashboard principal](#3-dashboard-principal)
4. [Gestión de dispositivos](#4-gestión-de-dispositivos)
5. [Reportes de consumo](#5-reportes-de-consumo)
6. [Alertas](#6-alertas)
7. [Recomendaciones](#7-recomendaciones)
8. [Conexión IoT ESP32](#8-conexión-iot-esp32)
9. [Perfil y configuración](#9-perfil-y-configuración)
10. [Preguntas frecuentes](#10-preguntas-frecuentes)

---

## 1. ¿Qué es GridWise?

GridWise es una aplicación de **gestión inteligente del consumo eléctrico residencial**. Te permite:

- 📊 Monitorear tu consumo en tiempo real
- 🏠 Registrar todos los dispositivos de tu hogar
- ⚡ Conectar dispositivos físicos (ESP32) via MQTT
- 🔔 Recibir alertas cuando superas tu límite configurado
- 💡 Obtener recomendaciones personalizadas de ahorro
- 📈 Ver reportes diarios, semanales y mensuales
- 💰 Estimar costos en pesos colombianos (COP)

---

## 2. Primeros pasos

### 2.1 Crear cuenta

1. Abre la app → **Bienvenida** → **Registrarse**
2. Completa los campos:
   - Nombre completo
   - Correo electrónico
   - Teléfono (opcional)
   - Contraseña (mínimo 6 caracteres)
3. Toca **Crear cuenta**

> También puedes usar **Google** con el botón de inicio rápido.

### 2.2 Iniciar sesión

Pantalla de bienvenida → **Iniciar sesión** → ingresa correo y contraseña.

### 2.3 Recuperar contraseña

Login → **¿Olvidaste tu contraseña?** → ingresa correo o teléfono → revisa tu bandeja.

---

## 3. Dashboard principal

El dashboard muestra un **resumen en tiempo real** que se recalcula automáticamente al cambiar dispositivos.

### Tarjetas de métricas

| Tarjeta | Descripción |
|---------|-------------|
| Consumo hoy | kWh estimados para el día |
| Ahorro mensual | % vs. mes anterior |
| Consumo mensual | kWh totales del mes |
| Costo estimado | COP × tarifa configurada |

### Gráfico de 7 días

Tendencia semanal. Desliza hacia abajo para refrescar.

### Indicador de alerta

Si superas el umbral configurado, aparece un badge rojo **"Consumo elevado"** en el encabezado.

---

## 4. Gestión de dispositivos

### 4.1 Agregar dispositivo

Pestaña **Dispositivos** → botón **+ Agregar** → completa:

| Campo | Ejemplo |
|-------|---------|
| Nombre | Aire acondicionado sala |
| Tipo | Climatización |
| Potencia (W) | 1500 |
| Horas/día | 8 |
| Ubicación | Sala |
| Activo ahora | Sí/No |

Al guardar, el dashboard se actualiza al instante.

### 4.2 Editar / Eliminar

- **Editar:** toca ✏️ en la tarjeta.
- **Eliminar:** toca 🗑️ y confirma.
- **Activar/desactivar:** usa el switch en la tarjeta.

---

## 5. Reportes de consumo

Pestaña **Reportes** → tres pestañas:

| Vista | Gráfico | Período |
|-------|---------|---------|
| Diario | Línea hora a hora | Últimas 24 h |
| Semanal | Barras por día | Últimos 7 días |
| Mensual | Barras por día del mes | Mes actual |

Cada vista muestra: total kWh, promedio, máximo, mínimo, CO₂ evitado y costo estimado COP.

---

## 6. Alertas

Pestaña **Alertas** → notificaciones del sistema.

| Tipo | Cuándo |
|------|--------|
| ⚡ Consumo elevado | Consumo mensual > umbral |
| 🔌 Dispositivo inactivo | Activo sin variación 24 h |

Toca una alerta para marcarla como leída.

---

## 7. Recomendaciones

Sugerencias generadas automáticamente: 🔴 Alta · 🟡 Media · 🟢 Baja prioridad.

---

## 8. Conexión IoT ESP32

### Registrar dispositivo

1. Pestaña **IoT** → **Registrar dispositivo**
2. Anota el `device_token` y los topics MQTT
3. Carga el firmware en tu ESP32

### Topics MQTT

| Topic | Dirección |
|-------|-----------|
| `home/{userId}/{deviceId}/data` | ESP32 → servidor |
| `home/{userId}/{deviceId}/commands` | Servidor → ESP32 |

---

## 9. Perfil y configuración

| Campo | Predeterminado |
|-------|----------------|
| Tarifa (COP/kWh) | 362.5 |
| Umbral alerta (kWh/mes) | 500 |

Cambiar la tarifa recalcula costos en toda la app.

---

## 10. Preguntas frecuentes

**¿El dashboard muestra 0 kWh?** → Agrega dispositivos en la pestaña Dispositivos.

**¿Los datos se actualizan solos?** → Sí, el Stream reactivo de Firestore recalcula al instante.

**¿Puedo usarlo sin hardware IoT?** → Sí, funciona completamente con datos manuales.

**¿Mis datos están protegidos?** → Sí, con reglas de seguridad Firestore: solo tú accedes a tu información.

---
*GridWise v1.0.0 — 2026*
