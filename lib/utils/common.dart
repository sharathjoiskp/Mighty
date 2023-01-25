import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:mightystore/app_localizations.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/screen/DashBoardScreen.dart';
import 'package:mightystore/screen/MyCartScreen.dart';
import 'package:mightystore/screen/SignInScreen.dart';
import 'package:mightystore/utils/admob_utils.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/shared_pref.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';

String convertDate(date) {
  try {
    return date != null ? DateFormat(orderDateFormat).format(DateTime.parse(date)) : '';
  } catch (e) {
    log(e);
    return '';
  }
}

String createDateFormat(date) {
  try {
    return date != null ? DateFormat(CreateDateFormat).format(DateTime.parse(date)) : '';
  } catch (e) {
    log(e);
    return '';
  }
}

String reviewConvertDate(date) {
  try {
    return date != null ? DateFormat(reviewDateFormat).format(DateTime.parse(date)) : '';
  } catch (e) {
    log(e);
    return '';
  }
}

void redirectUrl(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    toast('Please check URL');
    throw 'Could not launch $url';
  }
}

Future<bool> checkLogin(context) async {
  if (!await isLoggedIn()) {
    SignInScreen().launch(context);
    return false;
  } else {
    return true;
  }
}

Future logout(BuildContext context) async {
  ConfirmAction? res = await showConfirmDialogs(context, AppLocalizations.of(context)!.translate('lbl_logout'), AppLocalizations.of(context)!.translate('lbl_yes'), AppLocalizations.of(context)!.translate('lbl_cancel'));
  if (res == ConfirmAction.ACCEPT) {
    var primaryColor = getStringAsync(THEME_COLOR);
    await setValue(THEME_COLOR, primaryColor);

    await removeKey(PROFILE_IMAGE);
    await removeKey(BILLING);
    await removeKey(SHIPPING);
    await removeKey(USERNAME);
    if (getBoolAsync(IS_SOCIAL_LOGIN) || !getBoolAsync(IS_REMEMBERED)) {
      await removeKey(PASSWORD);
      await removeKey(USER_EMAIL);
    }
    await removeKey(FIRST_NAME);
    await removeKey(FIRST_NAME);
    await removeKey(LAST_NAME);
    await removeKey(TOKEN);
    await removeKey(USER_DISPLAY_NAME);
    await removeKey(USER_ID);
    await removeKey(AVATAR);
    await removeKey(COUNTRIES);
    await removeKey(CART_DATA);
    await removeKey(WISH_LIST_DATA);
    await removeKey(GUEST_USER_DATA);
    await removeKey(CARTCOUNT);
    await removeKey(DEFAULT_CURRENCY);
    await removeKey(CURRENCY_CODE);

    await setValue(IS_GUEST_USER, false);
    await setValue(IS_LOGGED_IN, false);
    await setValue(IS_SOCIAL_LOGIN, false);
    appStore.setCount(0);

    DashBoardScreen().launch(context, isNewTask: true);
  }
}

checkLoggedIn(context) async {
  var pref = await getSharedPref();
  if (pref.getBool(IS_LOGGED_IN) != null && pref.getBool(IS_LOGGED_IN)!) {
    MyCartScreen(isShowBack: true).launch(context);
  } else {
    SignInScreen().launch(context);
  }
}

String parseHtmlString(String? htmlString) {
  return parse(parse(htmlString).body!.text).documentElement!.text;
}

String durationFormatter(int milliSeconds) {
  int seconds = milliSeconds ~/ 1000;
  final int hours = seconds ~/ 3600;
  seconds = seconds % 3600;
  var minutes = seconds ~/ 60;
  seconds = seconds % 60;
  final hoursString = hours >= 10
      ? '$hours'
      : hours == 0
          ? '00'
          : '0$hours';
  final minutesString = minutes >= 10
      ? '$minutes'
      : minutes == 0
          ? '00'
          : '0$minutes';
  final secondsString = seconds >= 10
      ? '$seconds'
      : seconds == 0
          ? '00'
          : '0$seconds';
  final formattedTime = '${hoursString == '00' ? '' : hoursString + ':'}$minutesString:$secondsString';
  return formattedTime;
}

Future<String> getProductIdFromNative() async {
  const platform = const MethodChannel('getIdChannel');

  if (isMobile) {
    String? productId = await platform.invokeMethod('p');
    return productId.validate();
  } else {
    return '';
  }
}

BannerAd buildBannerAd() {
  return BannerAd(
    adUnitId: getBannerAdUnitId()!,
    size: AdSize.fullBanner,
    listener: BannerAdListener(onAdLoaded: (ad) {
      //
    }),
    request: AdRequest(),
  );
}

Color? getAppBarWidgetBackGroundColor() {
  if (getIntAsync(DASHBOARD_PAGE_VARIANT, defaultValue: 1) == 1) {
    return primaryColor!;
  } else if (getIntAsync(DASHBOARD_PAGE_VARIANT, defaultValue: 1) == 2 || getIntAsync(DASHBOARD_PAGE_VARIANT, defaultValue: 1) == 3) {
    return primaryColor!;
  } else {
    return primaryColor!;
  }
}

Future<void> setDynamicStatusBarColor({Color? color, int milliseconds = 100}) async {
  if (getIntAsync(DASHBOARD_PAGE_VARIANT, defaultValue: 1) == 1) {
    setStatusBarColor(color ?? primaryColor! /*, statusBarIconBrightness: Brightness.light*/, delayInMilliSeconds: milliseconds);
  } else if (getIntAsync(DASHBOARD_PAGE_VARIANT, defaultValue: 1) == 2 || getIntAsync(DASHBOARD_PAGE_VARIANT, defaultValue: 1) == 3) {
    setStatusBarColor(color ??  primaryColor! /*, statusBarIconBrightness: appStore.isDarkMode ? Brightness.light : Brightness.dark*/,
        delayInMilliSeconds: milliseconds);
  }
}

Color getAppBarWidgetTextColor() {
  if (getIntAsync(DASHBOARD_PAGE_VARIANT, defaultValue: 1) == 1) {
    return appStore.isDarkMode! ? white : white;
  } else if (getIntAsync(DASHBOARD_PAGE_VARIANT, defaultValue: 1) == 2 || getIntAsync(DASHBOARD_PAGE_VARIANT, defaultValue: 1) == 3) {
    return appStore.isDarkMode! ? white : black;
  } else {
    return appStore.isDarkMode! ? white : black;
  }
}
