import 'package:flutter/material.dart';
import '../model/chat_request.dart';
import '../model/chat_response.dart';
import '../service/api_service.dart';

class ChatbotBottomSheet extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const ChatbotBottomSheet({super.key, this.onDataChanged});

  @override
  State<ChatbotBottomSheet> createState() => _ChatbotBottomSheetState();
}

class _ChatbotBottomSheetState extends State<ChatbotBottomSheet> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _api = ApiService();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text: 'Merhaba! Bugünkü görev ve etkinliklerinizi sorabilir veya doğal dille yeni ekleyebilirsiniz. Örn: "Yarın saat 15:00\'da toplantı ekle"',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;

    _controller.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _loading = true;
    });
    _scrollToBottom();

    final request = ChatRequest(message: text, date: DateTime.now());
    final response = await _api.chat(request);

    if (!mounted) return;
    setState(() => _loading = false);

    if (response != null) {
      setState(() {
        _messages.add(ChatMessage(text: response.response, isUser: false));
      });
      if (response.createdTask != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görev: ${response.createdTask!.title}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (response.createdEvent != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Etkinlik: ${response.createdEvent!.title}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      _notifyDataChangedIfNeeded(response);
    } else {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Yanıt alınamadı. Bağlantıyı veya Ollama servisini kontrol edin.',
          isUser: false,
        ));
      });
    }
    _scrollToBottom();
  }

  /// Backend listedTasks/listedEvents döndüğünde veya görev/etkinlik CRUD sonrası ana ekranı yenile.
  /// Silme işleminde DTO gelmeyebilir; metinde "silindi" geçerse de yenileriz.
  void _notifyDataChangedIfNeeded(ChatResponse response) {
    final text = response.response.toLowerCase();
    final listQuery = response.listedTasks != null || response.listedEvents != null;
    final hadCrud = response.createdTask != null || response.createdEvent != null;
    final likelyDelete = text.contains('silindi');
    if (hadCrud || listQuery || likelyDelete) {
      widget.onDataChanged?.call();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade300, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Ajanda Asistanı',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFF6366F1),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Yanıt yazılıyor...', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                final msg = _messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!msg.isUser)
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFF6366F1),
                          child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
                        ),
                      if (!msg.isUser) const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: msg.isUser
                                ? const Color(0xFF6366F1)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(
                              color: msg.isUser ? Colors.white : Colors.grey.shade800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      if (msg.isUser) const SizedBox(width: 8),
                      if (msg.isUser)
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey.shade300,
                          child: Icon(Icons.person_rounded, color: Colors.grey.shade700, size: 18),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Mesajınızı yazın...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: _loading ? null : _send,
                    borderRadius: BorderRadius.circular(24),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.send_rounded, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}
