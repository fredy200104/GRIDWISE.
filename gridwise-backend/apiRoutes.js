const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const mqttService = require('./mqttService');
const engine = require('./recommendationEngine');
const { admin, db } = require('./firebaseAdmin');

const authMiddleware = async (req, res, next) => {
  const authHeader = req.headers.authorization || '';
  const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : null;
  if (!token) return res.status(401).json({ error: 'Missing bearer token' });

  try {
    const decoded = await admin.auth().verifyIdToken(token);
    req.auth = decoded;
    return next();
  } catch (_) {
    return res.status(401).json({ error: 'Invalid token' });
  }
};

router.post('/consumption/manual', authMiddleware, async (req, res) => {
  try {
    const { device_id, payload } = req.body || {};
    if (!payload || typeof payload !== 'object') {
      return res.status(400).json({ error: 'Invalid payload' });
    }

    const userId = req.auth.uid;

    const eventData = {
      source: 'manual',
      timestamp: new Date(),
      user_id: userId,
      device_id: device_id || null,
      payload,
    };

    await db.collection('device_data_unified').add(eventData);
    await engine.processEvent(eventData);

    res.status(200).json({ success: true, message: 'Manual residential data processed' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.post('/device/:id/command', authMiddleware, (req, res) => {
  const deviceId = req.params.id;
  const commandPayload = req.body || {};

  if (!deviceId || typeof commandPayload !== 'object') {
    return res.status(400).json({ error: 'Invalid command payload' });
  }

  mqttService.sendCommand(req.auth.uid, deviceId, commandPayload);
  res.status(200).json({ success: true, message: `Command sent to device ${deviceId}` });
});

router.post('/devices/register', authMiddleware, async (req, res) => {
  try {
    const { name, type, location } = req.body || {};
    if (!name || !type) {
      return res.status(400).json({ error: 'name and type are required' });
    }

    const deviceToken = crypto.randomBytes(32).toString('hex');
    const tokenHash = crypto.createHash('sha256').update(deviceToken).digest('hex');
    const userId = req.auth.uid;

    const createdAt = new Date();
    const deviceData = {
      name,
      type,
      user_id: userId,
      location: location || 'hogar',
      status: 'offline',
      token_hash: tokenHash,
      createdAt,
    };

    const docRef = await db.collection('iot_devices').add(deviceData);
    await db
      .collection('users')
      .doc(userId)
      .collection('iot_devices')
      .doc(docRef.id)
      .set({
        name,
        type,
        location: location || 'hogar',
        mode: 'real',
        is_connected: false,
        last_power_watts: 0,
        last_seen_at: null,
        created_at: createdAt,
        updated_at: createdAt,
      });

    res.status(201).json({ 
      success: true, 
      device_id: docRef.id,
      device_token: deviceToken,
      mqtt_data_topic: `home/${userId}/${docRef.id}/data`,
      mqtt_command_topic: `home/${userId}/${docRef.id}/commands`,
      message: 'Dispositivo registrado para conexion real.',
    });
  } catch (error) {
    res.status(500).json({ error: 'Error registering device' });
  }
});

router.post('/dashboard/projection', authMiddleware, async (req, res) => {
  const projected = Number(req.body?.projected_monthly_kwh || 0);
  const threshold = Number(req.body?.threshold_kwh || 500);
  const eventData = {
    source: 'dashboard',
    timestamp: new Date(),
    user_id: req.auth.uid,
    payload: {
      projected_monthly_kwh: projected,
      threshold_kwh: threshold,
    },
  };
  await engine.processEvent(eventData);
  return res.status(200).json({ success: true });
});

module.exports = router;
