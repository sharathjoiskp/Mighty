import 'package:flutter/material.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';
import '../main.dart';

class PaymentAcceptComponent extends StatefulWidget {
  final Function? onCall;

  PaymentAcceptComponent({this.onCall});

  @override
  _PaymentAcceptComponentState createState() => _PaymentAcceptComponentState();
}

class _PaymentAcceptComponentState extends State<PaymentAcceptComponent> {
  bool? isCheck = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
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
      backgroundColor: Colors.transparent,
      body: Container(
        height: context.height() * 0.21,
        margin: EdgeInsets.all(16),
        decoration: boxDecorationWithShadow(backgroundColor: context.cardColor, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(AppName + " " + appLocalization.translate("msg_accept_payment")!, style: boldTextStyle()).paddingAll(16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTheme(
                  child: Checkbox(
                    value: isCheck,
                    checkColor: white,
                    activeColor: primaryColor,
                    onChanged: (v) async {
                      log(v);
                      isCheck = v!;
                      setState(() {});
                    },
                  ),
                ),
                Text('I agree', style: secondaryTextStyle()),
                Icon(LineIcons.asterisk, color: Colors.red, size: 10),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    finish(context);
                  },
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(context.cardColor)),

                  child: Text(appLocalization.translate("lbl_cancel")!, style: primaryTextStyle()),
                ),
                16.width,
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(isCheck == true ? primaryColor : context.cardColor),
                  ),
                  onPressed: () {
                    if (isCheck == true) {
                      finish(context);
                      widget.onCall!();
                    }
                  },

                  child: Text(appLocalization.translate("btn_accept")!, style: primaryTextStyle(color: isCheck == true ? Colors.white : context.primaryColor)),
                ),
              ],
            ).paddingSymmetric(horizontal: 16)
          ],
        ),
      ).center(),
    );
  }
}
