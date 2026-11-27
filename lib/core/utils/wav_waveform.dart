import 'dart:math' as math;
import 'dart:typed_data';

// نتيجة تحليل ملف wav
class WavInfo {
  final List<double> samples;
  final Duration duration;
  const WavInfo(this.samples, this.duration);
}

// استخراج الموجة والمدة من ملف wav
class WavWaveform {
  static WavInfo? parse(Uint8List b, {int bars = 60}) {
    if (b.length < 44 || _tag(b, 0) != 'RIFF' || _tag(b, 8) != 'WAVE') return null;
    final bd = ByteData.sublistView(b);

    int format = 1, channels = 1, rate = 16000, bits = 16;
    int? dataStart;
    int dataLen = 0;

    // البحث عن جزء fmt وجزء data
    var pos = 12;
    while (pos + 8 <= b.length) {
      final id = _tag(b, pos);
      final size = bd.getUint32(pos + 4, Endian.little);
      if (id == 'fmt ' && pos + 24 <= b.length) {
        format = bd.getUint16(pos + 8, Endian.little);
        channels = math.max(1, bd.getUint16(pos + 10, Endian.little));
        rate = bd.getUint32(pos + 12, Endian.little);
        bits = bd.getUint16(pos + 22, Endian.little);
      } else if (id == 'data') {
        dataStart = pos + 8;
        dataLen = math.min(size, b.length - dataStart);
        break;
      }
      pos += 8 + size + (size.isOdd ? 1 : 0);
    }
    if (dataStart == null || rate <= 0) return null;

    final bytesPerSample = math.max(1, bits ~/ 8);
    final frameSize = bytesPerSample * channels;
    final frames = dataLen ~/ frameSize;
    if (frames == 0) return null;

    final duration = Duration(milliseconds: (frames * 1000 / rate).round());
    final bucket = math.max(1, frames ~/ bars);
    final stride = math.max(1, bucket ~/ 40); // تخطي عينات للسرعة

    final peaks = <double>[];
    for (var start = 0; start < frames && peaks.length < bars; start += bucket) {
      var peak = 0.0;
      final end = math.min(start + bucket, frames);
      for (var f = start; f < end; f += stride) {
        final v = _sample(bd, dataStart + f * frameSize, format, bits).abs();
        if (v > peak) peak = v;
      }
      peaks.add(peak);
    }

    // تطبيع القيم بين 0 و 1
    final maxPeak = peaks.fold<double>(0, math.max);
    final samples = peaks
        .map((p) => maxPeak == 0 ? 0.05 : math.sqrt(p / maxPeak).clamp(0.05, 1.0).toDouble())
        .toList();
    return WavInfo(samples, duration);
  }

  // قراءة عينة واحدة حسب الصيغة
  static double _sample(ByteData bd, int offset, int format, int bits) {
    if (offset >= bd.lengthInBytes) return 0;
    if (format == 7) return _muLaw(bd.getUint8(offset)) / 32768;
    if (format == 3 && bits == 32) return bd.getFloat32(offset, Endian.little);
    if (bits == 16) return bd.getInt16(offset, Endian.little) / 32768;
    if (bits == 8) return (bd.getUint8(offset) - 128) / 128;
    return 0;
  }

  // فك ترميز mu-law
  static int _muLaw(int u) {
    u = ~u & 0xFF;
    final sign = u & 0x80;
    final exponent = (u >> 4) & 0x07;
    final mantissa = u & 0x0F;
    var sample = ((mantissa << 3) + 0x84) << exponent;
    sample -= 0x84;
    return sign != 0 ? -sample : sample;
  }

  static String _tag(Uint8List b, int at) => String.fromCharCodes(b.sublist(at, at + 4));
}
