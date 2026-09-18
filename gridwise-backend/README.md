# GridWise Backend — Node.js

Servidor backend de la plataforma GridWise. Provee la API REST, comunicación en tiempo real via Socket.IO, integración con Google Gemini AI y conexión IoT via MQTT.

## Stack Tecnológico

| Tecnología | Versión | Propósito |
|---|---|---|
| Node.js | >= 18.x | Runtime principal |
| Express | ^5.2.1 | Framework HTTP REST |
| Socket.IO | ^4.8.3 | WebSockets — Chat en tiempo real |
| @google/genai | ^2.2.0 | Google Gemini AI SDK |
| firebase-admin | ^13.8.0 | Administración de Firebase desde el servidor |
| mqtt | ^5.15.1 | Protocolo IoT para dispositivos físicos |
| dotenv | ^17.4.2 | Variables de entorno |
| cors | ^2.8.6 | Control de acceso entre orígenes |

## Estructura de Archivos

```
gridwise-backend/
├── server.js               # Punto de entrada: Express + Socket.IO + autenticación JWT
├── apiRoutes.js            # Rutas REST: /api/consumption, /api/devices, /api/dashboard
├── chatRoutes.js           # Rutas REST: /api/chat/history
├── chatService.js          # Motor de IA: Gemini + RAG desde Firestore
├── mqttService.js          # Cliente MQTT: suscripción y publicación a dispositivos IoT
├── recommendationEngine.js # Motor de reglas: genera recomendaciones automáticas
├── firebaseAdmin.js        # Inicialización de Firebase Admin SDK
├── .env.example            # Plantilla de variables de entorno (NO contiene secretos)
└── package.json            # Dependencias y scripts
```

## Instalación

```bash
# Instalar dependencias
npm install

# Copiar plantilla de variables de entorno
cp .env.example .env
# Editar .env con tus credenciales reales

# Iniciar en modo desarrollo (con nodemon)
npm run dev

# Iniciar en producción
npm start
```

## Variables de Entorno

Crea el archivo `.env` basándote en `.env.example`:

```env
PORT=3000
NODE_ENV=development
GEMINI_API_KEY=tu_api_key_de_gemini
MQTT_BROKER_URL=mqtt://tu_broker:1883
MQTT_USERNAME=usuario
MQTT_PASSWORD=contraseña
MQTT_TOPIC=gridwise/devices/#
FIREBASE_SERVICE_ACCOUNT_PATH=./serviceAccountKey.json
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

> **IMPORTANTE**: Nunca subas `.env` ni `serviceAccountKey.json` al repositorio. Están en `.gitignore`.

## Configuración de Firebase Admin

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Configuración del Proyecto → Cuentas de servicio
3. Haz clic en **Generar nueva clave privada**
4. Guarda el archivo como `gridwise-backend/serviceAccountKey.json`

## Endpoints REST

### Autenticación
Todos los endpoints `POST` y `PUT` requieren el header:
```
Authorization: Bearer <firebase_id_token>
```

### Consumo
| Método | Ruta | Descripción |
|--------|------|-------------|
| `POST` | `/api/consumption/manual` | Registra datos de consumo manualmente |
| `POST` | `/api/dashboard/projection` | Procesa proyección mensual y genera alertas |

### Dispositivos IoT
| Método | Ruta | Descripción |
|--------|------|-------------|
| `POST` | `/api/devices/register` | Registra un nuevo dispositivo físico |
| `POST` | `/api/device/:id/command` | Envía comando MQTT a un dispositivo |

### Chat (historial)
| Método | Ruta | Descripción |
|--------|------|-------------|
| `GET` | `/api/chat/history` | Obtiene historial de conversaciones |
| `DELETE` | `/api/chat/history` | Limpia historial del usuario |

### Health Check
| Método | Ruta | Descripción |
|--------|------|-------------|
| `GET` | `/health` | Estado del servidor |

## Socket.IO — Chat en Tiempo Real

La conexión Socket.IO requiere autenticación via Firebase ID Token en el handshake:

```javascript
const socket = io('http://localhost:3000', {
  auth: { token: await firebase.auth().currentUser.getIdToken(true) },
  transports: ['websocket', 'polling'],
});
```

### Eventos del cliente → servidor
| Evento | Payload | Descripción |
|--------|---------|-------------|
| `chat:message` | `{ message: string, conversationId: string }` | Envía mensaje al asistente IA |

### Eventos servidor → cliente
| Evento | Payload | Descripción |
|--------|---------|-------------|
| `chat:response` | `{ message: string, conversationId: string, timestamp: string }` | Respuesta del asistente IA |
| `chat:typing` | `{ typing: boolean }` | Indicador de "escribiendo..." |
| `chat:error` | `{ error: string }` | Error al procesar el mensaje |

## Motor de Recomendaciones

El `recommendationEngine.js` evalúa eventos IoT y de dashboard con estas reglas:

| ID de Regla | Condición | Prioridad |
|-------------|-----------|-----------|
| `rule_high_instant_power` | Potencia instantánea > 1800W | Alta |
| `rule_standby_drain` | Consumo en espera > 80W | Media |
| `rule_monthly_projection` | Proyección mensual > umbral configurado | Alta |

## MQTT — Integración IoT

Los dispositivos físicos (ESP32, etc.) deben publicar datos en el topic:
```
home/{userId}/{deviceId}/data
```

Ejemplo de payload JSON:
```json
{
  "instant_power_watts": 150.5,
  "voltage": 120.0,
  "current": 1.25,
  "timestamp": "2026-09-17T08:00:00Z"
}
```

Para recibir comandos, los dispositivos se suscriben a:
```
home/{userId}/{deviceId}/commands
```
