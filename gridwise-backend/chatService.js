const { GoogleGenAI } = require('@google/genai');
const { db } = require('./firebaseAdmin');

const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

// Prompt del sistema: asistente energético de GridWise
const SYSTEM_PROMPT = `Eres GridWise Assistant, un asistente inteligente integrado en la plataforma GridWise de gestión energética residencial. 

Tu misión es ayudar a los usuarios a:
- Entender su consumo energético y cómo reducirlo
- Interpretar reportes y alertas del sistema
- Obtener recomendaciones personalizadas para ahorrar energía
- Resolver dudas sobre dispositivos IoT conectados (ESP32, sensores)
- Comprender métricas como kWh, vatios, proyecciones mensuales
- Aprender buenas prácticas de eficiencia energética

Responde siempre de forma clara, amigable y concisa. Si el usuario escribe en español, responde en español. Si escribe en inglés, responde en inglés. 

Cuando no tengas datos específicos del usuario, da consejos generales basados en buenas prácticas energéticas.`;

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
    let context = `\n\n--- DATOS ACTUALES DEL USUARIO ---\n`;
    
    // Obtener dispositivos
    const devicesSnap = await db.collection('users').doc(userId).collection('iot_devices').get();
    if (!devicesSnap.empty) {
      context += `Dispositivos IoT conectados:\n`;
      devicesSnap.forEach(doc => {
        const d = doc.data();
        context += `- ${d.name} (${d.type} en ${d.location}): ${d.last_power_watts || 0}W, Estado: ${d.is_connected ? 'Conectado' : 'Desconectado'}\n`;
      });
    } else {
      context += `El usuario no tiene dispositivos IoT registrados actualmente.\n`;
    }

    // Obtener recomendaciones pendientes
    const recsSnap = await db.collection('recommendations')
      .where('user_id', '==', userId)
      .where('status', '==', 'pending')
      .limit(3)
      .get();
      
    if (!recsSnap.empty) {
      context += `\nRecomendaciones recientes del sistema para este usuario:\n`;
      recsSnap.forEach(doc => {
        const r = doc.data();
        context += `- Prioridad ${r.priority}: ${r.message}\n`;
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
  // Recuperar historial para dar contexto a la IA
  const history = await getRecentHistory(userId);
  
  // Recuperar contexto en tiempo real del usuario
  const userContext = await getUserContext(userId);

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

  // Persistir ambos mensajes
  await saveMessage(userId, conversationId, 'user', userMessage);
  await saveMessage(userId, conversationId, 'assistant', assistantReply);

  return assistantReply;
}

module.exports = { generateResponse, getRecentHistory, saveMessage };
