require('dotenv').config();
const express = require('express');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');
const { admin } = require('./firebaseAdmin');
const { generateResponse } = require('./chatService');

// ─── App & HTTP Server ────────────────────────────────────────────────────────
const app = express();
const server = http.createServer(app);
const port = process.env.PORT || 3000;

// ─── CORS ─────────────────────────────────────────────────────────────────────
const allowedOrigins = (process.env.ALLOWED_ORIGINS || '')
  .split(',')
  .map((item) => item.trim())
  .filter(Boolean);

const corsOptions = {
  origin(origin, callback) {
    if (!origin || allowedOrigins.length === 0 || allowedOrigins.includes(origin)) {
      return callback(null, true);
    }
    return callback(new Error('CORS origin not allowed'), false);
  },
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  credentials: true,
};

app.use(cors(corsOptions));
app.use(express.json());

// ─── Socket.IO ────────────────────────────────────────────────────────────────
const io = new Server(server, {
  cors: {
    origin: '*', // En producción, restringir a los orígenes del app Flutter
    methods: ['GET', 'POST'],
  },
  transports: ['websocket', 'polling'],
});

/**
 * Middleware Socket.IO: verifica el Firebase ID token en el handshake
 */
io.use(async (socket, next) => {
  const token = socket.handshake.auth?.token;
  if (!token) return next(new Error('Authentication error: missing token'));

  try {
    const decoded = await admin.auth().verifyIdToken(token);
    socket.data.userId = decoded.uid;
    socket.data.email = decoded.email;
    return next();
  } catch (err) {
    console.error('❌ Socket auth error:', err.message);
    return next(new Error('Authentication error: invalid token'));
  }
});

io.on('connection', (socket) => {
  const userId = socket.data.userId;
  console.log(`🔗 Chat conectado: ${userId} (${socket.id})`);

  // El cliente se une a su sala personal para recibir respuestas solo a él
  socket.join(`user_${userId}`);

  /**
   * Evento: chat:message
   * Payload: { message: string, conversationId: string }
   */
  socket.on('chat:message', async (payload) => {
    const { message, conversationId } = payload || {};

    if (!message || typeof message !== 'string' || message.trim() === '') {
      return socket.emit('chat:error', { error: 'Mensaje vacío o inválido' });
    }

    const convId = conversationId || `conv_${userId}_${Date.now()}`;

    // Notificar al cliente que el bot está escribiendo
    socket.emit('chat:typing', { typing: true });

    try {
      const reply = await generateResponse(userId, convId, message.trim());

      socket.emit('chat:typing', { typing: false });
      socket.emit('chat:response', {
        conversationId: convId,
        message: reply,
        timestamp: new Date().toISOString(),
      });
    } catch (err) {
      console.error('❌ Error generando respuesta del chatbot:', err.message);
      socket.emit('chat:typing', { typing: false });
      socket.emit('chat:error', {
        error: 'No se pudo generar una respuesta. Por favor, inténtalo de nuevo.',
      });
    }
  });

  socket.on('disconnect', (reason) => {
    console.log(`🔌 Chat desconectado: ${userId} — motivo: ${reason}`);
  });
});

// ─── Servicios auto-inicializados ─────────────────────────────────────────────
require('./mqttService');

// ─── Rutas HTTP ───────────────────────────────────────────────────────────────
const apiRoutes = require('./apiRoutes');
const chatRoutes = require('./chatRoutes');

app.use('/api', apiRoutes);
app.use('/api/chat', chatRoutes);

// ─── Health check ─────────────────────────────────────────────────────────────
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    service: 'GridWise Residential Backend',
    features: ['MQTT', 'Socket.IO Chat', 'OpenAI'],
  });
});

// ─── Iniciar servidor ─────────────────────────────────────────────────────────
server.listen(port, () => {
  console.log(`🚀 Servidor backend escuchando en el puerto ${port}`);
  console.log(`💬 Socket.IO chat listo en ws://localhost:${port}`);
});
