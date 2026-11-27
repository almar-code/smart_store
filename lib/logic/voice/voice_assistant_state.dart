// مراحل المحادثة الصوتية
enum VoiceStatus { idle, listening, thinking, speaking }

class VoiceAssistantState {
  final VoiceStatus status;
  final String transcript;
  final String reply;
  final List<dynamic> products;
  final String? errorKey;

  const VoiceAssistantState({
    this.status = VoiceStatus.idle,
    this.transcript = '',
    this.reply = '',
    this.products = const [],
    this.errorKey,
  });

  bool get isActive => status != VoiceStatus.idle;

  VoiceAssistantState copyWith({
    VoiceStatus? status,
    String? transcript,
    String? reply,
    List<dynamic>? products,
    String? errorKey,
    bool clearError = false,
  }) {
    return VoiceAssistantState(
      status: status ?? this.status,
      transcript: transcript ?? this.transcript,
      reply: reply ?? this.reply,
      products: products ?? this.products,
      errorKey: clearError ? null : (errorKey ?? this.errorKey),
    );
  }
}