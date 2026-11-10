import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_endpoints.dart';
import '../../data/models/product_model.dart';
import 'live_try_on_state.dart';

/// دالة إرسال الأوامر إلى صفحة البث (تُسجّلها نافذة البث عند إنشائها)
typedef LiveTryOnSender = void Function(String message);

class LiveTryOnCubit extends Cubit<LiveTryOnState> {
  LiveTryOnCubit() : super(const LiveTryOnState());

  LiveTryOnSender? _sender;
  Timer? _timer;

  // ==================== التحكم بالنافذة ====================
  void open() => emit(state.copyWith(isOpen: true, isMinimized: false));

  void toggleMinimize() => emit(state.copyWith(isMinimized: !state.isMinimized));

  void closePanel() {
    stop();
    emit(const LiveTryOnState()); // إعادة كل شيء للبداية
  }

  /// تُستدعى من onTap في بطاقات المنتجات بأي صفحة.
  /// ترجع true إذا كانت النافذة مفتوحة وتم إرسال العباية للتجربة (فلا ننتقل لصفحة المنتج).
  bool handleProductTap(ProductModel product) {
    if (!state.isOpen) return false;
    selectGarment(
      imageUrl: ApiEndpoints.productImageUrl(product.pImage),
      name: product.pNameEn ?? product.pName,
    );
    return true;
  }

  void selectGarment({required String imageUrl, String? name}) {
    emit(state.copyWith(garmentImageUrl: imageUrl, garmentName: name, isMinimized: false));
    // إذا كان البث شغالاً تتبدل العباية فوراً بدون قطع الاتصال
    if (state.isLive) {
      _send({'type': 'garment', 'imageUrl': imageUrl, 'prompt': _buildPrompt(name)});
    }
  }

  // ==================== الاتصال بصفحة البث ====================
  void attachSender(LiveTryOnSender sender) => _sender = sender;

  void detachSender() {
    _sender = null;
    _stopTimer();
    emit(state.copyWith(isPageReady: false, status: LiveTryOnStatus.idle));
  }

  /// استقبال الرسائل القادمة من صفحة البث
  void onPageMessage(String raw) {
    final Map<String, dynamic> msg;
    try {
      msg = jsonDecode(raw);
    } catch (_) {
      return;
    }
    if (msg['source'] != 'live_try_on') return;

    switch (msg['type']) {
      case 'ready':
        emit(state.copyWith(isPageReady: true));
      case 'connecting':
        emit(state.copyWith(status: LiveTryOnStatus.connecting));
      case 'live':
        emit(state.copyWith(status: LiveTryOnStatus.live, remainingSeconds: ApiEndpoints.liveTryOnSeconds));
        _startTimer();
      case 'stopped':
        _stopTimer();
        emit(state.copyWith(status: LiveTryOnStatus.idle, remainingSeconds: 0));
      case 'error':
        _stopTimer();
        emit(state.copyWith(
          status: LiveTryOnStatus.idle,
          remainingSeconds: 0,
          errorKey: _mapError('${msg['message']}'),
        ));
    }
  }

  // ==================== بدء وإيقاف البث ====================
  Future<void> start() async {
    if (state.isRunning) return;
    if (!state.hasGarment) {
      emit(state.copyWith(errorKey: 'live_try_on_pick_abaya_first'));
      return;
    }
    if (ApiEndpoints.decartApiKey.isEmpty) {
      emit(state.copyWith(errorKey: 'live_try_on_invalid_key'));
      return;
    }
    if (!state.isPageReady) {
      emit(state.copyWith(errorKey: 'live_try_on_not_ready'));
      return;
    }

    // على الجوال يجب أخذ إذن الكاميرا للتطبيق قبل أن تطلبه صفحة البث
    if (!kIsWeb) {
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        emit(state.copyWith(errorKey: 'live_try_on_camera_denied'));
        return;
      }
    }

    emit(state.copyWith(status: LiveTryOnStatus.connecting));
    _send({
      'type': 'start',
      'apiKey': ApiEndpoints.decartApiKey,
      'imageUrl': state.garmentImageUrl,
      'prompt': _buildPrompt(state.garmentName),
    });
  }

  void stop() {
    _stopTimer();
    if (state.isRunning) _send({'type': 'stop'});
    emit(state.copyWith(status: LiveTryOnStatus.idle, remainingSeconds: 0));
  }

  // ==================== العداد التنازلي (يوقف البث عند الانتهاء لحماية الرصيد) ====================
  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = state.remainingSeconds - 1;
      if (next <= 0) {
        stop();
      } else {
        emit(state.copyWith(remainingSeconds: next));
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // ==================== أدوات مساعدة ====================
  void _send(Map<String, dynamic> command) {
    _sender?.call(jsonEncode({'target': 'live_try_on', ...command}));
  }

  /// وصف العباية للنموذج (بالإنجليزية لأنها أدق مع النموذج)
  String _buildPrompt(String? name) {
    final title = (name == null || name.trim().isEmpty) ? 'abaya' : name.trim();
    return 'Substitute the current outfit with a long, loose, full-length abaya '
        '($title) exactly as shown in the reference image, covering the body to the ankles';
  }

  String _mapError(String raw) {
    final text = raw.toLowerCase();
    if (text.contains('notallowed') || text.contains('permission')) return 'live_try_on_camera_denied';
    if (text.contains('notfound') || text.contains('notreadable')) return 'live_try_on_no_camera';
    if (text.contains('401') || text.contains('unauthorized') || text.contains('api key')) {
      return 'live_try_on_invalid_key';
    }
    if (text.contains('402') || text.contains('credit') || text.contains('insufficient')) {
      return 'live_try_on_no_credits';
    }
    if (text.contains('garment_load_failed')) return 'live_try_on_garment_failed';
    return 'live_try_on_failed';
  }

  @override
  Future<void> close() {
    _stopTimer();
    return super.close();
  }
}
