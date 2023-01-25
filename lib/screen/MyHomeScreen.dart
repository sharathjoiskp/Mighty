import 'package:flutter/material.dart';
import 'package:mightystore/screen/HomeScreen/HomeScreen.dart';
import 'package:mightystore/screen/HomeScreen/HomeScreen3.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import 'HomeScreen/HomeScreen2.dart';

class MyHomeScreen extends StatefulWidget {
  @override
  MyHomeScreenState createState() => MyHomeScreenState();
}

class MyHomeScreenState extends State<MyHomeScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    if (getIntAsync(DASHBOARD_PAGE_VARIANT, defaultValue: 1) == 1) {
      return HomeScreen();
    } else if (getIntAsync(DASHBOARD_PAGE_VARIANT, defaultValue: 1) == 2) {
      return HomeScreen2();
    } else if (getIntAsync(DASHBOARD_PAGE_VARIANT, defaultValue: 1) == 3) {
      return HomeScreen3();
    } else {
      return HomeScreen();
    }
  }
}
