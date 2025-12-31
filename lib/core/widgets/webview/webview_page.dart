import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final AppBar? appBar;
  final Future<bool> Function()? onWillPop;
  final Map<String, String>? headers;

  const WebViewPage({
    Key? key,
    required this.url,
    this.onWillPop, this.appBar, this.headers,
  }) : super(key: key);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool isValidUrl = true; // 👈 متغير لتحديد صلاحية الرابط

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final url = widget.url.trim();

    if (!url.startsWith("http://") && !url.startsWith("https://")) {
      setState(() => isValidUrl = false);
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(url),
        headers: widget.headers ?? {}, // ✅ هنا تبعت الهيدر مباشرة
      );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: widget.onWillPop ??
              () async {
            if (isValidUrl && await _controller.canGoBack()) {
              _controller.goBack();
              return false;
            }
            return true;
          },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: widget.appBar,
        body: SafeArea(
          child: isValidUrl
              ? WebViewWidget(controller: _controller)
              : _buildInvalidUrlWidget(),
        ),
      ),
    );
  }

  // 👇 ودجت بتظهر لو الرابط غير صالح
  Widget _buildInvalidUrlWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.error_outline, color: Colors.red, size: 60),
          SizedBox(height: 10),
          Text(
            "الرابط غير صالح ❌",
            style: TextStyle(fontSize: 18, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}