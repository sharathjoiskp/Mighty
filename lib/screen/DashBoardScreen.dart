import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mightystore/app_localizations.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/screen/MyCartScreen.dart';
import 'package:mightystore/screen/ProfileScreen.dart';
import 'package:mightystore/screen/WishListScreen.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:mightystore/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import 'CategoriesScreen.dart';
import 'MyHomeScreen.dart';

class DashBoardScreen extends StatefulWidget {
  static String tag = '/DashBoardScreen1';

  @override
  DashBoardScreenState createState() => DashBoardScreenState();
}

class DashBoardScreenState extends State<DashBoardScreen> {
  int _currentIndex = 0;
  bool mIsLoggedIn = false;

  final tab = [
    MyHomeScreen(),
    CategoriesScreen(),
    MyCartScreen(isShowBack: false),
    WishListScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(primaryColor!);
    setState(() {
      mIsLoggedIn = getBoolAsync(IS_LOGGED_IN, defaultValue: false);
    });
    setValue(CARTCOUNT, appStore.count);

    window.onPlatformBrightnessChanged = () {
      if (getIntAsync(THEME_MODE_INDEX) == ThemeModeSystem) {
        appStore.setDarkMode(aIsDarkMode: MediaQuery.of(context).platformBrightness == Brightness.light);
      }
    };
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    window.onPlatformBrightnessChanged = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: tab[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Theme.of(context).appBarTheme.iconTheme!.color,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          showSelectedLabels: true,
          currentIndex: _currentIndex,
          unselectedItemColor: Theme.of(context).textTheme.subtitle1!.color,
          unselectedLabelStyle: TextStyle(color: Theme.of(context).textTheme.subtitle1!.color),
          selectedLabelStyle: TextStyle(color: primaryColor),
          selectedItemColor: primaryColor,
          items: [
            BottomNavigationBarItem(
                icon: Image.asset(ic_home, height: 20, width: 20, color: Theme.of(context).textTheme.subtitle1!.color),
                activeIcon: Image.asset(ic_home, height: 20, width: 20, color: primaryColor),
                label: appLocalization.translate("lbl_home")),
            BottomNavigationBarItem(
                icon: Image.asset(ic_category, height: 20, width: 20, color: Theme.of(context).textTheme.subtitle1!.color),
                activeIcon: Image.asset(ic_category, height: 20, width: 20, color: primaryColor),
                label: appLocalization.translate("lbl_category")),
            BottomNavigationBarItem(
                icon: Stack(
                  children: <Widget>[
                    Image.asset(ic_shopping_cart, height: 20, width: 20, color: Theme.of(context).textTheme.subtitle1!.color),
                    appStore.count! > 0 && appStore.count != null
                        ? Positioned(
                            top: 5,
                            left: 6,
                            child: Observer(
                              builder: (_) => CircleAvatar(
                                maxRadius: 7,
                                backgroundColor: Theme.of(context).textTheme.subtitle1!.color,
                                child: FittedBox(child: Text('${appStore.count}', style: secondaryTextStyle(color: white))),
                              ),
                            ),
                          ).visible(mIsLoggedIn || getBoolAsync(IS_GUEST_USER) == true)
                        : SizedBox()
                  ],
                ),
                activeIcon: Stack(children: <Widget>[
                  Image.asset(ic_shopping_cart, height: 20, width: 20, color: primaryColor),
                  if (appStore.count.toString() != "0")
                    Positioned(
                            top: 5,
                            left: 6,
                            child: Observer(
                                builder: (_) => CircleAvatar(maxRadius: 7, backgroundColor: primaryColor, child: FittedBox(child: Text('${appStore.count}', style: secondaryTextStyle(color: white))))))
                        .visible(mIsLoggedIn || getBoolAsync(IS_GUEST_USER) == true),
                ]),
                label: appLocalization.translate("lbl_basket")),
            BottomNavigationBarItem(
                icon: Image.asset(ic_heart, height: 20, width: 20, color: Theme.of(context).textTheme.subtitle1!.color),
                activeIcon: Image.asset(ic_heart, height: 20, width: 20, color: primaryColor),
                label: appLocalization.translate("lbl_favourite")),
            BottomNavigationBarItem(
                icon: Image.asset(ic_user, height: 20, width: 20, color: Theme.of(context).textTheme.subtitle1!.color),
                activeIcon: Image.asset(ic_user, height: 20, width: 20, color: primaryColor),
                label: appLocalization.translate("lbl_account"))
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
