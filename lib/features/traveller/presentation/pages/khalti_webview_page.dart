import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KhaltiWebviewPage extends StatefulWidget {
  final String paymentUrl;
  final String returnUrl; // e.g. https://yourapp.com/payment/callback
  const KhaltiWebviewPage({super.key, required this.paymentUrl, required this.returnUrl});

  @override
  State<KhaltiWebviewPage> createState() => _KhaltiWebviewPageState();
}

class _KhaltiWebviewPageState extends State<KhaltiWebviewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            // Check for return URL
            if (url.startsWith(widget.returnUrl)) {
              Navigator.of(context).pop(url); // Pass the final URL back
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khalti Payment'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
