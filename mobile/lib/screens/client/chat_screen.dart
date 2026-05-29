import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../models/message_model.dart';
import '../../services/api_service.dart';
import '../../services/socket_service.dart';
import '../../config/api_config.dart';
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  final int solicitudId;
  final String otroNombre;
  final bool esTecnico;
  const ChatScreen({super.key, required this.solicitudId, required this.otroNombre, required this.esTecnico});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<MessageModel> _messages = [];
  bool _loading = true;
  bool _typing = false;
  int? _receptorId;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    SocketService.joinSolicitud(widget.solicitudId);
    SocketService.onNuevaMensaje((data) {
      final msg = MessageModel.fromJson(Map<String, dynamic>.from(data));
      setState(() => _messages.add(msg));
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    SocketService.offEvent('nuevo_mensaje');
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final result = await ApiService.get(ApiConfig.chat(widget.solicitudId));
    if (result['success'] && mounted) {
      setState(() {
        _messages = (result['data'] as List).map((e) => MessageModel.fromJson(e)).toList();
        _loading = false;
      });
      _scrollToBottom();
    } else {
      setState(() => _loading = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _sendMessage({String? text, String tipo = 'texto', double? lat, double? lng}) async {
    final userId = context.read<AuthProvider>().user!.id;
    final body = {
      'contenido': text ?? '',
      'tipo': tipo,
      if (lat != null) 'latitud': lat.toString(),
      if (lng != null) 'longitud': lng.toString(),
      'receptor_id': (_receptorId ?? 0).toString(),
    };
    await ApiService.post(ApiConfig.chat(widget.solicitudId), body);
    if (text != null) _msgCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().user?.id ?? 0;
    final nombreChat = widget.esTecnico ? 'J&P Corporate Systems' : 'J&P Corporate Systems';

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(nombreChat, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text(
              widget.esTecnico ? 'Técnico: ${widget.otroNombre}' : 'Técnico: ${widget.otroNombre}',
              style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.phone_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Online status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: AppColors.surface,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text('CHAT CON ${widget.otroNombre.toUpperCase()} — EN LÍNEA', style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            ]),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final msg = _messages[i];
                      final isMe = msg.emisorId == userId;
                      // Date separator
                      final showDate = i == 0 || _messages[i - 1].createdAt.day != msg.createdAt.day;
                      return Column(
                        children: [
                          if (showDate) Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(20)),
                              child: const Text('HOY', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          _MessageBubble(msg: msg, isMe: isMe),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
          ),
          // Input area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              children: [
                // Botones de acción (sólo para técnicos)
                if (widget.esTecnico) Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _ActionButton(icon: Icons.location_on, label: 'Enviar ubicación', onTap: () => SocketService.updateLocation(widget.solicitudId, -12.0464, -77.0428)),
                        const SizedBox(width: 8),
                        _ActionButton(icon: Icons.check_circle, label: 'Llegué al destino', onTap: () => SocketService.llegueDestino(widget.solicitudId)),
                        const SizedBox(width: 8),
                        _ActionButton(icon: Icons.access_time, label: 'En camino', onTap: () => SocketService.enCamino(widget.solicitudId)),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.add, color: AppColors.textSecondary), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.image_outlined, color: AppColors.textSecondary), onPressed: () {}),
                    Expanded(
                      child: TextField(
                        controller: _msgCtrl,
                        decoration: InputDecoration(
                          hintText: 'Escribe un mensaje...',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.border)),
                        ),
                        onChanged: (v) {
                          if (v.isNotEmpty && !_typing) { SocketService.sendTyping(widget.solicitudId); _typing = true; }
                          if (v.isEmpty && _typing) { SocketService.stopTyping(widget.solicitudId); _typing = false; }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        if (_msgCtrl.text.trim().isEmpty) return;
                        _sendMessage(text: _msgCtrl.text.trim());
                        _msgCtrl.clear();
                        SocketService.stopTyping(widget.solicitudId);
                        _typing = false;
                      },
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(22)),
                        child: const Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel msg;
  final bool isMe;
  const _MessageBubble({required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe) ...[
          CircleAvatar(radius: 16, backgroundColor: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.person, size: 16, color: AppColors.primary)),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe) Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Text(msg.emisorNombre?.toUpperCase() ?? '', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
              ),
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                padding: msg.tipo == 'imagen' ? const EdgeInsets.all(4) : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.chatBubbleSent : AppColors.chatBubbleReceived,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                  border: isMe ? null : Border.all(color: AppColors.border),
                  boxShadow: isMe ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: msg.tipo == 'imagen' && msg.imagenUrl != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network('${ApiConfig.baseUrl}/${msg.imagenUrl}', width: 200, height: 150, fit: BoxFit.cover))
                    : Text(msg.contenido ?? '', style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary, fontSize: 14)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${msg.createdAt.hour.toString().padLeft(2, '0')}:${msg.createdAt.minute.toString().padLeft(2, '0')} AM',
                      style: const TextStyle(fontSize: 10, color: AppColors.textHint),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Text(msg.leido ? '• Leído' : '', style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 8),
          CircleAvatar(radius: 16, backgroundColor: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.person, size: 16, color: AppColors.primary)),
        ],
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.primary)),
      ]),
    ),
  );
}
