const express = require('express');
const router = express.Router();
const { admin, db } = require('./firebaseAdmin');
const { getRecentHistory } = require('./chatService');

// Middleware de autenticación reutilizado
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

/**
 * GET /api/chat/history
 * Retorna los últimos 30 mensajes del usuario
 */
router.get('/history', authMiddleware, async (req, res) => {
  try {
    const snapshot = await db
      .collection('chat_conversations')
      .doc(req.auth.uid)
      .collection('messages')
      .orderBy('timestamp', 'desc')
      .limit(30)
      .get();

    if (snapshot.empty) return res.json({ messages: [] });

    const messages = snapshot.docs
      .map((doc) => ({
        id: doc.id,
        role: doc.data().role,
        content: doc.data().content,
        timestamp: doc.data().timestamp?.toDate?.()?.toISOString() || null,
      }))
      .reverse();

    return res.json({ messages });
  } catch (error) {
    console.error('Error al obtener historial de chat:', error);
    return res.status(500).json({ error: 'Error al obtener historial' });
  }
});

/**
 * DELETE /api/chat/history
 * Limpia toda la conversación del usuario
 */
router.delete('/history', authMiddleware, async (req, res) => {
  try {
    const messagesRef = db
      .collection('chat_conversations')
      .doc(req.auth.uid)
      .collection('messages');

    const snapshot = await messagesRef.get();
    const batch = db.batch();
    snapshot.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();

    // Eliminar metadata
    await db.collection('chat_conversations').doc(req.auth.uid).delete();

    return res.json({ success: true, message: 'Historial eliminado' });
  } catch (error) {
    console.error('Error al limpiar historial:', error);
    return res.status(500).json({ error: 'Error al limpiar historial' });
  }
});

module.exports = router;
