enum LiveTryOnStatus { idle, connecting, live }

class LiveTryOnState {
  final bool isOpen; // النافذة مفتوحة
  final bool isMinimized; // النافذة مصغّرة
  final bool isPageReady; // صفحة البث جاهزة لاستقبال الأوامر
  final LiveTryOnStatus status;
  final String? garmentImageUrl; // العباية الحالية
  final String? garmentName;
  final int remainingSeconds; // العداد التنازلي
  final String? errorKey; // مفتاح ترجمة الخطأ

  const LiveTryOnState({
    this.isOpen = false,
    this.isMinimized = false,
    this.isPageReady = false,
    this.status = LiveTryOnStatus.idle,
    this.garmentImageUrl,
    this.garmentName,
    this.remainingSeconds = 0,
    this.errorKey,
  });

  bool get hasGarment => garmentImageUrl != null;
  bool get isLive => status == LiveTryOnStatus.live;
  bool get isConnecting => status == LiveTryOnStatus.connecting;
  bool get isRunning => status != LiveTryOnStatus.idle;

  LiveTryOnState copyWith({
    bool? isOpen,
    bool? isMinimized,
    bool? isPageReady,
    LiveTryOnStatus? status,
    String? garmentImageUrl,
    String? garmentName,
    int? remainingSeconds,
    String? errorKey,
  }) {
    return LiveTryOnState(
      isOpen: isOpen ?? this.isOpen,
      isMinimized: isMinimized ?? this.isMinimized,
      isPageReady: isPageReady ?? this.isPageReady,
      status: status ?? this.status,
      garmentImageUrl: garmentImageUrl ?? this.garmentImageUrl,
      garmentName: garmentName ?? this.garmentName,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      errorKey: errorKey, // الخطأ يظهر مرة واحدة ثم يُمسح تلقائياً
    );
  }
}
