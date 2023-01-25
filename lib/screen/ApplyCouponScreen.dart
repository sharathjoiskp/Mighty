import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/models/CouponResponse.dart';
import 'package:mightystore/network/rest_apis.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:mightystore/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share/share.dart';

import '../app_localizations.dart';

class ApplyCouponScreen extends StatefulWidget {
  static String tag = '/ApplyCouponScreen';

  @override
  ApplyCouponScreenState createState() => ApplyCouponScreenState();
}

class ApplyCouponScreenState extends State<ApplyCouponScreen> {
  List<CouponResponse>? mCouponModel;
  String errorMsg = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    init();
    fetchCouponData();
  }

  init() async {}

  Future fetchCouponData() async {
    setState(() {
      isLoading = true;
    });
    await getCouponList().then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        Iterable mCoupon = res;
        mCouponModel = mCoupon.map((model) => CouponResponse.fromJson(model)).toList();
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;
    Widget mCouponName(var text) {
      return Text(text, style: boldTextStyle());
    }

    Widget mCouponInfo(var text) {
      return Text(text, style: secondaryTextStyle());
    }

    Widget mCoupon = ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: mCouponModel!.length,
        itemBuilder: (context, i) {
          bool? isExpired;
          if (mCouponModel![i].dateExpires != null) {
            var now = new DateTime.now();
            final expirationDate = DateTime(now.year, now.month, now.day + 1);
            DateTime tempDate = new DateFormat("yyyy-MM-dd").parse(mCouponModel![i].dateExpires);
            isExpired = expirationDate.isAfter(tempDate);
          }

          return mCouponModel![i].dateExpires != null
              ? isExpired == false
                  ? Container(
                      padding: EdgeInsets.only(bottom: spacing_standard.toDouble()),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (mCouponModel![i].discountType == "percent")
                                mCouponName('Get ' + mCouponModel![i].amount.toString() + "% off")
                              else if (mCouponModel![i].discountType == "fixed_cart")
                                mCouponName('Get Flat ' + mCouponModel![i].amount.toString() + " off")
                              else if (mCouponModel![i].discountType == "fixed_product")
                                mCouponName('Get Flat ' + mCouponModel![i].amount + " off to all products")
                              else
                                mCouponName('Get ' + mCouponModel![i].amount + "off"),
                              IconButton(
                                icon: Icon(Icons.share, color: Theme.of(context).iconTheme.color),
                                onPressed: () {
                                  Share.share('Apply Coupon Code: ' + mCouponModel![i].code + "\n\nDownload app from here: https://play.google.com/store/apps/details?id=");
                                },
                              ),
                            ],
                          ),
                          Text(mCouponModel![i].description, style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle2!.color, size: textSizeMedium)),
                          2.height,
                          if (double.parse(mCouponModel![i].minimumAmount) > 0.0)
                            mCouponInfo("Valid only orders of " + mCouponModel![i].amount.toString() + " and above.")
                          else if (double.parse(mCouponModel![i].maximumAmount) > 0.0)
                            mCouponInfo("\nMaximum bill amount is " + mCouponModel![i].maximumAmount)
                          else
                            mCouponModel![i].usageLimit != null
                                ? mCouponModel![i].usageLimit > 0
                                    ? mCouponInfo("Valid only for first " + mCouponModel![i].usageLimit.toString() + " users.")
                                    : SizedBox()
                                : mCouponInfo("No Minimum order value needed."),
                          8.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DottedBorder(
                                borderType: BorderType.RRect,
                                dashPattern: [6, 3, 6, 3],
                                color: primaryColor!,
                                radius: Radius.circular(6),
                                child: FittedBox(
                                  child: Container(
                                      color: primaryColor!.withOpacity(0.15), child: Center(child: Text(mCouponModel![i].code, style: secondaryTextStyle(color: primaryColor, size: textSizeSMedium))).paddingAll(6)),
                                ),
                              ),
                              Text(appLocalization.translate('lbl_apply')!, style: primaryTextStyle(color: primaryColor)).onTap(() {
                                Navigator.pop(context, jsonEncode(mCouponModel![i].toJson()));
                              })
                            ],
                          ).paddingOnly(right: 16),
                          10.height,
                          Divider(thickness: 6, color: Theme.of(context).textTheme.headline4!.color),
                          10.height
                        ],
                      ).paddingOnly(left: 16),
                    )
                  : SizedBox()
              : SizedBox();
        });

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: mTop(context, appLocalization.translate("lbl_available_coupon"), showBack: true) as PreferredSizeWidget?,
        body: Stack(
          alignment: Alignment.center,
          children: [
            mCouponModel != null
                ? mCouponModel!.isNotEmpty
                    ? mCoupon
                    : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Image.asset(ic_shopping_cart, height: 80, width: 80, color: primaryColor),
                        20.height,
                        Text(
                          appLocalization.translate("lbl_no_other_coupon_available")!,
                          style: primaryTextStyle(size: 22),
                          textAlign: TextAlign.center,
                        ).paddingOnly(left: 20, right: 20)
                      ]).center().visible(!isLoading)
                : SizedBox(),
            Center(child: mProgress().visible(isLoading))
          ],
        ),
      ),
    );
  }
}
