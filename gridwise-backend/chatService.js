const { GoogleGenAI } = require('@google/genai');
const { db } = require('./firebaseAdmin');

const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

// Prompt del sistema: asistente energético de GridWise
const SYSTEM_PROMPT = `Eres GridWise Assistant, un asistente inteligente integrado en la plataforma GridWise de gestión energética residencial. 

Tu filosofía orientadora se basa en la siguiente declaración institucional:
"Soy LIBRE, AUTÓNOMO Y RESPONSABLE a través del diálogo y la construcción, como ideal regulativo; me dirijo, controlo y dicto mis propias leyes."

Debes integrar esta filosofía en tus interacciones, promoviendo conceptos de:
- Desarrollo humano y evolución personal.
- Ética y autonomía en el consumo de recursos.
- Transformación positiva y bienestar integral.
- Responsabilidad social y consciencia ecológica.

Tu misión técnica es ayudar a los usuarios a:
- Entender su consumo energético y cómo reducirlo
- Interpretar reportes y alertas del sistema
- Obtener recomendaciones personalizadas para ahorrar energía
- Resolver dudas sobre dispositivos IoT conectados (ESP32, sensores)
- Comprender métricas como kWh, vatios, proyecciones mensuales

Responde siempre de forma clara, amigable y reflexiva, combinando la precisión técnica con un enfoque de desarrollo humano. Si el usuario escribe en español, responde en español. Si escribe en inglés, responde en inglés. 

Cuando no tengas datos específicos del usuario, da consejos generales basados en buenas prácticas energéticas y responsabilidad social.`;

/**
 * Guarda un mensaje en Firestore bajo la colección chat_conversations/{userId}/messages
 */
async function saveMessage(userId, conversationId, role, content) {
  try {
    const messagesRef = db
      .collection('chat_conversations')
      .doc(userId)
      .collection('messages');

    await messagesRef.add({
      conversationId,
      role,        // 'user' | 'assistant'
      content,
      timestamp: new Date(),
    });

    // Actualizar metadata de la conversación
    await db.collection('chat_conversations').doc(userId).set(
      {
        conversationId,
        lastMessage: content.substring(0, 100),
        lastUpdated: new Date(),
        userId,
      },
      { merge: true },
    );
  } catch (err) {
    console.error('⚠️ Error guardando mensaje en Firestore:', err.message);
    // No lanzamos el error para que el chat siga funcionando aunque Firestore falle
  }
}

/**
 * Obtiene el historial reciente de una conversación (últimos 10 mensajes)
 */
async function getRecentHistory(userId) {
  try {
    const snapshot = await db
      .collection('chat_conversations')
      .doc(userId)
      .collection('messages')
      .orderBy('timestamp', 'desc')
      .limit(10)
      .get();

    if (snapshot.empty) return [];

    return snapshot.docs
      .map((doc) => ({ role: doc.data().role, content: doc.data().content }))
      .reverse(); // Orden cronológico
  } catch (err) {
    console.error('⚠️ Error obteniendo historial:', err.message);
    return [];
  }
}

/**
 * Obtiene información de contexto del usuario (dispositivos y recomendaciones)
 */
async function getUserContext(userId) {
  try {
    let context = `\n\n--- DATOS DE CONSUMO ACTUAL DEL USUARIO ---\n`;
    
    // Ejecutar consultas a Firebase en paralelo para reducir latencia
    const [summaryDoc, devicesSnap, alertsSnap] = await Promise.all([
      db.collection('users').doc(userId).collection('dashboard_summary').doc('current').get(),
      db.collection('users').doc(userId).collection('devices').get(),
      db.collection('users').doc(userId).collection('alerts')
        .where('read', '==', false)
        .limit(3)
        .get()
    ]);
    
    // 1. Resumen del Dashboard
    if (summaryDoc.exists) {
      const s = summaryDoc.data();
      context += `Resumen Mensual:\n`;
      context += `- Consumo actual mes: ${s.current_kwh || 0} kWh\n`;
      context += `- Gasto estimado mes: $${s.estimated_cost || 0}\n`;
      context += `- Presupuesto configurado: $${s.budget || 'No definido'}\n`;
      context += `- Proyección fin de mes: ${s.projected_kwh || 0} kWh\n\n`;
    } else {
      context += `Resumen Mensual: No hay datos registrados aún.\n\n`;
    }

    // 2. Dispositivos (devices)
    if (!devicesSnap.empty) {
      context += `Dispositivos Registrados:\n`;
      devicesSnap.forEach(doc => {
        const d = doc.data();
        context += `- ${d.name} (${d.category || 'General'}): ${d.power_watts || 0}W - Estado: ${d.status || 'Desconocido'}\n`;
      });
      context += `\n`;
    }

    // 3. Alertas (alerts)
      
    if (!alertsSnap.empty) {
      context += `Alertas recientes sin leer:\n`;
      alertsSnap.forEach(doc => {
        const a = doc.data();
        context += `- [${a.type || 'Alerta'}]: ${a.message || ''}\n`;
      });
    }

    return context;
  } catch (err) {
    console.error('⚠️ Error obteniendo contexto de usuario:', err.message);
    return ''; // Si falla, devolvemos string vacío para no romper el chat
  }
}

/**
 * Genera una respuesta usando Gemini con historial de conversación y contexto de dispositivos
 */
async function generateResponse(userId, conversationId, userMessage) {
  // Ejecutar historial y contexto en paralelo
  const [history, userContext] = await Promise.all([
    getRecentHistory(userId),
    getUserContext(userId)
  ]);

  const contents = history.map(msg => ({
    role: msg.role === 'assistant' ? 'model' : msg.role,
    parts: [{ text: msg.content }]
  }));
  
  contents.push({ role: 'user', parts: [{ text: userMessage }] });

  const response = await ai.models.generateContent({
    model: process.env.GEMINI_MODEL || 'gemini-2.5-flash',
    contents: contents,
    config: {
      systemInstruction: SYSTEM_PROMPT + userContext,
      temperature: 0.7,
    }
  });

  const assistantReply = response.text;

  // Persistir ambos mensajes en paralelo (no bloqueamos el return esperando uno por uno)
  Promise.all([
    saveMessage(userId, conversationId, 'user', userMessage),
    saveMessage(userId, conversationId, 'assistant', assistantReply)
  ]).catch(err => console.error('Error guardando mensajes:', err));

  return assistantReply;
}

module.exports = { generateResponse, getRecentHistory, saveMessage };
