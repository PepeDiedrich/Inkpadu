import 'dart:io';

import 'package:inkpadu/features/drawing/domain/webview_node.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as wf;
import 'package:webview_windows/webview_windows.dart' as ww;

/// A cross-platform webview that uses `webview_windows` on Desktop Windows,
/// and `webview_flutter` elsewhere.
class CrossPlatformWebView extends StatefulWidget {
  /// The webview node data to display in this widget.
  final WebViewNode node;

  /// Creates a cross-platform webview widget for the given [node].
  const CrossPlatformWebView({super.key, required this.node});

  @override
  State<CrossPlatformWebView> createState() => _CrossPlatformWebViewState();
}

class _CrossPlatformWebViewState extends State<CrossPlatformWebView> {
  wf.WebViewController? _flutterController;
  ww.WebviewController? _windowsController;
  bool _isWindowsReady = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  @override
  void didUpdateWidget(CrossPlatformWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.node.htmlContent != widget.node.htmlContent) {
      _loadContent();
    }
  }

  void _initWebView() async {
    if (!kIsWeb && Platform.isWindows) {
      _windowsController = ww.WebviewController();
      try {
        await _windowsController!.initialize();
        if (mounted) {
          setState(() {
            _isWindowsReady = true;
          });
          _loadContent();
        }
      } catch (e) {
        debugPrint('Failed to initialize webview_windows: $e');
      }
    } else {
      _flutterController = wf.WebViewController()
        ..setJavaScriptMode(wf.JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent);
      _loadContent();
    }
  }

  void _loadContent() {
    String html = widget.node.htmlContent;
    if (!html.toLowerCase().contains('<html')) {
      html = '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<style>
  body { margin: 0; padding: 0; background-color: transparent; overflow: hidden; }
</style>
</head>
<body>
\$html
</body>
</html>
''';
    }

    if (!kIsWeb && Platform.isWindows) {
      if (_isWindowsReady && _windowsController != null) {
        _windowsController!.setBackgroundColor(Colors.transparent);
        _windowsController!.loadStringContent(html);
      }
    } else {
      if (_flutterController != null) {
        _flutterController!.loadHtmlString(html);
      }
    }
  }

  @override
  void dispose() {
    _windowsController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && Platform.isWindows) {
      if (!_isWindowsReady) {
        return Container(
          color: widget.node.backgroundColor,
          child: const Center(child: CircularProgressIndicator()),
        );
      }
      return Container(
        color: widget.node.backgroundColor,
        child: ww.Webview(_windowsController!),
      );
    } else {
      if (_flutterController == null) {
        return Container(
          color: widget.node.backgroundColor,
          child: const Center(child: CircularProgressIndicator()),
        );
      }
      return Container(
        color: widget.node.backgroundColor,
        child: wf.WebViewWidget(controller: _flutterController!),
      );
    }
  }
}
