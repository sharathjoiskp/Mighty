import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:mightystore/main.dart';

import 'package:mightystore/utils/constants.dart';
import 'package:mightystore/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';


Widget mDashBoard2Progress() {
  return Container(
    alignment: Alignment.center,
    child: Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 4,
      margin: EdgeInsets.all(4),
      shape: RoundedRectangleBorder(borderRadius: radius(50)),
      child: Container(
        width: 45,
        height: 45,
        padding: EdgeInsets.all(8.0),
        child: Theme(
          data: ThemeData(accentColor: primaryColor),
          child: CircularProgressIndicator(
            strokeWidth: 3,
          ),
        ),
      ),
    ),
  );
}

Function(BuildContext, String) placeholderWidgetFn() => (_, s) => placeholderWidget();

Widget placeholderWidget() => Image.asset(ic_placeHolder, fit: BoxFit.cover);

Widget commonCacheImageDashBoard2Widget(String? url, {double? width, BoxFit? fit, double? height}) {
  if (url.validate().startsWith('https')) {
    if (isMobile) {
      return CachedNetworkImage(
        placeholder: placeholderWidgetFn() as Widget Function(BuildContext, String)?,
        imageUrl: '$url',
        height: height,
        width: width,
        fit: fit,
      );
    } else {
      return Image.network(url!, height: height, width: width, fit: fit);
    }
  } else {
    return Image.asset(url!, height: height, width: width, fit: fit);
  }
}

class CustomTheme extends StatelessWidget {
  final Widget? child;

  CustomTheme({this.child});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: appStore.isDarkModeOn ? ThemeData.dark().copyWith(accentColor: primaryColor, backgroundColor: Theme.of(context).scaffoldBackgroundColor) : ThemeData.light(),
      child: child!,
    );
  }
}

Widget viewAll(BuildContext context, {String? viewAll}) {
  return GestureDetector(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add, size: 18),
        4.width,
        Text(viewAll!, style: secondaryTextStyle()).paddingOnly(bottom: 8),
      ],
    ),
  );
}
