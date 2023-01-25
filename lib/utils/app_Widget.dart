import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mightystore/app_localizations.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/models/ProductResponse.dart';
import 'package:mightystore/screen/DashBoardScreen.dart';
import 'package:mightystore/screen/NoInternetScreen.dart';
import 'package:mightystore/screen/VendorListScreen.dart';
import 'package:mightystore/screen/VendorProfileScreen.dart';
import 'package:mightystore/utils/colors.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:mightystore/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_view/photo_view.dart';

import 'colors.dart';
import 'common.dart';

// ignore: must_be_immutable
class EditText extends StatefulWidget {
  var isPassword;
  var hintText;
  var isSecure;
  int fontSize;
  var textColor;
  var fontFamily;
  var text;
  var maxLine;
  Function? validator;
  Function? onChanged;
  TextEditingController? mController;
  VoidCallback? onPressed;

  EditText({
    var this.fontSize = 16,
    var this.textColor = textColorSecondary,
    var this.hintText = '',
    var this.isPassword = true,
    var this.isSecure = false,
    var this.text = "",
    this.onChanged,
    this.validator,
    var this.mController,
    var this.maxLine = 1,
  });

  @override
  State<StatefulWidget> createState() {
    return EditTextState();
  }
}

class EditTextState extends State<EditText> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isSecure) {
      return TextFormField(
        controller: widget.mController,
        obscureText: widget.isPassword,
        cursorColor: primaryColor,
        maxLines: widget.maxLine,
        style: TextStyle(fontSize: widget.fontSize.toDouble(), color: Theme.of(context).textTheme.subtitle1!.color, fontFamily: widget.fontFamily),
        onChanged: widget.onChanged as void Function(String)?,
        validator: widget.validator as String? Function(String?)?,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20, 12, 4, 12),
          labelText: widget.hintText,
          labelStyle: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1!.color),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius(8),
            borderSide: BorderSide(color: Theme.of(context).textTheme.subtitle1!.color!, width: 0.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: radius(8),
            borderSide: BorderSide(color: Colors.red, width: 1.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: radius(8),
            borderSide: BorderSide(color: Colors.red, width: 1.0),
          ),
          errorMaxLines: 2,
          errorStyle: primaryTextStyle(color: Colors.red, size: 12),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius(8),
            borderSide: BorderSide(color: Theme.of(context).textTheme.subtitle1!.color!, width: 0.0),
          ),
        ),
      );
    } else {
      return TextFormField(
        controller: widget.mController,
        obscureText: widget.isPassword,
        cursorColor: primaryColor,
        validator: widget.validator as String? Function(String?)?,
        style: TextStyle(fontSize: widget.fontSize.toDouble(), color: Theme.of(context).textTheme.subtitle1!.color, fontFamily: widget.fontFamily),
        decoration: InputDecoration(
          suffixIcon: new GestureDetector(
            onTap: () {
              setState(() {
                widget.isPassword = !widget.isPassword;
              });
            },
            child: new Icon(
              widget.isPassword ? Icons.visibility : Icons.visibility_off,
              color: Theme.of(context).textTheme.subtitle1!.color,
            ),
          ),
          contentPadding: EdgeInsets.fromLTRB(20, 14, 4, 14),
          labelText: widget.hintText,
          labelStyle: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1!.color),
          // filled: true,
          // fillColor: Theme.of(context).textTheme.headline4.color,
          enabledBorder: OutlineInputBorder(
            borderRadius: radius(8),
            borderSide: BorderSide(color: Theme.of(context).textTheme.subtitle1!.color!, width: 0.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: radius(8),
            borderSide: BorderSide(color: Colors.red, width: 1.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: radius(8),
            borderSide: BorderSide(color: Colors.red, width: 1.0),
          ),
          errorMaxLines: 2,
          errorStyle: primaryTextStyle(color: Colors.red, size: 12),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius(8),
            borderSide: BorderSide(color: Theme.of(context).textTheme.subtitle1!.color!, width: 0.0),
          ),
        ),
      );
    }
  }
}

// ignore: must_be_immutable
class SimpleEditText extends StatefulWidget {
  bool isPassword;
  bool isSecure;
  int fontSize;
  var textColor;
  var fontFamily;
  var text;
  var maxLine;
  Function? validator;
  TextInputType? keyboardType;
  var hintText;

  TextEditingController? mController;

  VoidCallback? onPressed;

  SimpleEditText(
      {this.fontSize = textSizeNormal,
      this.textColor = textColorPrimary,
      this.isPassword = false,
      this.isSecure = true,
      this.text = '',
      this.mController,
      this.maxLine = 1,
      this.hintText = '',
      this.keyboardType,
      this.validator});

  @override
  State<StatefulWidget> createState() {
    return SimpleEditTextState();
  }
}

class SimpleEditTextState extends State<SimpleEditText> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.mController,
      obscureText: widget.isPassword,
      cursorColor: primaryColor!,
      validator: widget.validator as String? Function(String?)?,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20, 14, 4, 14),
        labelText: widget.hintText,
        labelStyle: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1!.color),
        // filled: true,
        // fillColor: Theme.of(context).textTheme.headline4.color,
        enabledBorder: OutlineInputBorder(
          borderRadius: radius(8),
          borderSide: BorderSide(color: Theme.of(context).textTheme.subtitle1!.color!, width: 0.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius(8),
          borderSide: BorderSide(color: Colors.red, width: 1.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius(8),
          borderSide: BorderSide(color: Colors.red, width: 1.0),
        ),
        errorMaxLines: 2,
        errorStyle: primaryTextStyle(color: Colors.red, size: 12),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius(8),
          borderSide: BorderSide(color: Theme.of(context).textTheme.subtitle1!.color!, width: 0.0),
        ),
      ),
    ).paddingBottom(16);
  }
}

enum ConfirmAction { CANCEL, ACCEPT }

Future<ConfirmAction?> showConfirmDialogs(context, msg, positiveText, negativeText) async {
  return showDialog<ConfirmAction>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: Text(msg, style: TextStyle(fontSize: 16, color: primaryColor)),
        actions: <Widget>[
          TextButton(
            child: Text(
              negativeText,
              style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1!.color),
            ),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.CANCEL);
            },
          ),
          TextButton(
            child: Text(
              positiveText,
              style: primaryTextStyle(color: primaryColor),
            ),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.ACCEPT);
            },
          )
        ],
      );
    },
  );
}

// ignore: must_be_immutable
class PriceWidget extends StatefulWidget {
  static String tag = '/PriceWidget';
  var price;
  double? size = 22.0;
  Color? color;
  var isLineThroughEnabled = false;

  PriceWidget({Key? key, this.price, this.color, this.size, this.isLineThroughEnabled = false}) : super(key: key);

  @override
  PriceWidgetState createState() => PriceWidgetState();
}

class PriceWidgetState extends State<PriceWidget> {
  var currency = '₹';
  Color? primaryColor;

  @override
  void initState() {
    super.initState();
    get();
  }

  get() async {
    if (getStringAsync(DEFAULT_CURRENCY) != null) {
      setState(() {
        currency = getStringAsync(DEFAULT_CURRENCY);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLineThroughEnabled) {
      return Text('$currency${widget.price.toString().replaceAll(".00", "")}', style: boldTextStyle(size: widget.size!.toInt(), color: widget.color != null ? widget.color : primaryColor));
    } else {
      return widget.price.toString().isNotEmpty
          ? Text('$currency${widget.price.toString().replaceAll(".00", "")}', style: TextStyle(fontSize: widget.size, color: widget.color ?? textPrimaryColor, decoration: TextDecoration.lineThrough))
          : Text('');
    }
  }
}

/*Widget noInternet(context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        MaterialCommunityIcons.wifi_off,
        size: 80,
      ),
      20.height,
      Text(AppLocalizations.of(context)!.translate('lbl_no_internet')!, style: boldTextStyle(size: 24, color: Theme.of(context).textTheme.subtitle2!.color)),
      4.height,
      Text(
        AppLocalizations.of(context)!.translate('lbl_no_internet_msg')!,
        style: secondaryTextStyle(size: 14, color: Theme.of(context).textTheme.subtitle1!.color),
        textAlign: TextAlign.center,
      ).paddingOnly(left: 20, right: 20),
    ],
  );
}*/

Widget getVendorWidget(VendorResponse vendor, BuildContext context, {double width = 300}) {
  String img = vendor.shop!.banner!.isNotEmpty ? vendor.shop!.banner.validate() : '';

  String? addressText = "";
  if (vendor.address != null) {
    if (vendor.address!.address1 != null) {
      if (vendor.address!.address1!.isNotEmpty && addressText.isEmpty) {
        addressText = vendor.address!.address1;
      }
    }
    if (vendor.address!.address2 != null) {
      if (vendor.address!.address2!.isNotEmpty) {
        if (addressText!.isEmpty) {
          addressText = vendor.address!.address2;
        } else {
          addressText += ", " + vendor.address!.address2!;
        }
      }
    }
    if (vendor.address!.city != null) {
      if (vendor.address!.city!.isNotEmpty) {
        if (addressText!.isEmpty) {
          addressText = vendor.address!.city;
        } else {
          addressText += ", " + vendor.address!.city!;
        }
      }
    }

    if (vendor.address!.postcode != null) {
      if (vendor.address!.postcode!.isNotEmpty) {
        if (addressText!.isEmpty) {
          addressText = vendor.address!.postcode;
        } else {
          addressText += " - " + vendor.address!.postcode!;
        }
      }
    }
    if (vendor.address!.state != null) {
      if (vendor.address!.state!.isNotEmpty) {
        if (addressText!.isEmpty) {
          addressText = vendor.address!.state;
        } else {
          addressText += ", " + vendor.address!.state!;
        }
      }
    }
    if (vendor.address!.country != null) {
      if (!vendor.address!.country!.isNotEmpty) {
        if (addressText!.isEmpty) {
          addressText = vendor.address!.country;
        } else {
          addressText += ", " + vendor.address!.country!;
        }
      }
    }
  }

  return Container(
    width: width,
    decoration: boxDecorationRoundedWithShadow(8, backgroundColor: Theme.of(context).cardTheme.color!),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        img.isEmptyOrNull
            ? Container(decoration: boxDecorationWithRoundedCorners(backgroundColor: Colors.grey.shade300, borderRadius: radiusOnly(topLeft: 10, topRight: 10)), height: 150, width: width)
            : ClipRRect(borderRadius: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10)), child: commonCacheImageWidget(img, height: 150, width: width, fit: BoxFit.cover)),
        Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(vendor.vendorProfile!), radius: 30),
            spacing_middle.width,
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(vendor.shop!.title!, style: boldTextStyle()),
                Text(addressText!, maxLines: 2, style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle1!.color)),
              ],
            ).expand(),
          ],
        ).paddingAll(8),
      ],
    ),
    margin: EdgeInsets.all(8.0),
  );
}

Widget vendorList(List<VendorResponse> product) {
  return Container(
    height: 255,
    alignment: Alignment.centerLeft,
    child: ListView.builder(
      itemCount: product.length,
      padding: EdgeInsets.only(left: 8, right: 8),
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, i) {
        return GestureDetector(
          onTap: () {
            VendorProfileScreen(mVendorId: product[i].id).launch(context);
          },
          child: Column(
            children: [
              getVendorWidget(product[i], context),
            ],
          ),
        );
      },
    ),
  );
}

Widget mVendorWidget(BuildContext context, List<VendorResponse> mVendorModel, var title, var all, {size: textSizeMedium}) {
  return mVendorModel.isNotEmpty
      ? Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: boldTextStyle(size: size)),
                Text(all, style: boldTextStyle(color: primaryColor)).onTap(() {
                  VendorListScreen().launch(context);
                })
              ],
            ).paddingOnly(left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble()).visible(mVendorModel.isNotEmpty),
            8.height,
            vendorList(mVendorModel)
          ],
        )
      : SizedBox();
}

Widget mCart(
  BuildContext context,
  bool mIsLoggedIn, {
  Color color = Colors.white,
}) {
  return Stack(
    alignment: Alignment.center,
    children: [
      Image.asset(ic_shopping_cart, height: 25, width: 25, color: white).onTap(() {
        checkLoggedIn(context);
      }).paddingRight(14),
      if (appStore.count.toString() != "0")
        Positioned(
          top: 8,
          right: 10,
          child: Observer(
            builder: (_) => CircleAvatar(
              maxRadius: 7,
              minRadius: 5,
              backgroundColor: color,
              child: FittedBox(child: Text('${appStore.count}', style: Theme.of(context).textTheme.headline3)),
            ),
          ),
        ).visible(mIsLoggedIn || getBoolAsync(IS_GUEST_USER, defaultValue: false) == true)
    ],
  );
}

Widget mTop(BuildContext context, var title, {List<Widget>? actions, bool showBack = false}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(60.0),
    child: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        leading: showBack
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: white),
                onPressed: () {
                  finish(context);
                },
              )
            : null,
        actions: actions,
        title: Text(title, style: boldTextStyle(color: Colors.white, size: 18)),
        automaticallyImplyLeading: false),
  );
}

Widget mTopNew(BuildContext context, var title, {List<Widget>? actions, bool showBack = false}) {
  return AppBar(
      elevation: 0,
      backgroundColor: primaryColor,
      leading: showBack
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: white),
              onPressed: () {
                finish(context);
              },
            )
          : null,
      actions: actions,
      title: Text(
        title,
        style: boldTextStyle(color: Colors.white, size: textSizeLargeMedium),
      ),
      automaticallyImplyLeading: false);
}

Widget mView(Widget widget, BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width,
    decoration:
        boxDecorationWithRoundedCorners(borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)), backgroundColor: Theme.of(context).scaffoldBackgroundColor),
    child: widget,
  );
}

class CustomShapeBorder extends ContinuousRectangleBorder {
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final double innerCircleRadius = 10.0;

    Path path = Path();
    path.lineTo(0, rect.height);
    path.quadraticBezierTo(rect.width / 2, rect.height + 15, rect.width / 2 - 75, rect.height + 50);
    path.cubicTo(rect.width / 2 - 0, rect.height + innerCircleRadius - 0, rect.width / 2 + 0, rect.height + innerCircleRadius - 0, rect.width / 2 + 75, rect.height + 50);
    path.quadraticBezierTo(rect.width / 2 + (innerCircleRadius / 2) + 30, rect.height + 15, rect.width, rect.height);
    path.lineTo(rect.width, 0.0);
    path.close();

    return path;
  }
}

Widget mProgress() {
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

Widget mSale(ProductResponse product) {
  return Positioned(
    left: 0,
    top: 0,
    child: Container(
      decoration: boxDecorationWithRoundedCorners(backgroundColor: Colors.red, borderRadius: radiusOnly(topLeft: 8)),
      child: Text("Sale", style: secondaryTextStyle(color: white, size: 12)),
      padding: EdgeInsets.fromLTRB(6, 2, 6, 2),
    ),
  ).visible(product.onSale == true);
}

Widget mSale3(ProductResponse product) {
  return Positioned(
    left: 0,
    top: 0,
    child: Container(
      decoration: boxDecorationWithRoundedCorners(backgroundColor: Colors.red, borderRadius: radius(0)),
      child: Text("Sale", style: secondaryTextStyle(color: white, size: 12)),
      padding: EdgeInsets.fromLTRB(6, 2, 6, 2),
    ),
  ).visible(product.onSale == true);
}

Function(BuildContext, String) placeholderWidgetFn() => (_, s) => placeholderWidget();

Widget placeholderWidget() => Image.asset(ic_placeHolder, fit: BoxFit.cover);

Widget commonCacheImageWidget(String? url, {double? width, BoxFit? fit, double? height}) {
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

class PinEntryTextField extends StatefulWidget {
  final String? lastPin;
  final int fields;
  final onSubmit;
  final fieldWidth;
  final fontSize;
  final isTextObscure;
  final showFieldAsBox;

  PinEntryTextField({this.lastPin, this.fields: 6, this.onSubmit, this.fieldWidth: 30.0, this.fontSize: 16.0, this.isTextObscure: false, this.showFieldAsBox: false}) : assert(fields > 0);

  @override
  State createState() {
    return PinEntryTextFieldState();
  }
}

class PinEntryTextFieldState extends State<PinEntryTextField> {
  late List<String?> _pin;
  late List<FocusNode?> _focusNodes;
  late List<TextEditingController?> _textControllers;

  Widget textfields = Container();

  @override
  void initState() {
    super.initState();
    // ignore: deprecated_member_use
    _pin = List<String?>.filled(widget.fields, null, growable: false);
    // ignore: deprecated_member_use
    _focusNodes = List<FocusNode?>.filled(widget.fields, null, growable: false);
    // ignore: deprecated_member_use
    _textControllers = List<TextEditingController?>.filled(widget.fields, null, growable: false);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        if (widget.lastPin != null) {
          for (var i = 0; i < widget.lastPin!.length; i++) {
            _pin[i] = widget.lastPin![i];
          }
        }
        textfields = generateTextFields(context);
      });
    });
  }

  @override
  void dispose() {
    _textControllers.forEach((TextEditingController? t) => t!.dispose());
    super.dispose();
  }

  Widget generateTextFields(BuildContext context) {
    List<Widget> textFields = List.generate(widget.fields, (int i) {
      return buildTextField(i, context);
    });

    if (_pin.first != null) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    }

    return Row(mainAxisAlignment: MainAxisAlignment.center, verticalDirection: VerticalDirection.down, children: textFields);
  }

  void clearTextFields() {
    _textControllers.forEach((TextEditingController? tEditController) => tEditController!.clear());
    _pin.clear();
  }

  Widget buildTextField(int i, BuildContext context) {
    if (_focusNodes[i] == null) {
      _focusNodes[i] = FocusNode();
    }
    if (_textControllers[i] == null) {
      _textControllers[i] = TextEditingController();
      if (widget.lastPin != null) {
        _textControllers[i]!.text = widget.lastPin![i];
      }
    }

    _focusNodes[i]!.addListener(() {
      if (_focusNodes[i]!.hasFocus) {}
    });

    final String lastDigit = _textControllers[i]!.text;

    return Container(
      width: widget.fieldWidth,
      margin: EdgeInsets.only(right: 10.0),
      child: TextField(
        controller: _textControllers[i],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: primaryTextStyle(),
        focusNode: _focusNodes[i],
        obscureText: widget.isTextObscure,
        decoration: InputDecoration(focusColor: primaryColor, counterText: "", border: widget.showFieldAsBox ? OutlineInputBorder(borderSide: BorderSide(width: 2.0)) : null),
        onChanged: (String str) {
          setState(() {
            _pin[i] = str;
          });
          if (i + 1 != widget.fields) {
            _focusNodes[i]!.unfocus();
            if (lastDigit != null && _pin[i] == '') {
              FocusScope.of(context).requestFocus(_focusNodes[i - 1]);
            } else {
              FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
            }
          } else {
            _focusNodes[i]!.unfocus();
            if (lastDigit != null && _pin[i] == '') {
              FocusScope.of(context).requestFocus(_focusNodes[i - 1]);
            }
          }
          if (_pin.every((String? digit) => digit != null && digit != '')) {
            widget.onSubmit(_pin.join());
          }
        },
        onSubmitted: (String str) {
          if (_pin.every((String? digit) => digit != null && digit != '')) {
            widget.onSubmit(_pin.join());
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return textfields;
  }
}

class CustomTheme extends StatelessWidget {
  final Widget? child;

  CustomTheme({this.child});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: appStore.isDarkModeOn
          ? ThemeData.dark().copyWith(
              accentColor: primaryColor,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            )
          : ThemeData.light(),
      child: child!,
    );
  }
}

void openPhotoViewer(context, ImageProvider imageProvider) {
  Scaffold(
    body: Stack(
      children: <Widget>[
        PhotoView(
          imageProvider: imageProvider,
          minScale: PhotoViewComputedScale.contained,
          maxScale: 1.0,
        ),
        Positioned(top: 35, left: 16, child: BackButton(color: Colors.white)),
      ],
    ),
  ).launch(context);
}

Widget mInternetConnection(Widget widget) {
  Stream connectivityStream = Connectivity().onConnectivityChanged;
  return StreamBuilder<ConnectivityResult>(
    stream: connectivityStream as Stream<ConnectivityResult>?,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final connectivityResult = snapshot.data;
        if (connectivityResult == ConnectivityResult.none) {
          return NoInternetScreen();
        }
        return widget;
      } else if (snapshot.hasError) {
        return NoInternetScreen();
      }
      return widget;
    },
  );
}

Future<void> setLogoutData(BuildContext context) async {
  if (getBoolAsync(IS_LOGGED_IN) == true) {
    var primaryColor = getStringAsync(THEME_COLOR);
    await setValue(THEME_COLOR, primaryColor);
    await removeKey(PROFILE_IMAGE);
    await removeKey(BILLING);
    await removeKey(SHIPPING);
    await removeKey(USERNAME);
    await removeKey(FIRST_NAME);
    await removeKey(FIRST_NAME);
    await removeKey(LAST_NAME);
    await removeKey(TOKEN);
    await removeKey(USER_DISPLAY_NAME);
    await removeKey(USER_ID);
    await removeKey(USER_EMAIL);
    await removeKey(AVATAR);
    await removeKey(COUNTRIES);
    await removeKey(CART_DATA);
    await removeKey(WISH_LIST_DATA);
    await removeKey(GUEST_USER_DATA);
    await removeKey(CARTCOUNT);
    await setValue(IS_GUEST_USER, false);
    await setValue(IS_LOGGED_IN, false);
    await setValue(IS_SOCIAL_LOGIN, false);
    appStore.setCount(0);
    DashBoardScreen().launch(context, isNewTask: true);
  } else {
    DashBoardScreen().launch(context, isNewTask: true);
  }
}
