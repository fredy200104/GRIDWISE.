const mqtt = require('mqtt');
const crypto = require('crypto');
const { db } = require('./firebaseAdmin');
const engine = require('./recommendationEngine');

const MQTT_BROKER = process.env.MQTT_BROKER_URL || 'mqtts://broker.emqx.io:8883';
const MQTT_USERNAME = process.env.MQTT_USERNAME;
const MQTT_PASSWORD = process.env.MQTT_PASSWORD;

class MqttService {
  constructor() {
    this.client = mqtt.connect(MQTT_BROKER, {
      clientId: `gridwise_backend_${Math.random().toString(16).substring(2, 8)}`,
      clean: true,
      connectTimeout: 4000,
      reconnectPeriod: 1000,
      username: MQTT_USERNAME,
      password: MQTT_PASSWORD,
    });

    this.client.on('connect', () => {
      console.log('MQTT connected');
      this.client.subscribe('home/+/+/data', (err) => {
        if (!err) {
          console.log('MQTT subscribed to home/+/+/data');
        } else {
          console.error('MQTT subscribe error:', err);
        }
      });
    });

    this.client.on('message', async (topic, message) => {
      try {
        const payload = JSON.parse(message.toString());
        const parts = topic.split('/');
        const userId = parts[1];
        const deviceId = parts[2];

        const iotDoc = await db.collection('iot_devices').doc(deviceId).get();
        if (!iotDoc.exists) return;
        const iotData = iotDoc.data() || {};
        if (iotData.user_id !== userId) return;

        const payloadToken = String(payload.device_token || '');
        const tokenHash = crypto.createHash('sha256').update(payloadToken).digest('hex');
        if (!payloadToken || tokenHash !== iotData.token_hash) {
          return;
        }

        const eventData = {
          source: 'iot',
          timestamp: new Date(),
          user_id: userId,
          device_id: deviceId,
          payload,
        };

        await db.collection('device_data_unified').add(eventData);
        await db
          .collection('users')
          .doc(userId)
          .collection('iot_devices')
          .doc(deviceId)
          .set(
            {
              mode: 'real',
              is_connected: true,
              last_power_watts: Number(payload.instant_power_watts || 0),
              last_seen_at: new Date(),
              updated_at: new Date(),
            },
            { merge: true },
          );
        await engine.processEvent(eventData);

      } catch (e) {
        console.error('MQTT process error:', e);
      }
    });

    this.client.on('error', (err) => {
      console.error('MQTT client error:', err);
    });
  }

  sendCommand(userId, deviceId, commandPayload) {
    const topic = `home/${userId}/${deviceId}/commands`;
    const message = JSON.stringify(commandPayload);
    this.client.publish(topic, message, { qos: 1 }, (err) => {
      if (err) {
        console.error(`MQTT publish error ${deviceId}:`, err);
      } else {
        console.log(`MQTT command sent to ${topic}`);
      }
    });
  }
}

module.exports = new MqttService();
