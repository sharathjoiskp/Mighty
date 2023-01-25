import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mightystore/app_localizations.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPaymentScreen extends StatefulWidget {
  static String tag = '/WebViewPaymentScreen';
  final String? checkoutUrl;

  WebViewPaymentScreen({this.checkoutUrl});

  @override
  WebViewPaymentScreenState createState() => WebViewPaymentScreenState();
}

class WebViewPaymentScreenState extends State<WebViewPaymentScreen> {
  bool mIsError = false;
  bool mIsLoading = false;

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: mTop(context, appLocalization.translate('title_payment'), showBack: true) as PreferredSizeWidget?,
        body: Stack(
          children: [
            WebView(
              initialUrl: widget.checkoutUrl,
              javascriptMode: JavascriptMode.unrestricted,
              gestureNavigationEnabled: true,
              onPageFinished: (String url) {
                if (mIsError) return;
                if (url.contains('checkout/order-received')) {
                  mIsLoading = true;
                  toast('Order placed successfully');
                  appStore.setCount(0);
                  Navigator.pop(context, true);
                } else {
                  mIsLoading = false;
                }
              },
              onWebResourceError: (s) {
                mIsError = true;
              },
            ),
            Center(child: mProgress()).visible(mIsLoading)
          ],
        ),
      ),
    );
  }
}
