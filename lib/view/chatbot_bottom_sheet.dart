import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
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
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _loading = false;
  bool _speechAvailable = false;
  bool _isListening = false;
  /// Parmak mikrofondaysa; motor erken `notListening` verse bile görünür durumu bozmamak için.
  bool _micPointerDown = false;
  bool _voiceResponseEnabled = true;

  /// Sesli giriş ve TTS yalnızca Android’de (iOS’ta Info.plist / hedef yok).
  static bool get _androidVoice =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text: 'Merhaba! Bugünkü görev ve etkinliklerinizi sorabilir veya doğal dille yeni ekleyebilirsiniz. Örn: "Yarın saat 15:00\'da toplantı ekle"',
      isUser: false,
    ));
    _initVoice();
  }

  @override
  void dispose() {
    if (_androidVoice) {
      _speechToText.stop();
      _flutterTts.stop();
    }
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initVoice() async {
    if (!_androidVoice) {
      if (!mounted) return;
      setState(() => _speechAvailable = false);
      return;
    }

    final available = await _speechToText.initialize(
      onStatus: (status) {
        if (!mounted) return;
        if (status == 'done' || status == 'notListening') {
          if (!_micPointerDown) setState(() => _isListening = false);
        }
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _isListening = false);
      },
    );

    await _flutterTts.setLanguage('tr-TR');
    await _flutterTts.setSpeechRate(0.48);
    await _flutterTts.setPitch(1.0);

    if (!mounted) return;
    setState(() => _speechAvailable = available);
  }

  Future<void> _micPressStart() async {
    if (_loading || _isListening) return;
    if (!_speechAvailable) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesli giriş kullanılamıyor. Mikrofon iznini kontrol edin.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _micPointerDown = true);
    await _flutterTts.stop();
    final started = await _speechToText.listen(
      localeId: 'tr_TR',
      onResult: _onSpeechResult,
      listenMode: ListenMode.dictation,
      partialResults: true,
      pauseFor: const Duration(seconds: 10),
      listenFor: const Duration(minutes: 2),
    );

    if (!mounted) return;
    if (!_micPointerDown) {
      await _speechToText.stop();
      setState(() => _isListening = false);
      return;
    }
    setState(() => _isListening = started);
    if (!started) setState(() => _micPointerDown = false);
  }

  Future<void> _micPressEnd() async {
    if (!_micPointerDown && !_isListening) return;

    setState(() => _micPointerDown = false);
    await _speechToText.stop();

    if (!mounted) return;
    setState(() => _isListening = false);

    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted || _loading) return;

    final text = _controller.text.trim();
    if (text.isNotEmpty) await _send();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    setState(() {
      _controller.text = result.recognizedWords;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
  }

  Future<void> _speak(String text) async {
    if (!_androidVoice || !_voiceResponseEnabled || text.trim().isEmpty) return;
    await _flutterTts.stop();
    await _flutterTts.speak(text);
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
      _speak(response.response);
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
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Ajanda Asistanı',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (_androidVoice) ...[
                  Tooltip(
                    message: _voiceResponseEnabled
                        ? 'Sesli cevap açık — kapatmak için dokunun'
                        : 'Sesli cevap kapalı — açmak için dokunun',
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _voiceResponseEnabled = !_voiceResponseEnabled;
                          if (!_voiceResponseEnabled) _flutterTts.stop();
                        });
                      },
                      icon: Icon(
                        _voiceResponseEnabled
                            ? Icons.record_voice_over_rounded
                            : Icons.voice_over_off_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
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
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFF6366F1),
                          child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
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
                if (_androidVoice) ...[
                  Tooltip(
                    message: _speechAvailable
                        ? 'Basılı tutun, konuşun, bırakınca gönderilir'
                        : 'Sesli giriş kullanılamıyor',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown:
                          _loading || !_speechAvailable ? null : (_) => _micPressStart(),
                      onTapUp:
                          _loading || !_speechAvailable ? null : (_) => _micPressEnd(),
                      onTapCancel: _loading || !_speechAvailable
                          ? null
                          : () => _micPressEnd(),
                      child: Material(
                        color: _isListening
                            ? const Color(0xFFE11D48)
                            : (_speechAvailable && !_loading
                                ? Colors.white
                                : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            _isListening ? Icons.mic : Icons.mic_none_rounded,
                            color: _isListening ? Colors.white : const Color(0xFF6366F1),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
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
