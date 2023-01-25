import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mightystore/models/ProductResponse.dart';
import 'package:mightystore/screen/VendorListScreen.dart';
import 'package:mightystore/screen/VendorProfileScreen.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:mightystore/utils/dashed_ract.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import 'DashBoard3app_Widget.dart';

Widget getVendorDashBoard3Widget(VendorResponse vendor, BuildContext context, {double width = 260}) {
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
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(border: Border.all(width: 0.1, color: appStore.isDarkMode! ? white : gray)),
    margin: EdgeInsets.symmetric(horizontal: 4),
    child: Row(
      children: [
        CachedNetworkImage(imageUrl: img, fit: BoxFit.cover, height: 200, width: context.width() * 0.4),
        Container(
          height: 190,
          width: context.width() * 0.4,
          padding: EdgeInsets.only(left: 8, right: 10),
          decoration: boxDecorationWithShadow(backgroundColor: Theme.of(context).cardTheme.color!),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              spacing_control.height,
              Text(vendor.shop!.title!, style: boldTextStyle()),
              spacing_control.height,
              Text(addressText!, maxLines: 3, overflow: TextOverflow.ellipsis, style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle1!.color)),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget vendorDashBoard3List(List<VendorResponse> product) {
  return Container(
    height: 240,
    alignment: Alignment.centerLeft,
    child: ListView.builder(
      itemCount: product.length,
      padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, i) {
        return GestureDetector(
          onTap: () {
            VendorProfileScreen(mVendorId: product[i].id).launch(context);
          },
          child: Column(
            children: [
              getVendorDashBoard3Widget(product[i], context),
            ],
          ),
        );
      },
    ),
  );
}

Widget mVendorDashBoard3Widget(BuildContext context, List<VendorResponse> mVendorModel, var title, var all, {size: textSizeMedium}) {
  return mVendorModel.isNotEmpty
      ? Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(title, style: GoogleFonts.alata(fontSize: 23, color: context.iconColor)),
                4.height,
                SizedBox(width: context.width() * 0.22, child: DashedRect(gap: 3, color: context.iconColor)),
              ],
            ),
            4.height,
            viewAllNewDashBoard3(context, viewAll: all).onTap(() {
              VendorListScreen().launch(context);
            }),
            vendorDashBoard3List(mVendorModel)
          ],
        )
      : SizedBox();
}
