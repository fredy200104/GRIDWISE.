# 📱 GridWise — Manual de Usuario

<div align="center">

**Versión:** 1.0.0 &nbsp;|&nbsp; **Idioma:** Español &nbsp;|&nbsp; **Plataformas:** Android · iOS · Web

*Guía completa para monitorear y optimizar el consumo energético de tu hogar*

</div>

---

## 📋 Tabla de Contenidos

1. [¿Qué es GridWise?](#1-qué-es-gridwise)
2. [Instalación y primeros pasos](#2-instalación-y-primeros-pasos)
3. [Crear una cuenta](#3-crear-una-cuenta)
4. [Iniciar sesión](#4-iniciar-sesión)
5. [Dashboard — Panel Principal](#5-dashboard--panel-principal)
6. [Gestión de dispositivos](#6-gestión-de-dispositivos)
7. [Reportes de consumo](#7-reportes-de-consumo)
8. [Centro de alertas](#8-centro-de-alertas)
9. [Recomendaciones de ahorro](#9-recomendaciones-de-ahorro)
10. [GridWise Assistant — Chat con IA](#10-gridwise-assistant--chat-con-ia)
11. [Conexión IoT con ESP32](#11-conexión-iot-con-esp32)
12. [Perfil y configuración](#12-perfil-y-configuración)
13. [Solución de problemas](#13-solución-de-problemas)
14. [Preguntas frecuentes (FAQ)](#14-preguntas-frecuentes-faq)
15. [Glosario de términos](#15-glosario-de-términos)

---

## 1. ¿Qué es GridWise?

**GridWise** es una aplicación de **gestión inteligente del consumo eléctrico** diseñada para hogares y pequeñas empresas. Con GridWise puedes:

| Función | Descripción |
|---------|-------------|
| 📊 **Monitoreo en tiempo real** | Visualiza cuántos kWh consume tu hogar en este momento |
| 🏠 **Gestión de dispositivos** | Registra todos tus electrodomésticos y calcula su impacto en la factura |
| ⚡ **Conexión IoT** | Conecta sensores físicos (ESP32) vía MQTT para medición real |
| 🔔 **Alertas inteligentes** | Recibe notificaciones cuando superes tu límite de consumo configurado |
| 💡 **Recomendaciones** | Obtén consejos personalizados de ahorro energético generados por IA |
| 📈 **Reportes detallados** | Revisa tu consumo diario, semanal y mensual con gráficos claros |
| 💬 **Chat con IA** | Habla con el asistente GridWise sobre tu consumo real en tiempo real |
| 💰 **Estimación de costos** | Calcula tu factura estimada en pesos colombianos (COP) |

> **¿Para quién es GridWise?** Para cualquier persona que quiera reducir su factura eléctrica, entender qué dispositivos consumen más y tomar decisiones informadas sobre el uso de energía.

---

## 2. Instalación y primeros pasos

### En Android

1. Descarga el archivo **GridWise.apk** desde el repositorio oficial o Google Play Store.
2. Si instalas el APK directamente, activa **"Instalar aplicaciones de fuentes desconocidas"** en Ajustes → Seguridad.
3. Toca el archivo APK y sigue las instrucciones de instalación.
4. Abre la app desde tu menú de aplicaciones.

**Requisitos mínimos Android:**
- Android 6.0 (API 23) o superior
- 50 MB de espacio libre
- Conexión a internet activa

### En iOS

1. Descarga GridWise desde la **App Store** (busca "GridWise Energía").
2. Toca **Obtener** y confirma con Face ID / Touch ID / contraseña de Apple.
3. Abre la app desde tu pantalla de inicio.

**Requisitos mínimos iOS:**
- iOS 13.0 o superior (iPhone 6s o más reciente)
- 50 MB de espacio libre
- Conexión a internet activa

### En Web (Chrome)

Accede directamente desde tu navegador:
```
https://gridwise.app
```
No requiere instalación. Compatible con Google Chrome, Microsoft Edge y Safari.

---

## 3. Crear una cuenta

### Método 1 — Registro con email

1. Abre la app → Toca **"Registrarse"** en la pantalla de bienvenida.
2. Completa el formulario:

   | Campo | Ejemplo | Observaciones |
   |-------|---------|---------------|
   | Nombre completo | Juan Pérez | Mínimo 2 caracteres |
   | Correo electrónico | juan@email.com | Debe ser un email válido |
   | Teléfono | +573001234567 | Opcional, útil para recuperar contraseña |
   | Contraseña | ••••••••• | Mínimo 6 caracteres |

3. Toca **"Crear cuenta"**.
4. Recibirás un correo de verificación de Firebase (revisa tu carpeta de spam si no llega).

### Método 2 — Registro con Google

1. En la pantalla de bienvenida → Toca el botón **"Continuar con Google"**.
2. Selecciona tu cuenta de Google en el selector que aparece.
3. Acepta los permisos solicitados.
4. ¡Listo! Tu cuenta queda creada automáticamente con los datos de tu perfil de Google.

> **💡 Consejo:** Usar Google es más rápido y no requiere recordar otra contraseña. GridWise solo accede a tu nombre y email de Google, nunca a otros datos.

---

## 4. Iniciar sesión

### Con email y contraseña

1. Pantalla de bienvenida → **"Iniciar sesión"**
2. Ingresa tu correo electrónico y contraseña
3. Toca **"Ingresar"**

### Con Google

1. Pantalla de bienvenida → Botón **"Continuar con Google"**
2. Selecciona tu cuenta → Listo

### Recuperar contraseña

1. En la pantalla de login → **"¿Olvidaste tu contraseña?"**
2. Ingresa tu correo electrónico registrado
3. Toca **"Enviar enlace"**
4. Revisa tu correo — recibirás un enlace para crear una nueva contraseña
5. El enlace caduca en 1 hora por seguridad

> **⚠️ Importante:** Si registraste tu cuenta con Google, no puedes usar recuperación por email. Simplemente usa el botón "Continuar con Google".

---

## 5. Dashboard — Panel Principal

El **Dashboard** es la pantalla principal de GridWise. Se actualiza automáticamente cada vez que agregas, editas o eliminas dispositivos.

### Tarjetas de métricas

Al entrar al dashboard, verás cuatro tarjetas principales:

| Tarjeta | Qué muestra | Cómo se calcula |
|---------|-------------|-----------------|
| ⚡ **Consumo hoy** | kWh estimados para el día actual | Suma de (potencia × horas de uso diario) de todos tus dispositivos activos |
| 💰 **Costo estimado** | Pesos colombianos (COP) del mes | kWh mensual × tarifa configurada en tu perfil |
| 📊 **Consumo mensual** | kWh totales del mes en curso | Proyección de 30 días basada en dispositivos activos |
| 📉 **Ahorro mensual** | Porcentaje vs. mes anterior | Comparación con el registro del mes anterior en Firestore |

### Gráfico de tendencia semanal

Debajo de las tarjetas encontrarás un **gráfico de barras** con el consumo estimado de los últimos 7 días. Los días con mayor consumo aparecen resaltados en color naranja o rojo.

### Indicador de alerta

Si tu consumo mensual supera el **umbral configurado en tu perfil**, aparecerá:
- Un badge rojo **"⚡ Consumo elevado"** en el encabezado del dashboard
- Una notificación en la pestaña de Alertas

### Refrescar datos

- **Gesto pull-to-refresh:** Desliza hacia abajo en el dashboard para forzar una actualización.
- **Automático:** Los cambios en dispositivos se reflejan instantáneamente gracias al stream reactivo de Firestore.

---

## 6. Gestión de dispositivos

La pestaña **Dispositivos** te permite registrar y gestionar todos los electrodomésticos de tu hogar para calcular su consumo.

### 6.1 Agregar un dispositivo

1. Pestaña **Dispositivos** → Botón **"+ Agregar"** (esquina inferior derecha)
2. Completa el formulario:

   | Campo | Descripción | Ejemplo |
   |-------|-------------|---------|
   | Nombre | Nombre descriptivo del dispositivo | "Aire acondicionado sala" |
   | Tipo | Categoría del dispositivo | Climatización, Iluminación, Electrodoméstico, etc. |
   | Marca | Fabricante (opcional) | LG, Samsung, Whirlpool |
   | Modelo | Número de modelo (opcional) | Inverter 18000 BTU |
   | Potencia (W) | Vatios que consume el dispositivo | 1500 |
   | Horas de uso/día | Promedio de horas de uso diario | 8 |
   | Ubicación | Habitación o área | Sala, Cocina, Dormitorio |
   | ¿Activo ahora? | Si el dispositivo está en uso actualmente | Sí / No |

3. Toca **"Guardar"** — el dashboard se actualiza al instante.

> **💡 ¿Dónde encuentro la potencia de mi dispositivo?** Está en la etiqueta de especificaciones del electrodoméstico (parte trasera o inferior), en el manual, o buscando el modelo en internet.

### 6.2 Tipos de dispositivos disponibles

| Icono | Tipo | Ejemplos |
|-------|------|---------|
| ❄️ | Climatización | Aire acondicionado, ventilador, calefactor |
| 💡 | Iluminación | Bombillas, lámparas, tiras LED |
| 🍳 | Electrodoméstico de cocina | Nevera, microondas, horno eléctrico |
| 👕 | Lavandería | Lavadora, secadora, plancha |
| 📺 | Entretenimiento | TV, consola, equipo de sonido |
| 💻 | Tecnología | Computador, router, impresora |
| 🔌 | Otros | Cualquier dispositivo eléctrico |

### 6.3 Editar un dispositivo

1. En la lista de dispositivos, toca el ícono **✏️** en la tarjeta del dispositivo.
2. Modifica los campos que desees.
3. Toca **"Guardar cambios"**.

### 6.4 Activar o desactivar un dispositivo

Cada tarjeta de dispositivo tiene un **switch** (interruptor). Desactiva los dispositivos que no estás usando actualmente para que no cuenten en el cálculo del dashboard.

> **Ejemplo:** Si tu aire acondicionado solo funciona en verano, desactívalo en invierno para que no infle las métricas del dashboard.

### 6.5 Eliminar un dispositivo

1. Toca el ícono **🗑️** en la tarjeta del dispositivo.
2. Confirma la eliminación en el diálogo que aparece.
3. El dispositivo y todos sus datos se eliminan permanentemente.

---

## 7. Reportes de consumo

La pestaña **Reportes** muestra análisis detallados de tu consumo energético con gráficos interactivos.

### Vistas disponibles

| Vista | Gráfico | Período | Datos mostrados |
|-------|---------|---------|-----------------|
| **📅 Diario** | Línea hora a hora | Últimas 24 horas | Consumo por hora del día |
| **📆 Semanal** | Barras por día | Últimos 7 días | Consumo diario de la semana |
| **🗓️ Mensual** | Barras por día del mes | Mes actual completo | Consumo de cada día del mes |

### Panel de estadísticas

Cada vista incluye un panel resumen con:

| Métrica | Descripción |
|---------|-------------|
| 📊 Total kWh | Consumo total del período seleccionado |
| 📈 Promedio | Consumo promedio por unidad de tiempo |
| ⬆️ Máximo | El pico más alto de consumo registrado |
| ⬇️ Mínimo | El consumo más bajo del período |
| 🌿 CO₂ evitado | Estimación de CO₂ en kg (referencial) |
| 💰 Costo estimado | Valor en COP según tu tarifa configurada |

### Compartir un reporte

1. En la pantalla de Reportes → Botón **"Compartir"** (ícono superior derecho)
2. El reporte se captura como imagen
3. Selecciona la aplicación para compartir (WhatsApp, email, etc.)

---

## 8. Centro de alertas

La pestaña **Alertas** (ícono de campana 🔔) muestra todas las notificaciones del sistema.

### Tipos de alertas

| Tipo | Ícono | Cuándo se genera |
|------|-------|-----------------|
| Consumo elevado | ⚡ | Tu consumo mensual supera el umbral configurado |
| Alta potencia instantánea | 🔴 | Un dispositivo IoT supera 1,800W |
| Consumo fantasma | 🟡 | Dispositivo en standby consume más de 80W sin uso |
| Proyección alta | 🔴 | La proyección mensual indica que superarás tu límite |

### Gestionar alertas

- **Marcar como leída:** Toca la alerta → desaparece el punto rojo
- **Marcar todas como leídas:** Botón **"Leer todas"** en el encabezado
- El número de alertas sin leer aparece como badge rojo en la pestaña de navegación

### Configurar el umbral de alertas

El umbral (límite en kWh/mes) que dispara las alertas se configura en tu perfil:  
**Perfil** → **Umbral de alerta** → Ingresa el valor en kWh → **Guardar**

> **💡 Sugerencia:** Revisa tu factura eléctrica del mes pasado para saber cuántos kWh consumiste. Usa ese número como referencia para tu umbral.

---

## 9. Recomendaciones de ahorro

La pestaña **Recomendaciones** (ícono de bombilla 💡) muestra sugerencias personalizadas para reducir tu consumo.

### Prioridades de las recomendaciones

| Color | Prioridad | Ejemplo de recomendación |
|-------|-----------|--------------------------|
| 🔴 Rojo | Alta | "Tu dispositivo está consumiendo 2,000W — es 11% más de lo normal" |
| 🟡 Amarillo | Media | "El modo standby de tu TV consume 90W innecesariamente" |
| 🟢 Verde | Baja | "Considera apagar dispositivos en horas de alta demanda (6-9 PM)" |

### Origen de las recomendaciones

Las recomendaciones se generan de dos formas:

1. **Motor de reglas automático:** Analiza los datos IoT en tiempo real con reglas predefinidas.
2. **GridWise Assistant (IA):** El chat con IA también genera recomendaciones contextualizadas basadas en tu consumo actual.

---

## 10. GridWise Assistant — Chat con IA

**GridWise Assistant** es tu asistente personal de energía, impulsado por **Google Gemini 2.5 Flash**. A diferencia de un chatbot genérico, conoce exactamente qué dispositivos tienes y cuánto están consumiendo en este momento.

### ¿Qué puede hacer el asistente?

- Explicarte qué dispositivos están consumiendo más en este momento
- Calcular cuánto te costará el mes si sigues con el consumo actual
- Darte estrategias personalizadas de ahorro basadas en tus dispositivos reales
- Responder preguntas sobre eficiencia energética y tarifas
- Ayudarte a entender tus gráficos de consumo
- Comparar dispositivos para que decidas cuál apagar primero

### Cómo usar el chat

1. Toca la pestaña **Chat** (ícono de burbuja 💬)
2. Escribe tu pregunta en el campo de texto
3. Toca **Enviar** ↑
4. El asistente responderá en segundos con información contextualizada

### Ejemplos de preguntas útiles

```
💬 "¿Cuánto voy a gastar en electricidad este mes?"
💬 "¿Qué dispositivo debo apagar para ahorrar más?"
💬 "¿Mi consumo de hoy es normal para este horario?"
💬 "¿Cómo puedo reducir mi factura a menos de $50,000 COP?"
💬 "¿Qué tan eficiente es mi aire acondicionado?"
```

### Historial de conversaciones

El asistente recuerda el historial de tu conversación. Si cierras la app y vuelves a abrirla, el historial estará disponible. Para borrar el historial:  
**Chat** → Ícono de **🗑️** en la esquina superior derecha → **Confirmar**

---

## 11. Conexión IoT con ESP32

La sección **IoT** te permite conectar sensores físicos (como el microcontrolador ESP32) para medir el consumo eléctrico real de tus dispositivos.

> **⚠️ Nota:** Esta función requiere hardware adicional (ESP32 o similar) y conocimientos básicos de electrónica. Si no tienes hardware IoT, puedes usar GridWise completamente con datos manuales.

### ¿Qué necesitas?

- Microcontrolador **ESP32** (aprox. $5-10 USD)
- Sensor de corriente **SCT-013** o módulo de medición de potencia
- Conexión WiFi en casa
- Cuenta en un broker MQTT (EMQX Cloud gratuito: [emqx.com](https://www.emqx.com))

### Paso 1 — Registrar el dispositivo IoT

1. Pestaña **IoT** → **"Registrar dispositivo"**
2. Ingresa un nombre para el sensor (ej: "Sensor sala")
3. Toca **"Generar"**
4. Anota los datos que aparecen:
   - `device_token` — clave de autenticación del sensor (¡guárdala!)
   - `topic_data` — dirección donde el sensor publica datos
   - `topic_commands` — dirección donde el sensor recibe comandos

### Paso 2 — Configurar el firmware del ESP32

Sube el firmware a tu ESP32 con los siguientes parámetros:

```cpp
// Configuración MQTT
const char* BROKER = "broker.emqx.io";
const int PORT = 8883;  // MQTT sobre TLS
const char* TOPIC = "home/{TU_USER_ID}/{TU_DEVICE_ID}/data";
const char* DEVICE_TOKEN = "{TU_DEVICE_TOKEN}";

// El ESP32 publica cada 30 segundos:
{
  "device_token": DEVICE_TOKEN,
  "instant_power_watts": lectura_sensor,
  "voltage": 120.0,
  "current_amps": lectura_corriente
}
```

Consulta la guía completa de firmware en: [`docs/esp32_firmware.md`](esp32_firmware.md)

### Paso 3 — Verificar la conexión

1. Una vez que el ESP32 esté publicando datos, el estado aparecerá como **"Online 🟢"** en la pantalla IoT.
2. Los datos de consumo en tiempo real se mostrarán en la tarjeta del dispositivo.
3. El motor de recomendaciones comenzará a analizar los datos automáticamente.

### Controlar un dispositivo desde la app

Si conectas un **relé** a tu ESP32, puedes encender/apagar dispositivos desde la app:

1. En la pantalla IoT → Toca el dispositivo conectado
2. Toca el botón **"Encender"** / **"Apagar"**
3. El comando llega al ESP32 en milisegundos vía MQTT

---

## 12. Perfil y configuración

La pestaña **Perfil** (ícono de persona 👤) te permite personalizar GridWise para que los cálculos sean precisos para tu hogar.

### Datos personales

| Campo | Descripción | Cómo modificarlo |
|-------|-------------|------------------|
| Foto de perfil | Tu foto en la app | Toca la foto → Galería o cámara |
| Nombre completo | Tu nombre en la cuenta | Toca el campo → Edita → Guarda |
| Teléfono | Para recuperar cuenta | Toca el campo → Edita → Guarda |

### Configuración energética

| Configuración | Valor por defecto | Descripción |
|---------------|------------------|-------------|
| **Tarifa (COP/kWh)** | $362.5 | Precio que paga por cada kWh según tu compañía eléctrica |
| **Umbral de alerta (kWh/mes)** | 500 kWh | Límite mensual que dispara las alertas de consumo |
| **Notificaciones** | Activadas | Alertas dentro de la app |

### ¿Dónde encuentro mi tarifa de energía?

Tu tarifa está en tu **factura de energía eléctrica**. Busca el campo "Precio por kWh" o "Tarifa". En Colombia, varía entre $350 y $600 COP/kWh según el estrato y la ciudad.

### Cerrar sesión

**Perfil** → Desliza hacia abajo → **"Cerrar sesión"** → Confirmar

---

## 13. Solución de problemas

### El dashboard muestra 0 kWh

**Causa:** No tienes dispositivos registrados o todos están desactivados.  
**Solución:** Ve a la pestaña **Dispositivos** → Agrega al menos un dispositivo → Actívalo con el switch.

### No puedo conectarme al chat IA

**Causa:** El backend no está disponible o hay problemas de red.  
**Solución:**
1. Verifica tu conexión a internet
2. Si usas la versión de desarrollo, asegúrate de que el servidor Node.js esté corriendo (`npm start` en la carpeta `gridwise-backend`)
3. En dispositivos físicos, verifica que la IP del backend en `chat_service.dart` sea la IP local de tu computador

### El gráfico de reportes no tiene datos

**Causa:** Los datos de consumo se calculan en tiempo real desde tus dispositivos. Si acabas de instalar la app, puede no haber historial.  
**Solución:** Los datos históricos se acumulan automáticamente con el tiempo a medida que la app registra tu consumo.

### El dispositivo IoT muestra "Offline"

**Causa:** El ESP32 no está publicando datos o hay problemas de conectividad MQTT.  
**Solución:**
1. Verifica que el ESP32 esté encendido y conectado al WiFi
2. Confirma que el `device_token` en el firmware sea correcto
3. Verifica que el broker MQTT sea accesible (prueba desde [EMQX WebSocket Client](https://www.emqx.com/en/mqtt/public-mqtt5-broker))

### No recibo el email de recuperación de contraseña

**Causa:** El email puede estar en spam o haber demora en el servidor.  
**Solución:**
1. Revisa la carpeta de **Spam** o **Correo no deseado**
2. Espera 5 minutos y revisa nuevamente
3. Asegúrate de haber ingresado el email con el que te registraste
4. Intenta nuevamente — Firebase permite reenviar el enlace

### La app cierra inesperadamente (crash)

**Solución:**
1. Cierra completamente la app y vuelve a abrirla
2. Verifica que tengas la última versión instalada
3. Verifica tu conexión a internet
4. Si el problema persiste, reporta el error en [GitHub Issues](https://github.com/fredy200104/GRIDWISE/issues)

---

## 14. Preguntas frecuentes (FAQ)

**¿GridWise es gratuito?**  
Sí, GridWise es completamente gratuito en su versión actual.

**¿Mis datos están seguros?**  
Sí. Tus datos se almacenan en **Firebase Cloud Firestore** con reglas de seguridad que garantizan que solo tú puedes acceder a tu información. Nadie más puede ver tus dispositivos ni tu consumo.

**¿Puedo usarlo sin hardware IoT?**  
Absolutamente. GridWise funciona al 100% con datos manuales. Solo necesitas registrar tus dispositivos con su potencia y horas de uso. Los sensores físicos son opcionales.

**¿Los datos se actualizan automáticamente?**  
Sí. La app usa Streams de Firestore que actualizan el dashboard en tiempo real cuando cambias dispositivos. Para reportes históricos, desliza hacia abajo para refrescar.

**¿Funciona sin internet?**  
No. GridWise requiere conexión a internet activa para sincronizar datos con Firebase y para que el asistente de IA funcione.

**¿Cuántos dispositivos puedo registrar?**  
No hay límite. Puedes registrar todos los dispositivos que necesites.

**¿La app funciona en tablet?**  
Sí, en Android e iOS la interfaz se adapta a tablets. En web, funciona en cualquier resolución de pantalla.

**¿Puedo usar la misma cuenta en múltiples dispositivos?**  
Sí. Tus datos están en la nube y puedes acceder desde cualquier dispositivo con tu misma cuenta.

**¿El asistente de IA guarda mis conversaciones?**  
Sí, el historial de chat se guarda en Firestore y solo tú puedes verlo. Puedes borrarlo desde el botón 🗑️ dentro del chat.

**¿Cómo reporto un error o sugiero una mejora?**  
Abre un issue en [GitHub](https://github.com/fredy200104/GRIDWISE/issues) o contáctanos por los canales del proyecto.

---

## 15. Glosario de términos

| Término | Definición |
|---------|------------|
| **kWh (kilovatio-hora)** | Unidad de energía eléctrica. 1 kWh = usar 1,000 watts durante 1 hora. Es la unidad que aparece en tu factura |
| **Watt (W)** | Unidad de potencia eléctrica. Indica cuánta energía consume un dispositivo en cada momento |
| **Tarifa eléctrica** | Precio que la compañía eléctrica cobra por cada kWh consumido (en COP/kWh) |
| **Umbral de consumo** | Límite mensual de kWh que configuras para recibir alertas cuando lo superas |
| **IoT** | "Internet of Things" — dispositivos físicos conectados a internet que envían datos automáticamente |
| **MQTT** | Protocolo de comunicación ligero usado para conectar sensores y dispositivos IoT |
| **ESP32** | Microcontrolador de bajo costo con WiFi y Bluetooth, usado como sensor de consumo |
| **Firebase** | Plataforma de Google que almacena los datos de GridWise en la nube de forma segura |
| **RAG** | "Retrieval-Augmented Generation" — técnica de IA que inyecta datos reales al modelo de lenguaje para respuestas contextualizadas |
| **Standby** | Consumo eléctrico de un dispositivo cuando está apagado pero conectado a la corriente |
| **Dashboard** | Panel principal de la app con el resumen de métricas energéticas |
| **CO₂ evitado** | Estimación de dióxido de carbono que no se emite al ahorrar energía |
| **kWp** | Kilovatio pico — medida de capacidad de paneles solares (referencial en recomendaciones) |

---

<div align="center">

*GridWise v1.0.0 — 2026 · Energía Inteligente para un Futuro Sostenible*

[Reportar un error](https://github.com/fredy200104/GRIDWISE/issues) · [Manual del Desarrollador](manual_desarrollador.md) · [Política de Privacidad](privacy_policy.md)

</div>
