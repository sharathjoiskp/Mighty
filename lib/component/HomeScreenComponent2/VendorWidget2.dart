import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mightystore/models/ProductResponse.dart';
import 'package:mightystore/screen/VendorListScreen.dart';
import 'package:mightystore/screen/VendorProfileScreen.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import 'DashBoard2app_Widget.dart';

Widget getVendorDashBoard2Widget(VendorResponse vendor, BuildContext context, {double width = 260}) {
  String img = vendor.shop!.banner!.isNotEmpty ? vendor.shop!.banner!.validate() : '';

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
    decoration: boxDecorationWithRoundedCorners(borderRadius: BorderRadius.circular(16)),
    margin: EdgeInsets.all(8.0),
    child: Stack(
    clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: commonCacheImageWidget(img, height: 150, width: width, fit: BoxFit.fill),
        ),
        Positioned(
          bottom: -50,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            width: 245,
            padding: EdgeInsets.only(left: 16, right: 8, bottom: 4),
            decoration: boxDecorationRoundedWithShadow(8, blurRadius: 0.3, spreadRadius: 0.2, shadowColor: gray.withOpacity(0.3), backgroundColor: Theme.of(context).cardTheme.color!),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                spacing_control.height,
                Text(vendor.shop!.title!, style: boldTextStyle()),
                spacing_control.height,
                Text(addressText!, maxLines: 2, style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1!.color)),
              ],
            ),
          ),
        )
      ],
    ),
  );
}

Widget vendorDashBoard2List(List<VendorResponse> product) {
  return Container(
    height: 220,
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
              getVendorDashBoard2Widget(product[i], context),
            ],
          ),
        );
      },
    ),
  );
}

Widget mVendorDashBoard2Widget(BuildContext context, List<VendorResponse> mVendorModel, var title, var all, {size: textSizeMedium}) {
  return mVendorModel.isNotEmpty
      ? Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(height: 1.5, width: 24, color: context.iconColor),
          8.width,
          Text(title, style: GoogleFonts.alata(fontSize: 24, color: context.iconColor)),
          8.width,
          Container(height: 1.5, width: 24, color: context.iconColor),
        ],
      ).paddingOnly(left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble()).visible(mVendorModel.isNotEmpty),
      8.height,
      viewAll(context, viewAll: all).onTap(() {
        VendorListScreen().launch(context);
      }),
      vendorDashBoard2List(mVendorModel)
    ],
  )
      : SizedBox();
}
