# Documentacion ESP32 y Payloads MQTT (Residencial)

Esta documentacion incluye estructura de payloads JSON y un ejemplo de ESP32 para un escenario residencial.

## 1. Estructura de Payloads MQTT

### Topic de Envío de Datos (ESP32 -> Backend)
**Topico:** `home/{user_uid}/{device_id}/data`
**Frecuencia sugerida:** Cada 5 a 15 minutos.

```json
{
  "device_token": "TOKEN_ENTREGADO_POR_BACKEND",
  "instant_power_watts": 420.5,
  "voltage": 120.1,
  "current": 3.2
}
```

### Topic de Comandos (Backend -> ESP32)
**Topico:** `home/{user_uid}/{device_id}/commands`

```json
{
  "action": "set_mode",
  "value": "eco"
}
```

---

## 2. Codigo de ejemplo ESP32 (Arduino IDE)

Requiere las librerías: `PubSubClient` y `ArduinoJson`.

```cpp
#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>

const char* ssid = "TU_WIFI";
const char* password = "TU_PASSWORD";
const char* mqtt_server = "broker.emqx.io";
const int mqtt_port = 8883;

// Cambia por el ID generado en la App GridWise
const char* device_id = "device_12345";
const char* user_uid = "UID_FIREBASE";
const char* device_token = "TOKEN_GENERADO_BACKEND";

WiFiClient espClient;
PubSubClient client(espClient);

void setup_wifi() {
  delay(10);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
  }
}

void callback(char* topic, byte* payload, unsigned int length) {
  String message;
  for (int i = 0; i < length; i++) {
    message += (char)payload[i];
  }
  
  // Procesar JSON de comandos
  StaticJsonDocument<200> doc;
  deserializeJson(doc, message);
  
  const char* action = doc["action"];
  if (String(action) == "set_mode") {
    // Ajustar modo de energia del dispositivo
  }
}

void reconnect() {
  while (!client.connected()) {
    if (client.connect(device_id)) {
      // Suscribirse al topic de comandos
      String cmdTopic = String("home/") + user_uid + "/" + device_id + "/commands";
      client.subscribe(cmdTopic.c_str());
    } else {
      delay(5000);
    }
  }
}

void setup() {
  Serial.begin(115200);
  setup_wifi();
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
}

void loop() {
  if (!client.connected()) reconnect();
  client.loop();

  // Simulacion de envio cada 10 segundos
  static unsigned long lastMsg = 0;
  unsigned long now = millis();
  if (now - lastMsg > 10000) {
    lastMsg = now;
    
    StaticJsonDocument<200> doc;
    doc["device_token"] = device_token;
    doc["instant_power_watts"] = random(100, 1200);
    doc["voltage"] = 120 + random(-5, 5);
    doc["current"] = random(1, 10);
    
    char buffer[256];
    serializeJson(doc, buffer);
    
    String dataTopic = String("home/") + user_uid + "/" + device_id + "/data";
    client.publish(dataTopic.c_str(), buffer);
  }
}
```
