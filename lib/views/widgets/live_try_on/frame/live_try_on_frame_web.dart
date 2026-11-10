import 'dart:js_interop';
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// نسخة الويب: صفحة البث داخل iframe من نفس الموقع (assets)، والتواصل عبر postMessage
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
  late final JSFunction _listener;

  @override
  void initState() {
    super.initState();
    _listener = ((web.MessageEvent event) {
      final data = event.data;
      if (data != null && data.typeofEquals('string')) {
        widget.onMessage((data as JSString).toDart);
      }
    }).toJS;
    web.window.addEventListener('message', _listener);
  }

  @override
  void dispose() {
    web.window.removeEventListener('message', _listener);
    widget.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      tagName: 'iframe',
      onElementCreated: (Object element) {
        final frame = element as web.HTMLIFrameElement;
        frame
          ..src = 'assets/assets/live_try_on/index.html'
          ..allow = 'camera; autoplay';
        frame.style
          ..border = 'none'
          ..width = '100%'
          ..height = '100%';

        widget.onCreated((message) => frame.contentWindow?.postMessage(message.toJS, '*'.toJS));
      },
    );
  }
}
