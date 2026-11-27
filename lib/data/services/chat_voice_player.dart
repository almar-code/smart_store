import 'dart:convert';
import 'dart:io' show File;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/chat_message.dart';

// مشغل واحد لكل رسائل الدردشة حتى لا يعمل صوتان معا
class ChatVoicePlayer {
  ChatVoicePlayer._() {
    _player.onPositionChanged.listen((p) => position.value = p);
    _player.onDurationChanged.listen((d) {
      if (d > Duration.zero) duration.value = d;
    });
    _player.onPlayerStateChanged.listen((s) => playing.value = s == PlayerState.playing);
    _player.onPlayerComplete.listen((_) {
      playing.value = false;
      position.value = Duration.zero;
      activeId.value = null;
    });
  }

  static final ChatVoicePlayer instance = ChatVoicePlayer._();

  final AudioPlayer _player = AudioPlayer();
  final Map<String, String> _files = {};

  final ValueNotifier<String?> activeId = ValueNotifier(null);
  final ValueNotifier<bool> playing = ValueNotifier(false);
  final ValueNotifier<Duration> position = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> duration = ValueNotifier(Duration.zero);
  final ValueNotifier<double> rate = ValueNotifier(1);

  Listenable get listenable => Listenable.merge([activeId, playing, position, duration, rate]);

  // تشغيل او ايقاف مؤقت لرسالة
  Future<void> toggle(ChatMessage m, {Duration total = Duration.zero}) async {
    if (activeId.value == m.id) {
      playing.value ? await _player.pause() : await _player.resume();
      return;
    }
    await _start(m, total: total);
  }

  // التقديم والتاخير بنسبة من 0 الى 1
  Future<void> seek(ChatMessage m, double fraction, {Duration total = Duration.zero}) async {
    fraction = fraction.clamp(0.0, 1.0);
    if (activeId.value != m.id) {
      await _start(m, total: total, fraction: fraction);
      return;
    }
    final len = duration.value > Duration.zero ? duration.value : total;
    final target = len * fraction;
    position.value = target;
    await _player.seek(target);
  }

  // تبديل السرعة بين 1 و 1.5 و 2
  Future<void> cycleRate() async {
    rate.value = rate.value == 1 ? 1.5 : rate.value == 1.5 ? 2 : 1;
    if (activeId.value != null) await _player.setPlaybackRate(rate.value);
  }

  Future<void> stop() async {
    await _player.stop();
    playing.value = false;
    position.value = Duration.zero;
    activeId.value = null;
  }

  Future<void> _start(ChatMessage m, {Duration total = Duration.zero, double fraction = 0}) async {
    await _player.stop();
    activeId.value = m.id;
    duration.value = total;
    position.value = total * fraction;
    try {
      await _player.play(await _source(m), position: total * fraction);
      await _player.setPlaybackRate(rate.value);
    } catch (e) {
      debugPrint('chat voice play error: $e');
      await stop();
    }
  }

  // مصدر الصوت حسب المنصة
  Future<Source> _source(ChatMessage m) async {
    final mime = m.audioMime ?? 'audio/wav';
    if (kIsWeb) {
      return UrlSource('data:$mime;base64,${base64Encode(m.audioBytes!)}');
    }
    if (m.audioPath != null) return DeviceFileSource(m.audioPath!);

    // حفظ البايتات في ملف مؤقت مرة واحدة
    final cached = _files[m.id];
    if (cached != null) return DeviceFileSource(cached);
    final dir = await getTemporaryDirectory();
    final ext = mime.contains('mp4') || mime.contains('m4a') ? 'm4a' : mime.contains('mpeg') ? 'mp3' : 'wav';
    final file = File('${dir.path}/chat_voice_${m.id}.$ext');
    await file.writeAsBytes(m.audioBytes!, flush: true);
    _files[m.id] = file.path;
    return DeviceFileSource(file.path);
  }
}
