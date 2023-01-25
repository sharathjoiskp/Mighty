import 'package:flutter/material.dart';
import 'package:mightystore/app_localizations.dart';
import 'package:mightystore/screen/DashBoardScreen.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/common.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:mightystore/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import 'AppBarWidget.dart';

class ChooseDashboardPageVariant extends StatefulWidget {
  static String tag = '/ChooseDashboardScreen';

  @override
  ChooseDashboardPageVariantState createState() => ChooseDashboardPageVariantState();
}

class ChooseDashboardPageVariantState extends State<ChooseDashboardPageVariant> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    setDynamicStatusBarColor();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    return SafeArea(
      top: !isIos ? true : false,
      child: Scaffold(
        appBar:  mTop(context,  appLocalization.translate('choose_dashboard_page_variant')!, showBack: true, actions: [
          Image.asset(ic_home, height: 20, width: 20, color: white).onTap((){
            DashBoardScreen().launch(context, isNewTask: true);
          }).paddingRight(12)
        ],) as PreferredSizeWidget?,
        body: BodyCornerWidget(
          child: Container(
            child: SingleChildScrollView(
              child: Wrap(
                runSpacing: 8,
                spacing: 8,
                children: [
                  itemWidget(
                    title: '${appLocalization.translate('variant')} 1',
                    code: 1,
                    onTap: () async {
                      await setValue(DASHBOARD_PAGE_VARIANT, 1);
                      setState(() {});
                    },
                  ),
                  itemWidget(
                    title: '${appLocalization.translate('variant')} 2',
                    code: 2,
                    onTap: () async {
                      await setValue(DASHBOARD_PAGE_VARIANT, 2);
                      setState(() {});
                    },
                  ),
                  itemWidget(
                    title: '${appLocalization.translate('variant')} 3',
                    code: 3,
                    onTap: () async {
                      await setValue(DASHBOARD_PAGE_VARIANT, 3);
                      setState(() {});
                    },
                  ),
                ],
              ).center(),
            ),
          ),
        ),
      ),
    );
  }

  Widget itemWidget({required Function onTap, String? title, int code = 1, String? img}) {
    return Container(
      width: context.width() * 0.46,
      height: context.height() * 0.4,
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        borderRadius: radius(8),
        border: Border.all(color: getIntAsync(DASHBOARD_PAGE_VARIANT, defaultValue: 1) == code ? primaryColor! : Theme.of(context).dividerColor),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("images/mightystore/dashBoard$code.jpg", fit: BoxFit.cover, alignment: Alignment.topCenter).cornerRadiusWithClipRRect(8),
          AnimatedContainer(
            duration: Duration(milliseconds: 800),
            color: getIntAsync(DASHBOARD_PAGE_VARIANT, defaultValue: 1) == code ? transparentColor : Colors.black45,
          ).cornerRadiusWithClipRRect(8),
          AnimatedContainer(
            duration: Duration(milliseconds: 800),
            child: Text(title.validate(), style: boldTextStyle(color: getIntAsync(DASHBOARD_PAGE_VARIANT, defaultValue: 1) == code ? white : textPrimaryColor)),
            decoration: BoxDecoration(color: getIntAsync(DASHBOARD_PAGE_VARIANT, defaultValue: 1) == code ? Colors.black.withOpacity(0.5) : Colors.grey, borderRadius: radius(defaultRadius)),
            padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
          ).center(),
          Positioned(
            bottom: 8,
            right: 8,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 800),
              padding: EdgeInsets.all(4),
              child: Icon(Icons.check, size: 18, color: white),
              decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle, boxShadow: defaultBoxShadow()),
            ).visible(getIntAsync(DASHBOARD_PAGE_VARIANT, defaultValue: 1) == code),
          ),
        ],
      ),
    ).onTap(
      () {
        onTap.call();
        setDynamicStatusBarColor();
      },
    );
  }
}
