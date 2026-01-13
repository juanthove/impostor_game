import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LegalWebViewScreen extends StatefulWidget {
  final String url;
  const LegalWebViewScreen({super.key, required this.url});

  @override
  State<LegalWebViewScreen> createState() => _LegalWebViewScreenState();
}

class _LegalWebViewScreenState extends State<LegalWebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // Crear el controller y configurar Javascript
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal'),
        backgroundColor: Colors.black,
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}
