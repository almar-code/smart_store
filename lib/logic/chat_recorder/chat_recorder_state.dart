// مراحل التسجيل
enum RecorderPhase { idle, recording, locked }

class ChatRecorderState {
  final RecorderPhase phase;
  final Duration elapsed;
  final List<double> samples;
  final double slide; // تقدم السحب للالغاء من 0 الى 1
  final double lift; // تقدم السحب للقفل من 0 الى 1

  const ChatRecorderState({
    this.phase = RecorderPhase.idle,
    this.elapsed = Duration.zero,
    this.samples = const [],
    this.slide = 0,
    this.lift = 0,
  });

  bool get isActive => phase != RecorderPhase.idle;

  ChatRecorderState copyWith({
    RecorderPhase? phase,
    Duration? elapsed,
    List<double>? samples,
    double? slide,
    double? lift,
  }) {
    return ChatRecorderState(
      phase: phase ?? this.phase,
      elapsed: elapsed ?? this.elapsed,
      samples: samples ?? this.samples,
      slide: slide ?? this.slide,
      lift: lift ?? this.lift,
    );
  }
}
