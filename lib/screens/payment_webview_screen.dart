import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/providers/reservation_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String url;

  const PaymentWebViewScreen({super.key, required this.url});

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            _checkUrlForStatus(url);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            _checkUrlForStatus(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _checkUrlForStatus(String url) {
    if (url.toLowerCase().contains('success')) {
      _finishPayment(true);
    } else if (url.toLowerCase().contains('cancel') || url.toLowerCase().contains('fail')) {
      _finishPayment(false);
    }
  }

  void _finishPayment(bool success) {
    if (!mounted) return;
    context.read<ReservationProvider>().handlePaymentResult(success);
    // Builder rebuilds the screen automatically based on handlePaymentResult changing the currentStep.
  }

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('reservation.cancel_payment'.tr()),
        content: Text('reservation.cancel_payment_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('reservation.no'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('reservation.yes_cancel'.tr()),
          ),
        ],
      ),
    );

    if (shouldPop == true) {
      _finishPayment(false);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop) {
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: theme.background,
        appBar: AppBar(
          backgroundColor: theme.primary,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () async {
              final shouldPop = await _onWillPop();
            },
          ),
          title: Text(
            'reservation.payment_secure'.tr(),
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              LinearProgressIndicator(color: theme.primary, backgroundColor: theme.primary.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }
}
