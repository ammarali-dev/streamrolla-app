import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            // Inject JS to force popups/new tabs to open in current window
            _controller.runJavaScript(
              "window.open = function(url) { window.location.href = url; }; " +
              "document.addEventListener('click', function(e) { " +
              "  var target = e.target; " +
              "  while (target && target.tagName !== 'A') { " +
              "    target = target.parentElement; " +
              "  } " +
              "  if (target && target.target === '_blank') { " +
              "    target.target = '_self'; " +
              "  } " +
              "}, true);"
            );
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..setUserAgent("Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36")
      ..loadRequest(Uri.parse('http://streamrolla.duckdns.org/'));
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          // This allows closing the app if no history is available
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(

        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await _controller.reload();
            },
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
