import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'dart:html' as html;

import '../../../core/theme/bloc/theme_bloc.dart';
import '../../../core/theme/bloc/theme_event.dart';

// Web TTS
import 'dart:html' as html;

const String geminiApiKey = "***************************-QV3toQ1A";

enum AssistantState { idle, listening, thinking, speaking }

class VoiceAssistantPage extends StatefulWidget {
  const VoiceAssistantPage({super.key});

  @override
  State<VoiceAssistantPage> createState() => _VoiceAssistantPageState();
}

class _VoiceAssistantPageState extends State<VoiceAssistantPage> {
  final SpeechToText _speech = SpeechToText();

  AssistantState _state = AssistantState.idle;

  final List<Map<String, String>> _memory = [];

  String _buffer = "";
  bool _isSpeaking = false;
  bool _initialized = false;

  Timer? _silenceTimer;

  // ================= INIT =================
  Future<void> _initAssistant() async {
    final available = await _speech.initialize();

    if (!available) return;

    setState(() {
      _initialized = true;
      _state = AssistantState.listening;
    });

    _startListening();
  }

  // ================= LISTEN =================
  Future<void> _startListening() async {
    await _speech.stop();

    setState(() => _state = AssistantState.listening);

    await _speech.listen(
      localeId: 'ar',
      listenMode: ListenMode.dictation,
      partialResults: true,
      listenFor: const Duration(minutes: 999),
      onResult: (result) {
        if (_isSpeaking) return;

        final text = result.recognizedWords.trim();
        if (text.isEmpty) return;

        _buffer = text;

        _silenceTimer?.cancel();

        _silenceTimer = Timer(const Duration(seconds: 1), () {
          _process(_buffer);
        });
      },
    );
  }

  // ================= PROCESS =================
  Future<void> _process(String text) async {
    if (text.trim().isEmpty) return;

    setState(() => _state = AssistantState.thinking);

    _memory.add({"role": "user", "text": text});

    final reply = await _askGemini(text);

    _memory.add({"role": "assistant", "text": reply});

    await _speak(reply);
  }

  // ================= GEMINI =================
  Future<String> _askGemini(String text) async {
    final url =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AIzaSyCXod3pZu8rZoNAarDmJocuGD-QV3toQ1A";

    final context = _memory
        .takeLast(6)
        .map((e) => "${e['role']}: ${e['text']}")
        .join("\n");

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text":
                "أنت مساعد صوتي ذكي عربي. رد بشكل طبيعي ومختصر وواضح.\n\nالسياق:\n$context\n\nالسؤال: $text"
              }
            ]
          }
        ]
      }),
    );

    final data = jsonDecode(response.body);

    return data["candidates"][0]["content"]["parts"][0]["text"];
  }

  // ================= SPEAK (FIXED) =================
  Future<void> _speak(String text) async {
    _isSpeaking = true;
    setState(() => _state = AssistantState.speaking);

    await _speech.stop();

    final synth = html.window.speechSynthesis;

    if (synth == null) return;

    synth.cancel();

    final utterance = html.SpeechSynthesisUtterance(text)
      ..lang = 'ar-SA'
      ..rate = 1.0
      ..pitch = 1.0
      ..volume = 1.0;

    utterance.onEnd.listen((_) {
      _isSpeaking = false;
      _startListening();
    });

    utterance.onError.listen((_) {
      _isSpeaking = false;
      _startListening();
    });

    synth.speak(utterance);
  }

  @override
  void dispose() {
    _speech.stop();
    _silenceTimer?.cancel();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("المساعد الذكي"),
        backgroundColor: const Color(0xFF03C383),
      ),
      body: Center(
        child: !_initialized
            ? ElevatedButton(
          onPressed: _initAssistant,
          child: const Text("تفعيل المساعد 🎤"),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              switch (_state) {
                AssistantState.listening => "🎤 أستمع...",
                AssistantState.thinking => "🧠 أفكر...",
                AssistantState.speaking => "🤖 أتكلم...",
                _ => "جاهز",
              },
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startListening,
              child: const Text("إعادة الاستماع"),
            )
          ],
        ),
      ),
    );
  }
}

// ================= EXTENSION =================
extension LastTake<T> on List<T> {
  List<T> takeLast(int n) {
    if (length <= n) return this;
    return sublist(length - n);
  }
}




// ================= VOICE ASSISTANT =================

class VoiceAssistantPagee extends StatefulWidget {
  const VoiceAssistantPagee({super.key});

  @override
  State<VoiceAssistantPagee> createState() => _VoiceAssistantPageStatee();
}

class _VoiceAssistantPageStatee extends State<VoiceAssistantPagee> {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  String _text = "اضغط على زر التحدث لبدء الاستماع التلقائي";

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _speech.initialize();

    if (!kIsWeb) {
      await _tts.setLanguage("ar-SA");
      await _tts.setVoice({"name": "Naayf", "locale": "ar-SA"});
      await _tts.setSpeechRate(1.2);
      await _tts.setPitch(1.0);
    }
  }

  // 🔊 دالة موحدة للصوت (Web + Mobile)
  Future<void> speak(String text) async {
    if (kIsWeb) {
      final utterance = html.SpeechSynthesisUtterance(text);
      utterance.lang = 'ar-SA';
      html.window.speechSynthesis?.speak(utterance);
    } else {
      await _tts.speak(text);
    }
  }

  // 🎤 بدء الاستماع التلقائي
  void _startListening() async {
    if (_isListening) return;

    setState(() {
      _isListening = true;
      _text = "أنا أستمع إليك الآن، تحدث بوضوح...";
    });

    await _speech.listen(
      localeId: 'ar',
      // لتسجيل الصوت باستمرار دون انقطاع حتى يتوقف المستخدم عن الكلام
      listenFor: const Duration(seconds: 15),
      onResult: (result) {
        setState(() {
          _text = result.recognizedWords;
        });

        // عندما ينتهي المستخدم من الكلام (Final Result)، نقوم بتحليل الأمر تلقائياً بدون ضغط زر
        if (result.finalResult) {
          _stopListeningAndProcess();
        }
      },
    );
  }

  // ⛔ إيقاف الاستماع التلقائي ومعالجة الأمر
  void _stopListeningAndProcess() async {
    await _speech.stop();

    setState(() {
      _isListening = false;
      _text = "جاري تنفيذ الأمر...";
    });

    await _handleCommand(_text);
  }

  // 🧠 تحليل الأوامر تلقائياً
  Future<void> _handleCommand(String text) async {
    final lower = text.toLowerCase().trim();

    if (lower.contains("ليلي") || lower.contains("dark") || lower.contains("أسود")) {
      context.read<ThemeBloc>().add(ToggleThemeEvent());
      await speak("تم تفعيل الوضع الليلي بنجاح");
      setState(() {
        _text = "تم تغيير الوضع بنجاح";
      });
    }
    else if (lower.contains("نهاري") || lower.contains("فاتح") || lower.contains("أبيض")) {
      context.read<ThemeBloc>().add(ToggleThemeEvent());
      await speak("تم تفعيل الوضع النهاري بنجاح");
      setState(() {
        _text = "تم تغيير الوضع بنجاح";
      });
    }
    else {
      await speak("عذراً، لم أفهم طلبك. يرجى إعادة المحاولة");
      setState(() {
        _text = "حاول مرة أخرى";
      });
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("المساعد الذكي"),
        backgroundColor: const Color(0xFF03C383),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // التموج البصري (يظهر فقط أثناء الاستماع)
              if (_isListening) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFF03C383),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFF03C383),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFF03C383),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF03C383)),
                  backgroundColor: Colors.black12,
                ),
              ],
              const SizedBox(height: 32),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    _text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isListening ? _stopListeningAndProcess : _startListening,
        backgroundColor: const Color(0xFF03C383),
        icon: Icon(
          _isListening ? Icons.stop : Icons.mic,
          color: Colors.white,
        ),
        label: Text(
          _isListening ? "إيقاف الاستماع" : "تحدث",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
