// 🌐 استيراد شرطي: الويب يستخدم iframe، والجوال يستخدم WebView
export 'live_try_on_frame_mobile.dart'
    if (dart.library.js_interop) 'live_try_on_frame_web.dart';
