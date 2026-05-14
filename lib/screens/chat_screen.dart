import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

/// Pantalla completa del chatbot GridWise Assistant
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final ChatService _chatService = ChatService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  late final AnimationController _typingController;

  @override
  void initState() {
    super.initState();

    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Conectar y escuchar cambios
    _chatService.addListener(_onChatChanged);
    _chatService.connect();
  }

  void _onChatChanged() {
    if (mounted) {
      setState(() {});
      // Scroll al final cuando llega un mensaje nuevo
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    _chatService.sendMessage(text);
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _chatService.removeListener(_onChatChanged);
    _chatService.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingController.dispose();
    super.dispose();
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildChatHeader(isDark, theme),
          _buildConnectionBanner(isDark, theme),
          Expanded(child: _buildMessageList(isDark, theme)),
          if (_chatService.isTyping) _buildTypingIndicator(isDark, theme),
          _buildInputBar(isDark, theme),
        ],
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────

  Widget _buildChatHeader(bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0D1B2A), const Color(0xFF1A2744)]
              : [const Color(0xFF005BBF), const Color(0xFF1A73E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF1A73E8) : const Color(0xFF005BBF))
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar del bot
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
            ),
            child: const Center(
              child: Icon(Icons.energy_savings_leaf, color: Color(0xFF00C853), size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GridWise Assistant',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _buildStatusDot(),
                    const SizedBox(width: 6),
                    Text(
                      _statusLabel(),
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Botón limpiar
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white70, size: 22),
            onPressed: _confirmClearChat,
            tooltip: 'Limpiar conversación',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDot() {
    Color dotColor;
    switch (_chatService.connectionState) {
      case ChatConnectionState.connected:
        dotColor = const Color(0xFF00C853);
        break;
      case ChatConnectionState.connecting:
        dotColor = Colors.amber;
        break;
      case ChatConnectionState.error:
        dotColor = Colors.redAccent;
        break;
      default:
        dotColor = Colors.grey;
    }
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
    );
  }

  String _statusLabel() {
    switch (_chatService.connectionState) {
      case ChatConnectionState.connected:
        return 'En línea';
      case ChatConnectionState.connecting:
        return 'Conectando...';
      case ChatConnectionState.error:
        return 'Sin conexión';
      default:
        return 'Desconectado';
    }
  }

  // ─── Banner de error de conexión ─────────────────────────────────────────────

  Widget _buildConnectionBanner(bool isDark, ThemeData theme) {
    final state = _chatService.connectionState;
    if (state == ChatConnectionState.connected ||
        state == ChatConnectionState.connecting) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: state == ChatConnectionState.error
          ? Colors.redAccent.withOpacity(0.12)
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded,
              size: 16,
              color: state == ChatConnectionState.error ? Colors.redAccent : Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _chatService.errorMessage ?? 'Sin conexión al servidor',
              style: GoogleFonts.inter(
                color: state == ChatConnectionState.error
                    ? Colors.redAccent
                    : Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _chatService.connect,
            icon: const Icon(Icons.refresh_rounded, size: 14),
            label: const Text('Reconectar'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              textStyle: GoogleFonts.inter(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Lista de mensajes ───────────────────────────────────────────────────────

  Widget _buildMessageList(bool isDark, ThemeData theme) {
    final messages = _chatService.messages;

    if (messages.isEmpty) {
      return _buildEmptyState(isDark, theme);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      itemCount: messages.length,
      itemBuilder: (ctx, i) {
        final msg = messages[i];
        final showDate = i == 0 ||
            !_isSameDay(messages[i - 1].timestamp, msg.timestamp);

        return Column(
          children: [
            if (showDate) _buildDateDivider(msg.timestamp, isDark),
            _buildMessageBubble(msg, isDark, theme),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark, ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF005BBF), Color(0xFF1A73E8)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A73E8).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.energy_savings_leaf,
                  color: Color(0xFF00C853), size: 44),
            ),
            const SizedBox(height: 24),
            Text(
              'GridWise Assistant',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu asistente inteligente de energía.\nPregúntame lo que necesites.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                '¿Cuánto consumo esta semana?',
                '¿Cómo ahorro energía?',
                '¿Qué son los kWh?',
                'Ver mis alertas',
              ]
                  .map((q) => _buildSuggestionChip(q, isDark, theme))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String label, bool isDark, ThemeData theme) {
    return ActionChip(
      label: Text(label, style: GoogleFonts.inter(fontSize: 12)),
      onPressed: () {
        _textController.text = label;
        _sendMessage();
      },
      backgroundColor:
          isDark ? const Color(0xFF1E2336) : const Color(0xFFECEDF7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.3)),
    );
  }

  Widget _buildDateDivider(DateTime date, bool isDark) {
    final label = _formatDateLabel(date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
              child: Divider(color: Colors.grey.withOpacity(isDark ? 0.2 : 0.3))),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Expanded(
              child: Divider(color: Colors.grey.withOpacity(isDark ? 0.2 : 0.3))),
        ],
      ),
    );
  }

  // ─── Burbuja de mensaje ──────────────────────────────────────────────────────

  Widget _buildMessageBubble(ChatMessage msg, bool isDark, ThemeData theme) {
    if (msg.isSystem) return _buildSystemMessage(msg, isDark);

    final isUser = msg.isUser;

    return Padding(
      padding: EdgeInsets.only(
        top: 4,
        bottom: 4,
        left: isUser ? 48 : 0,
        right: isUser ? 0 : 48,
      ),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _buildBotAvatar(isDark),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildBubbleContainer(msg, isUser, isDark, theme),
                const SizedBox(height: 3),
                Text(
                  DateFormat('HH:mm').format(msg.timestamp),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.grey.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildBotAvatar(bool isDark) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF005BBF), Color(0xFF1A73E8)],
        ),
      ),
      child: const Icon(Icons.energy_savings_leaf,
          color: Color(0xFF00C853), size: 16),
    );
  }

  Widget _buildBubbleContainer(
      ChatMessage msg, bool isUser, bool isDark, ThemeData theme) {
    final userGradient = const LinearGradient(
      colors: [Color(0xFF005BBF), Color(0xFF1565C0)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final botBg = isDark ? const Color(0xFF1E2336) : const Color(0xFFECEDF7);

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isUser ? 18 : 4),
      bottomRight: Radius.circular(isUser ? 4 : 18),
    );

    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      decoration: BoxDecoration(
        gradient: isUser ? userGradient : null,
        color: isUser ? null : botBg,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: (isUser
                    ? const Color(0xFF1A73E8)
                    : Colors.black)
                .withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Text(
        msg.content,
        style: GoogleFonts.inter(
          fontSize: 14.5,
          color: isUser ? Colors.white : theme.colorScheme.onSurface,
          height: 1.45,
        ),
      ),
    );
  }

  Widget _buildSystemMessage(ChatMessage msg, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(isDark ? 0.12 : 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Text(
            msg.content,
            style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // ─── Indicador "escribiendo..." ───────────────────────────────────────────────

  Widget _buildTypingIndicator(bool isDark, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildBotAvatar(isDark),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2336) : const Color(0xFFECEDF7),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: AnimatedBuilder(
              animation: _typingController,
              builder: (ctx, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final delay = i / 3;
                    final progress = (_typingController.value + delay) % 1.0;
                    final scale = 0.5 + 0.5 * sin(progress * pi * 2);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Barra de entrada ────────────────────────────────────────────────────────

  Widget _buildInputBar(bool isDark, ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1626) : Colors.white,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.15),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E2336)
                    : const Color(0xFFF4F5FC),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(
                    _focusNode.hasFocus ? 0.5 : 0.1,
                  ),
                ),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14.5,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildSendButton(theme),
        ],
      ),
    );
  }

  Widget _buildSendButton(ThemeData theme) {
    final canSend = _chatService.isConnected && !_chatService.isTyping;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: canSend
            ? const LinearGradient(
                colors: [Color(0xFF005BBF), Color(0xFF1A73E8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: canSend ? null : Colors.grey.withOpacity(0.3),
        boxShadow: canSend
            ? [
                BoxShadow(
                  color: const Color(0xFF1A73E8).withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: canSend ? _sendMessage : null,
          child: const Icon(
            Icons.send_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  void _confirmClearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpiar conversación'),
        content: const Text(
            '¿Estás seguro de que quieres borrar todos los mensajes de esta sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _chatService.clearMessages();
            },
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) return 'Hoy';
    if (_isSameDay(date, now.subtract(const Duration(days: 1)))) return 'Ayer';
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
