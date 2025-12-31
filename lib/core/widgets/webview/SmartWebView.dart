import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SmartWebView extends StatefulWidget {
  final String url;
  final AppBar? appBar;
  final Map<String, String>? headers;
  final String? closeWhenUrlContains; // الكلمة اللي لما تظهر في الرابط يقفل الويبفيو
  final VoidCallback? onClose; // لما يقفل
  final dynamic Function(String url)? onCloseWithResult; // لما يقفل مع إرجاع result بناءً على الرابط
  final Future<bool> Function()? onWillPop; // للتحكم في زر الرجوع

  const SmartWebView({
    Key? key,
    required this.url,
    this.appBar,
    this.headers,
    this.closeWhenUrlContains,
    this.onClose,
    this.onCloseWithResult,
    this.onWillPop,
  }) : super(key: key);

  @override
  State<SmartWebView> createState() => _SmartWebViewState();
}

class _SmartWebViewState extends State<SmartWebView> {
  late final WebViewController _controller;
  bool isValidUrl = true;
  bool _isClosing = false; // لتجنب الإغلاق المزدوج

  @override
  void initState() {
    super.initState();
    initWebView();
  }

  void initWebView() {
    final url = widget.url.trim();

    if (!url.startsWith("http://") && !url.startsWith("https://")) {
      setState(() => isValidUrl = false);
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final currentUrl = request.url;
            print("🔍 WebView URL: $currentUrl");

            // التحقق من الرابط في onNavigationRequest أيضاً
            if (!_isClosing &&
                widget.closeWhenUrlContains != null &&
                currentUrl.contains(widget.closeWhenUrlContains!)) {
              print("📌 Trigger detected in onNavigationRequest → closing WebView...");
              _closeWebView(currentUrl);
              return NavigationDecision.prevent;
            }

            // السماح بتحميل الصفحة
            return NavigationDecision.navigate;
          },
          onPageFinished: (String url) {
            print("🔍 Page finished loading: $url");
            
            // التحقق من الرابط بعد تحميل الصفحة
            if (!_isClosing &&
                widget.closeWhenUrlContains != null &&
                url.contains(widget.closeWhenUrlContains!)) {
              print("📌 Trigger detected after page load → closing WebView...");
              _closeWebView(url);
            }
          },
        ),
      )
      ..loadRequest(
        Uri.parse(url),
        headers: widget.headers ?? {},
      );
  }

  void _closeWebView(String url) {
    if (_isClosing) {
      print("⚠️ Already closing, ignoring...");
      return; // تجنب الإغلاق المزدوج
    }
    _isClosing = true;
    print("🔄 Starting close process...");

    // إغلاق الويبفيو مباشرة
    Future.delayed(const Duration(milliseconds: 300), () {
      try {
        print("🚪 Attempting to close WebView...");
        // إذا كان هناك callback لإرجاع result
        if (widget.onCloseWithResult != null) {
          final result = widget.onCloseWithResult!(url);
          print("📤 Closing with result...");
          // إغلاق الويبفيو أولاً
          if (Get.context != null && Navigator.of(Get.context!).canPop()) {
            Navigator.of(Get.context!).pop(result);
            print("✅ Closed using Navigator.pop");
          } else {
            Get.back(result: result);
            print("✅ Closed using Get.back");
          }
          // استدعاء callback بعد تأخير صغير
          Future.delayed(const Duration(milliseconds: 200), () {
            widget.onClose?.call();
            print("✅ onClose callback executed");
          });
        } else {
          print("📤 Closing without result...");
          // إغلاق الويبفيو أولاً
          if (Get.context != null && Navigator.of(Get.context!).canPop()) {
            Navigator.of(Get.context!).pop();
            print("✅ Closed using Navigator.pop");
          } else {
            Get.back();
            print("✅ Closed using Get.back");
          }
          // استدعاء callback بعد تأخير صغير
          Future.delayed(const Duration(milliseconds: 200), () {
            widget.onClose?.call();
            print("✅ onClose callback executed");
          });
        }
      } catch (e) {
        print("❌ Error closing WebView: $e");
        // محاولة بديلة
        try {
          Get.back();
          print("✅ Closed using Get.back (fallback)");
          Future.delayed(const Duration(milliseconds: 200), () {
            widget.onClose?.call();
            print("✅ onClose callback executed (fallback)");
          });
        } catch (e2) {
          print("❌ Error with Get.back(): $e2");
        }
      }
    });
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
        appBar: widget.appBar,
        backgroundColor: Colors.white,

        body: SafeArea(
          child: isValidUrl
              ? WebViewWidget(controller: _controller)
              : invalidUrlWidget(),
        ),
      ),
    );
  }

  Widget invalidUrlWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.error, color: Colors.red, size: 60),
          SizedBox(height: 10),
          Text(
            "الرابط غير صالح ❌",
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
