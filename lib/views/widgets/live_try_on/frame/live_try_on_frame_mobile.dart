import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// نسخة الجوال: صفحة البث داخل WebView يقدّمها سيرفر محلي من assets
/// (الكاميرا تحتاج صفحة من مصدر آمن مثل localhost)
class LiveTryOnFrame extends StatefulWidget {
  final void Function(String message) onMessage;
  final void Function(void Function(String message) sender) onCreated;
  final VoidCallback onDisposed;

  const LiveTryOnFrame({
    super.key,
    required this.onMessage,
    required this.onCreated,
    required this.onDisposed,
  });

  @override
  State<LiveTryOnFrame> createState() => _LiveTryOnFrameState();
}

class _LiveTryOnFrameState extends State<LiveTryOnFrame> {
  static final InAppLocalhostServer _server = InAppLocalhostServer();
  bool _serverReady = false;

  @override
  void initState() {
    super.initState();
    _startServer();
  }

  Future<void> _startServer() async {
    if (!_server.isRunning()) await _server.start();
    if (mounted) setState(() => _serverReady = true);
  }

  @override
  void dispose() {
    widget.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_serverReady) return const ColoredBox(color: Colors.black);

    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri('http://localhost:8080/assets/live_try_on/index.html'),
      ),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        transparentBackground: true,
      ),
      onWebViewCreated: (controller) {
        controller.addJavaScriptHandler(
          handlerName: 'liveTryOn',
          callback: (args) {
            if (args.isNotEmpty) widget.onMessage(args.first.toString());
          },
        );
        widget.onCreated(
          (message) => controller.evaluateJavascript(
            source: 'window.liveTryOnReceive(${jsonEncode(message)})',
          ),
        );
      },
      // السماح لصفحة البث باستخدام الكاميرا
      onPermissionRequest: (controller, request) async => PermissionResponse(
        resources: request.resources,
        action: PermissionResponseAction.GRANT,
      ),
    );
  }
}
