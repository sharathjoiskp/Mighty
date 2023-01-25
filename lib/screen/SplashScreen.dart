import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mightystore/app_localizations.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/screen/DashBoardScreen.dart';
import 'package:mightystore/screen/ProductDetailScreen/ProductDetailScreen.dart';
import 'package:mightystore/utils/common.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:mightystore/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import 'ProductDetailScreen/ProductDetailScreen2.dart';
import 'ProductDetailScreen/ProductDetailScreen3.dart';
import 'WalkThroughScreen.dart';

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(primaryColor!, statusBarIconBrightness: Brightness.light, statusBarBrightness: Brightness.dark);
    await Future.delayed(Duration(seconds: 2));

    int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
    if (themeModeIndex == ThemeModeSystem) {
      appStore.setDarkMode(aIsDarkMode: MediaQuery.of(context).platformBrightness == Brightness.dark);
    } else if (themeModeIndex == ThemeModeLight) {
      appStore.setDarkMode(aIsDarkMode: false);
    } else if (themeModeIndex == ThemeModeDark) {
      appStore.setDarkMode(aIsDarkMode: true);
    }

    String productId = await getProductIdFromNative();
    print(productId);

    if (productId.isNotEmpty) {
      if (getIntAsync(PRODUCT_DETAIL_VARIANT, defaultValue: 1) == 1) {
        ProductDetailScreen(mProId: productId.toInt()).launch(context);
      } else if (getIntAsync(PRODUCT_DETAIL_VARIANT, defaultValue: 1) == 2) {
        ProductDetailScreen2(mProId: productId.toInt()).launch(context);
      } else if (getIntAsync(PRODUCT_DETAIL_VARIANT, defaultValue: 1) == 3) {
        ProductDetailScreen3(mProId: productId.toInt()).launch(context);
      } else {
        ProductDetailScreen(mProId: productId.toInt()).launch(context);
      }
    } else {
      checkFirstSeen();
    }
  }

  Future checkFirstSeen() async {
    bool _seen = (getBoolAsync('seen', defaultValue: false));
    if (_seen) {
      DashBoardScreen().launch(context, isNewTask: true);
    } else {
      await setValue('seen', true);
      WalkThroughScreen().launch(context, isNewTask: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var appLocalization = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(splash, width: width * 0.65, height: 200, fit: BoxFit.cover),
          Text(
            appLocalization.translate('app_name')!,
            style: boldTextStyle(
              color: Theme.of(context).textTheme.subtitle2!.color,
              size: 26,
            ),
          ),
        ],
      ).center(),
    );
  }
}
