import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/chat_message.dart';

import 'dart:io' show Platform;

/// Obtiene la URL del backend dinámicamente según la plataforma
String get _kBackendUrl {
  if (kIsWeb) {
    return 'http://127.0.0.1:3000';
  } else if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000'; // IP especial para acceder a localhost desde emulador Android
  } else {
    return 'http://localhost:3000'; // iOS simulador, Windows de escritorio, etc.
  }
}

/// Estados posibles de la conexión Socket.IO
enum ChatConnectionState { disconnected, connecting, connected, error }

/// Servicio de chat que gestiona la conexión Socket.IO con el backend GridWise.
/// Expone un [ValueNotifier] de mensajes y un [ValueNotifier] del estado de conexión
/// para que la UI reaccione reactivamente sin necesitar setState().
class ChatService extends ChangeNotifier {
  io.Socket? _socket;

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  ChatConnectionState _connectionState = ChatConnectionState.disconnected;
  ChatConnectionState get connectionState => _connectionState;

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  String? _conversationId;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isConnected => _connectionState == ChatConnectionState.connected;

  // ─── Ciclo de vida ──────────────────────────────────────────────────────────

  /// Inicializa el servicio: obtiene token de Firebase y conecta Socket.IO
  Future<void> connect() async {
    if (_connectionState == ChatConnectionState.connecting ||
        _connectionState == ChatConnectionState.connected) return;

    // Destruir socket anterior si existe
    _socket?.dispose();
    _socket = null;

    _setConnectionState(ChatConnectionState.connecting);
    _errorMessage = null;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      // Siempre forzar refresh del token para evitar tokens expirados
      final token = await user.getIdToken(true);
      _conversationId ??= 'conv_${user.uid}_${DateTime.now().millisecondsSinceEpoch}';

      _socket = io.io(
        _kBackendUrl,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .disableAutoConnect()
            .enableReconnection()          // Socket.IO reintenta solo
            .setReconnectionAttempts(5)
            .setReconnectionDelay(2000)
            .setAuth({'token': token})
            .setTimeout(10000)
            .build(),
      );

      _registerEventHandlers();
      _socket!.connect();
    } catch (e) {
      _errorMessage = e.toString();
      _setConnectionState(ChatConnectionState.error);
      debugPrint('❌ ChatService connect error: $e');
    }
  }


  /// Desconecta el socket limpiamente
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _setConnectionState(ChatConnectionState.disconnected);
  }

  // ─── Eventos Socket.IO ──────────────────────────────────────────────────────

  void _registerEventHandlers() {
    _socket!
      ..onConnect((_) {
        debugPrint('✅ Socket.IO conectado al chat');
        _setConnectionState(ChatConnectionState.connected);
        _errorMessage = null;

        // Mensaje de bienvenida si es la primera conexión
        if (_messages.isEmpty) {
          _addMessage(ChatMessage.assistant(
            '¡Hola! Soy GridWise Assistant 🌱 Tu asistente inteligente.\n\n'
            'Por favor, escribe "Español" o "English" para elegir el idioma del chat.\n'
            'Please type "Español" or "English" to choose the chat language.'
          ));
          
          Future.delayed(const Duration(milliseconds: 500), () {
            _addMessage(ChatMessage.assistant(
              '“Soy LIBRE, AUTÓNOMO Y RESPONSABLE a través del diálogo y la construcción, como ideal regulativo; me dirijo, controlo y dicto mis propias leyes.”\n\n'
              'Mi propósito es acompañarte en tu transformación positiva y bienestar. '
              '¿En qué puedo ayudarte hoy / How can I help you today?'
            ));
          });
        }
      })
      ..onConnectError((data) {
        debugPrint('❌ Socket.IO connect error: $data');
        _errorMessage = 'Error de conexión al servidor';
        _setConnectionState(ChatConnectionState.error);
      })
      ..onDisconnect((reason) {
        debugPrint('🔌 Socket.IO desconectado: $reason');
        _setConnectionState(ChatConnectionState.disconnected);
      })
      ..on('chat:response', (data) {
        final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
        final content = map['message'] as String? ?? '';
        if (content.isNotEmpty) {
          _addMessage(ChatMessage.assistant(content));
        }
      })
      ..on('chat:typing', (data) {
        final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
        _isTyping = map['typing'] as bool? ?? false;
        notifyListeners();
      })
      ..on('chat:error', (data) {
        final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
        final errMsg = map['error'] as String? ?? 'Error desconocido';
        _isTyping = false;
        _addMessage(ChatMessage.system('⚠️ $errMsg'));
      });
  }

  // ─── Envío de mensajes ──────────────────────────────────────────────────────

  /// Envía un mensaje al backend via Socket.IO
  void sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // Agregar mensaje del usuario a la lista local inmediatamente
    _addMessage(ChatMessage.user(trimmed));

    if (!isConnected) {
      _addMessage(ChatMessage.system('⚠️ Sin conexión al servidor. Reconectando...'));
      connect();
      return;
    }

    _socket!.emit('chat:message', {
      'message': trimmed,
      'conversationId': _conversationId,
    });
  }

  // ─── Utilidades ─────────────────────────────────────────────────────────────

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  void _addMessage(ChatMessage msg) {
    _messages.add(msg);
    notifyListeners();
  }

  void _setConnectionState(ChatConnectionState state) {
    _connectionState = state;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
