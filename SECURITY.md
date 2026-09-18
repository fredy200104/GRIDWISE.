# 🔐 Política de Seguridad — GridWise

## Versiones soportadas

La siguiente tabla indica qué versiones de GridWise reciben actualizaciones de seguridad activamente:

| Versión | Soporte de seguridad |
|---------|---------------------|
| 1.0.x | ✅ Soportada |
| < 1.0 | ❌ Sin soporte |

---

## Reportar una vulnerabilidad

**⚠️ Por favor NO reportes vulnerabilidades de seguridad a través de los Issues públicos de GitHub.**

Si descubres una vulnerabilidad de seguridad en GridWise, te pedimos que la reportes de forma responsable para proteger a los usuarios del proyecto.

### Proceso de reporte responsable

1. **Abre un Issue privado** en GitHub usando la categoría **"Security Advisory"** (si está habilitada).
2. **Alternativamente**, contacta directamente al equipo del proyecto via el repositorio con una descripción general del problema (sin incluir detalles técnicos sensibles en público).

### Información a incluir en tu reporte

Para que podamos investigar y corregir la vulnerabilidad rápidamente, incluye:

- **Descripción:** Descripción clara de la vulnerabilidad y su impacto potencial
- **Componente afectado:** App Flutter / Backend Node.js / Reglas Firestore / otro
- **Pasos para reproducir:** Instrucciones detalladas para reproducir el problema
- **Impacto:** ¿Qué datos o funcionalidades podrían verse comprometidos?
- **Prueba de concepto:** Si es posible, incluye código o capturas que demuestren el problema (sin explotar activamente la vulnerabilidad)
- **Sugerencia de corrección:** Si tienes una idea de cómo corregirla, inclúyela

### Qué puedes esperar

- **Confirmación de recibo:** En un plazo de **48 horas** laborables
- **Evaluación inicial:** En un plazo de **7 días**
- **Actualización del estado:** Cada 7 días hasta que el problema esté resuelto
- **Crédito:** Si lo deseas, serás mencionado en el CHANGELOG cuando se publique la corrección

---

## Buenas prácticas de seguridad para colaboradores

### Variables de entorno y credenciales

> [!CAUTION]
> **NUNCA** subas los siguientes archivos al repositorio:

| Archivo | Descripción |
|---------|-------------|
| `gridwise-backend/.env` | Variables de entorno con API keys y contraseñas |
| `gridwise-backend/serviceAccountKey.json` | Clave privada de Firebase Admin |
| `android/key.properties` | Contraseñas del keystore de firma Android |
| `*.jks`, `*.keystore` | Archivos de firma Android |
| `ios/Runner/GoogleService-Info.plist` | (Si contiene datos reales — usar placeholder) |

Todos estos archivos están protegidos en `.gitignore`. Si accidentalmente subes un secreto, **rota inmediatamente las credenciales** y contacta al equipo.

### Seguridad en el código

- **Tokens de dispositivos IoT:** Solo almacenar el hash SHA-256, nunca el token en texto plano
- **Firebase ID Tokens:** Siempre validar con `admin.auth().verifyIdToken()` en el backend
- **CORS:** En producción, configurar `ALLOWED_ORIGINS` con URLs específicas (no `*`)
- **MQTT:** Usar siempre TLS (puerto 8883), nunca MQTT sin cifrado (puerto 1883) en producción
- **Reglas Firestore:** Cada usuario solo puede acceder a sus propios datos (`request.auth.uid == uid`)

### Seguridad en el almacenamiento de datos

GridWise implementa las siguientes medidas de seguridad en los datos de usuario:

1. **Aislamiento de datos:** Reglas Firestore garantizan que cada usuario solo accede a sus documentos
2. **Autenticación en WebSocket:** Socket.IO verifica JWT de Firebase en el handshake
3. **No hay datos sensibles en la app:** Las API keys del backend nunca llegan al cliente Flutter
4. **Tokens efímeros:** Los Firebase ID Tokens caducan cada hora y se renuevan automáticamente

---

## Vulnerabilidades conocidas y mitigadas

Las siguientes vulnerabilidades fueron identificadas y corregidas durante el desarrollo de v1.0.0:

| ID | Descripción | Estado | Versión |
|----|-------------|--------|---------|
| GW-001 | Token de sesión Socket.IO podía caducar sin renovación automática | ✅ Corregido | 1.0.0 |
| GW-002 | El hash del token IoT no se validaba antes de procesar datos MQTT | ✅ Corregido | 1.0.0 |
| GW-003 | Reglas Firestore permitían escritura en `/iot_devices` desde el cliente | ✅ Corregido | 1.0.0 |

---

*GridWise — Seguridad es una prioridad, no una característica.*
