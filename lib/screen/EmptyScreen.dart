import 'package:flutter/material.dart';
import 'package:mightystore/app_localizations.dart';
import 'package:mightystore/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class EmptyScreen extends StatefulWidget {
  static String tag = '/EmptyScreen';

  @override
  EmptyScreenState createState() => EmptyScreenState();
}

class EmptyScreenState extends State<EmptyScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Image.asset(ic_sad, height: 80, width: 80, fit: BoxFit.contain).paddingAll(16), Text(appLocalization.translate('lbl_data_not_found')!, style: boldTextStyle(size: 24)).paddingAll(16)],
      ).center(),
    );
  }
}
