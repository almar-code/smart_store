// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:dio/dio.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
//
// import '../models/try_on_model.dart';
//
// /// 👗 خدمة التجربة الافتراضية - تتعامل مباشرة مع Hugging Face (CatVTON)
// ///
// /// خطوات العمل:
// ///  1. رفع صورة العميلة + صورة العباية + قناع فارغ إلى الـ Space  (/upload)
// ///  2. طلب التوليد من الدالة submit_function والحصول على event_id
// ///  3. انتظار النتيجة من البث (SSE) واستخراج رابط الصورة الناتجة
// ///  4. تنزيل الصورة الناتجة كبايتات وعرضها مباشرة
// class TryOnService {
//   // صورة PNG سوداء 1x1 تُرسل كطبقة قناع فارغة،
//   // فيقوم النموذج بتوليد القناع تلقائياً حسب نوع القطعة (overall / upper / lower)
//   static final Uint8List _blankMask = base64Decode(
//     'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAAAAAA6fptVAAAACklEQVR4nGNgAAAAAgABSK+kcQAAAABJRU5ErkJggg==',
//   );
//
//   // البادئة تختلف حسب نسخة Gradio في الـ Space (5.x = /gradio_api ، 4.x = بدون)
//   static const List<String> _prefixes = ['/gradio_api', ''];
//   String? _prefix;
//
//   // 🔑 القيم من ملف .env في فلاتر
//   String get _spaceUrl {
//     final url = dotenv.env['HF_TRYON_SPACE_URL'] ?? 'https://zhengchong-catvton.hf.space';
//     return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
//   }
//
//   String? get _token {
//     final token = dotenv.env['HF_TOKEN'];
//     return (token == null || token.trim().isEmpty) ? null : token.trim();
//   }
//
//   // المعالجة على Hugging Face قد تأخذ من 30 ثانية إلى عدة دقائق (طابور + توليد)
//   late final Dio _hfDio = Dio(
//     BaseOptions(
//       connectTimeout: const Duration(seconds: 30),
//       sendTimeout: const Duration(minutes: 2),
//       receiveTimeout: const Duration(minutes: 5),
//       headers: {if (_token != null) 'Authorization': 'Bearer $_token'},
//     ),
//   );
//
//   // Dio منفصل لتنزيل صورة المنتج من سيرفرنا (بدون توكن Hugging Face)
//   final Dio _dio = Dio();
//
//   /// تنزيل صورة المنتج في الخلفية كبايتات
//   /// [imageUrl] = ApiEndpoints.productImageUrl(item.pImage)
//   Future<Uint8List> downloadGarment(String imageUrl) async {
//     try {
//       final response = await _dio.get<List<int>>(
//         imageUrl,
//         options: Options(responseType: ResponseType.bytes),
//       );
//       final bytes = Uint8List.fromList(response.data ?? []);
//       if (bytes.isEmpty) throw TryOnException('garment_not_found');
//       return bytes;
//     } on DioException {
//       throw TryOnException('garment_not_found');
//     }
//   }
//
//   /// تنفيذ التجربة وإرجاع الصورة الناتجة كبايتات
//   Future<Uint8List> tryOn({
//     required Uint8List personImage,
//     required Uint8List garmentImage,
//     String clothType = 'overall',
//   }) async {
//     try {
//       // 1️⃣ رفع الصور الثلاث
//       final remote = await _upload([
//         _NamedBytes(personImage, 'person.jpg'),
//         _NamedBytes(garmentImage, 'garment.jpg'),
//         _NamedBytes(_blankMask, 'mask.png'),
//       ]);
//
//       // 2️⃣ طلب التوليد (نفس ترتيب مدخلات submit_function في CatVTON)
//       final eventId = await _call('submit_function', [
//         {
//           'background': _fileData(remote[0], 'person.jpg'),
//           'layers': [_fileData(remote[2], 'mask.png')],
//           'composite': _fileData(remote[0], 'person.jpg'),
//         },
//         _fileData(remote[1], 'garment.jpg'),
//         clothType, // upper | lower | overall
//         40, // num_inference_steps
//         2.5, // guidance_scale
//         42, // seed
//         'result only', // show_type
//       ]);
//
//       // 3️⃣ انتظار النتيجة
//       final resultUrl = await _waitForResult('submit_function', eventId);
//
//       // 4️⃣ تنزيل الصورة الناتجة
//       final response = await _hfDio.get<List<int>>(
//         resultUrl,
//         options: Options(responseType: ResponseType.bytes),
//       );
//       return Uint8List.fromList(response.data ?? []);
//     } on TryOnException {
//       rethrow;
//     } on DioException catch (e) {
//       print('نوع الخطأ: ${e.type}');
//       print('رسالة Dio: ${e.message}');
//       print('رمز HTTP: ${e.response?.statusCode}');
//       print('استجابة الخادم: ${e.response?.data}');
//
//       if (e.response?.statusCode == 429) {
//         throw TryOnException('quota_exceeded');
//       }
//
//       if (e.type == DioExceptionType.receiveTimeout ||
//           e.type == DioExceptionType.sendTimeout ||
//           e.type == DioExceptionType.connectionTimeout) {
//         throw TryOnException('timeout');
//       }
//
//       throw TryOnException('network');
//     } catch (_) {
//       throw TryOnException('server');
//     }
//   }
//
//   /// رفع الملفات وإرجاع مساراتها على سيرفر Gradio
//   Future<List<String>> _upload(List<_NamedBytes> files) async {
//     DioException? lastError;
//
//     for (final prefix in _prefixes) {
//       final formData = FormData();
//       for (final f in files) {
//         formData.files.add(MapEntry('files', MultipartFile.fromBytes(f.bytes, filename: f.name)));
//       }
//
//       try {
//         final response = await _hfDio.post('$_spaceUrl$prefix/upload', data: formData);
//         final data = response.data;
//         if (data is List && data.length == files.length) {
//           _prefix = prefix;
//           return data.map((e) => e.toString()).toList();
//         }
//       } on DioException catch (e) {
//         lastError = e;
//         // 404 يعني أن البادئة خاطئة، نجرب التالية
//         if (e.response?.statusCode != 404) rethrow;
//       }
//     }
//
//     throw lastError ?? TryOnException('server');
//   }
//
//   Map<String, dynamic> _fileData(String path, String name) => {
//     'path': path,
//     'orig_name': name,
//     'meta': {'_type': 'gradio.FileData'},
//   };
//
//   /// استدعاء الدالة وإرجاع event_id
//   Future<String> _call(String apiName, List<dynamic> data) async {
//     final response = await _hfDio.post(
//       '$_spaceUrl$_prefix/call/$apiName',
//       data: {'data': data},
//       options: Options(contentType: Headers.jsonContentType),
//     );
//     final eventId = response.data is Map ? response.data['event_id']?.toString() : null;
//     if (eventId == null || eventId.isEmpty) throw TryOnException('server');
//     return eventId;
//   }
//
//   /// قراءة بث النتيجة (SSE) واستخراج رابط الصورة الناتجة
//   Future<String> _waitForResult(String apiName, String eventId) async {
//     final response = await _hfDio.get<String>(
//       '$_spaceUrl$_prefix/call/$apiName/$eventId',
//       options: Options(
//         responseType: ResponseType.plain,
//         headers: {'Accept': 'text/event-stream'},
//       ),
//     );
//
//     String? event;
//     for (final line in const LineSplitter().convert(response.data ?? '')) {
//       if (line.startsWith('event:')) {
//         event = line.substring(6).trim();
//         continue;
//       }
//       if (!line.startsWith('data:')) continue;
//
//       final raw = line.substring(5).trim();
//
//       if (event == 'error') {
//         final msg = raw.toLowerCase();
//         // رسائل انتهاء الحصة المجانية من ZeroGPU
//         if (msg.contains('quota') || msg.contains('exceeded') || msg.contains('gpu duration')) {
//           throw TryOnException('quota_exceeded');
//         }
//         throw TryOnException('server');
//       }
//
//       if (event == 'complete') {
//         final payload = jsonDecode(raw);
//         if (payload is List && payload.isNotEmpty && payload.first is Map) {
//           final file = payload.first as Map;
//           String? url = file['url']?.toString();
//           if ((url == null || url.isEmpty) && file['path'] != null) {
//             url = '$_spaceUrl$_prefix/file=${file['path']}';
//           }
//           if (url != null && url.isNotEmpty) {
//             return url.startsWith('http') ? url : '$_spaceUrl$url';
//           }
//         }
//       }
//     }
//
//     throw TryOnException('server');
//   }
// }
//
// class _NamedBytes {
//   final Uint8List bytes;
//   final String name;
//   _NamedBytes(this.bytes, this.name);
// }
//
// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:dio/dio.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
//
// import '../models/try_on_model.dart';
//
// /// 👗 خدمة التجربة الافتراضية (مع نسختك الخاصة من IDM-VTON)
// class TryOnService {
//   static final Uint8List _blankMask = base64Decode(
//     'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAAAAAA6fptVAAAACklEQVR4nGNgAAAAAgABSK+kcQAAAABJRU5ErkJggg==',
//   );
//
//   static const List<String> _prefixes = ['/gradio_api', ''];
//   String? _prefix;
//
//   String get _spaceUrl {
//     final url ='https://2716omar-my-idm-vton.hf.space';
//     return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
//   }
//
//   String? get _token {
//     final token = dotenv.env['HF_TOKEN'];
//     return (token == null || token.trim().isEmpty) ? null : token.trim();
//   }
//
//   late final Dio _hfDio = Dio(
//     BaseOptions(
//       connectTimeout: const Duration(seconds: 30),
//       sendTimeout: const Duration(minutes: 2),
//       receiveTimeout: const Duration(minutes: 5),
//       headers: {if (_token != null) 'Authorization': 'Bearer $_token'},
//     ),
//   );
//
//   final Dio _dio = Dio();
//
//   Future<Uint8List> downloadGarment(String imageUrl) async {
//     try {
//       final response = await _dio.get<List<int>>(
//         imageUrl,
//         options: Options(responseType: ResponseType.bytes),
//       );
//       final bytes = Uint8List.fromList(response.data ?? []);
//       if (bytes.isEmpty) throw TryOnException('garment_not_found');
//       return bytes;
//     } on DioException {
//       throw TryOnException('garment_not_found');
//     }
//   }
//
//   Future<Uint8List> tryOn({
//     required Uint8List personImage,
//     required Uint8List garmentImage,
//     String clothType = 'overall',
//   }) async {
//     try {
//       final remote = await _upload([
//         _NamedBytes(personImage, 'person.jpg'),
//         _NamedBytes(garmentImage, 'garment.jpg'),
//         _NamedBytes(_blankMask, 'mask.png'),
//       ]);
//
//       // تم تعديل اسم الدالة إلى 'tryon' (بدون شرطة سفلية) تطابقاً مع وثائق نسختك
//       final eventId = await _call('tryon', [
//         {
//           'background': _fileData(remote[0], 'person.jpg'),
//           'layers': [_fileData(remote[2], 'mask.png')],
//           'composite': _fileData(remote[0], 'person.jpg'),
//         },
//         _fileData(remote[1], 'garment.jpg'),
//         'long full-body abaya dress, maxi length traditional robe', // وصف أدق يوضح أنها قطعتين أو طويلة بالكامل
//         true, // is_checked (auto mask)
//         true, // is_checked_crop (auto crop)
//         30, // denoising_steps
//         42, // seed
//       ]);
//
//       final resultUrl = await _waitForResult('tryon', eventId);
//
//       final response = await _hfDio.get<List<int>>(
//         resultUrl,
//         options: Options(responseType: ResponseType.bytes),
//       );
//       return Uint8List.fromList(response.data ?? []);
//     } on TryOnException {
//       rethrow;
//     } on DioException catch (e) {
//       print('نوع الخطأ: ${e.type}');
//       print('رسالة Dio: ${e.message}');
//       print('رمز HTTP: ${e.response?.statusCode}');
//       print('استجابة الخادم: ${e.response?.data}');
//
//       if (e.response?.statusCode == 429) {
//         throw TryOnException('quota_exceeded');
//       }
//
//       if (e.type == DioExceptionType.receiveTimeout ||
//           e.type == DioExceptionType.sendTimeout ||
//           e.type == DioExceptionType.connectionTimeout) {
//         throw TryOnException('timeout');
//       }
//
//       throw TryOnException('network');
//     } catch (_) {
//       throw TryOnException('server');
//     }
//   }
//
//   Future<List<String>> _upload(List<_NamedBytes> files) async {
//     DioException? lastError;
//
//     for (final prefix in _prefixes) {
//       final formData = FormData();
//       for (final f in files) {
//         formData.files.add(MapEntry('files', MultipartFile.fromBytes(f.bytes, filename: f.name)));
//       }
//
//       try {
//         final response = await _hfDio.post('$_spaceUrl$prefix/upload', data: formData);
//         final data = response.data;
//         if (data is List && data.length == files.length) {
//           _prefix = prefix;
//           return data.map((e) => e.toString()).toList();
//         }
//       } on DioException catch (e) {
//         lastError = e;
//         if (e.response?.statusCode != 404) rethrow;
//       }
//     }
//
//     throw lastError ?? TryOnException('server');
//   }
//
//   Map<String, dynamic> _fileData(String path, String name) => {
//     'path': path,
//     'orig_name': name,
//     'meta': {'_type': 'gradio.FileData'},
//   };
//
//   Future<String> _call(String apiName, List<dynamic> data) async {
//     final response = await _hfDio.post(
//       '$_spaceUrl$_prefix/call/$apiName',
//       data: {'data': data},
//       options: Options(contentType: Headers.jsonContentType),
//     );
//     final eventId = response.data is Map ? response.data['event_id']?.toString() : null;
//     if (eventId == null || eventId.isEmpty) throw TryOnException('server');
//     return eventId;
//   }
//
//   Future<String> _waitForResult(String apiName, String eventId) async {
//     final response = await _hfDio.get<String>(
//       '$_spaceUrl$_prefix/call/$apiName/$eventId',
//       options: Options(
//         responseType: ResponseType.plain,
//         headers: {'Accept': 'text/event-stream'},
//       ),
//     );
//
//     String? event;
//     for (final line in const LineSplitter().convert(response.data ?? '')) {
//       if (line.startsWith('event:')) {
//         event = line.substring(6).trim();
//         continue;
//       }
//       if (!line.startsWith('data:')) continue;
//
//       final raw = line.substring(5).trim();
//
//       if (event == 'error') {
//         final msg = raw.toLowerCase();
//         if (msg.contains('quota') || msg.contains('exceeded') || msg.contains('gpu duration')) {
//           throw TryOnException('quota_exceeded');
//         }
//         throw TryOnException('server');
//       }
//
//       if (event == 'complete') {
//         final payload = jsonDecode(raw);
//         if (payload is List && payload.isNotEmpty) {
//           final firstItem = payload.first;
//           Map? file;
//           if (firstItem is Map) {
//             file = firstItem;
//           } else if (firstItem is List && firstItem.isNotEmpty && firstItem.first is Map) {
//             file = firstItem.first as Map;
//           }
//
//           if (file != null) {
//             String? url = file['url']?.toString();
//             if ((url == null || url.isEmpty) && file['path'] != null) {
//               url = '$_spaceUrl$_prefix/file=${file['path']}';
//             }
//             if (url != null && url.isNotEmpty) {
//               return url.startsWith('http') ? url : '$_spaceUrl$url';
//             }
//           }
//         }
//       }
//     }
//
//     throw TryOnException('server');
//   }
// }
//
// class _NamedBytes {
//   final Uint8List bytes;
//   final String name;
//   _NamedBytes(this.bytes, this.name);
// }

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';

import '../../core/constants/app_endpoints.dart';
import '../models/try_on_model.dart';

/// 👗 خدمة التجربة الافتراضية بالصورة عبر Decart (Lucy Image 2)
/// ترسل صورة العميلة + صورة العباية، وترجع صورة العميلة وهي لابسة العباية.
class TryOnService {
  /// وصف مفصّل للنموذج (التوثيق يوصي بـ 20-30 كلمة)
  static const String _prompt =
      'Dress the person in the abaya from the reference image, copying it exactly: same color, fabric, pattern, embroidery, cut, sleeves, and full length down to the ankles. You can change her pose or body position freely, but keep her face, hair, and the background completely unchanged.';

  /// أقصى نسبة (العرض ÷ الطول) لنعتبر الصورة كاملة الجسم.
  /// صورة إنسان واقف من الرأس للقدم تكون طولية بوضوح (أقل من 0.65 تقريباً).
  /// ارفع الرقم إن رُفضت صور كاملة صحيحة، واخفضه إن قُبلت صور نصفية.
  static const double _fullBodyMaxRatio = 0.65;

  late final Dio _decartDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(minutes: 2),
      receiveTimeout: const Duration(minutes: 3),
      headers: {'X-API-KEY': ApiEndpoints.decartApiKey},
    ),
  );

  final Dio _dio = Dio();

  Future<Uint8List> downloadGarment(String imageUrl) async {
    try {
      final response = await _dio.get<List<int>>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data ?? []);
      if (bytes.isEmpty) throw TryOnException('garment_not_found');
      return bytes;
    } on DioException {
      throw TryOnException('garment_not_found');
    }
  }

  Future<Uint8List> tryOn({
    required Uint8List personImage,
    required Uint8List garmentImage,
    String clothType = 'overall', // غير مستخدم مع Decart، أبقيناه حتى لا يتغير استدعاء الـ Repo
  }) async {
    if (ApiEndpoints.decartApiKey.isEmpty) throw TryOnException('server');

    // ⚠️ التأكد أن صورة العميلة لجسم كامل قبل إرسالها (حتى لا يُستهلك الرصيد)
    await _ensureFullBodyPhoto(personImage);

    try {
      final formData = FormData.fromMap({
        'data': MultipartFile.fromBytes(personImage, filename: 'person.jpg'), // صورة العميلة
        'reference_image': MultipartFile.fromBytes(garmentImage, filename: 'abaya.jpg'), // صورة العباية
        'prompt': _prompt,
        'resolution': '720p', // أو 480p (أرخص وأسرع)
        'enhance_prompt': 'false',
      });

      final response = await _decartDio.post<List<int>>(
        ApiEndpoints.decartImageEdit,
        data: formData,
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = Uint8List.fromList(response.data ?? []);
      if (bytes.isEmpty) throw TryOnException('server');
      return bytes;
    } on TryOnException {
      rethrow;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      print('نوع الخطأ: ${e.type}');
      print('رمز HTTP: $status');
      // الرد يأتي bytes، نحوّله لنص لنقرأ رسالة الخطأ
      if (e.response?.data is List<int>) {
        print('استجابة الخادم: ${String.fromCharCodes(e.response!.data as List<int>)}');
      }

      if (status == 429 || status == 402) throw TryOnException('quota_exceeded');

      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        throw TryOnException('timeout');
      }

      if (status == null) throw TryOnException('network');
      throw TryOnException('server'); // 401 مفتاح خاطئ، 422 بيانات غير صحيحة...
    } catch (_) {
      throw TryOnException('server');
    }
  }

  /// يرفض صور الرأس فقط أو الجزء الصغير من الجسم (الصور المربعة أو العريضة).
  /// الفحص سريع: نفك الصورة بعرض 64 بكسل فقط لمعرفة نسبة أبعادها.
  Future<void> _ensureFullBodyPhoto(Uint8List bytes) async {
    double ratio;
    try {
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 64);
      final image = (await codec.getNextFrame()).image;
      ratio = image.width / image.height;
      image.dispose();
      codec.dispose();
    } catch (_) {
      return; // إن تعذّر الفحص لا نمنع العميلة، ونترك القرار للنموذج
    }

    if (ratio > _fullBodyMaxRatio) {
      throw TryOnException('full_body_required');
    }
  }
}