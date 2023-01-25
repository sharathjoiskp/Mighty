import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mightystore/component/Product.dart';
import 'package:mightystore/models/ProductResponse.dart';
import 'package:mightystore/network/rest_apis.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/colors.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';
import 'AppBarWidget.dart';

class VendorProfileScreen extends StatefulWidget {
  static String tag = '/VendorProfileScreen';
  var mVendorId;

  VendorProfileScreen({Key? key, this.mVendorId}) : super(key: key);

  @override
  _VendorProfileScreenState createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  VendorResponse? mVendorModel;
  List<ProductResponse> mVendorProductList = [];
  bool isLoading = false;
  String mErrorMsg = '';

  @override
  void initState() {
    super.initState();
    log(widget.mVendorId.toString());
    fetchVendorProfile();
    fetchVendorProduct();
  }

  Future fetchVendorProfile() async {
    setState(() {
      isLoading = true;
    });
    await getVendorProfile(widget.mVendorId).then((res) {
      if (!mounted) return;
      VendorResponse methodResponse = VendorResponse.fromJson(res);
      setState(() {
        isLoading = false;
        mVendorModel = methodResponse;
        mErrorMsg = '';
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        mErrorMsg = 'No Products';
      });
    });
  }

  Future fetchVendorProduct() async {
    setState(() {
      isLoading = true;
    });
    await getVendorProduct(widget.mVendorId).then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        mErrorMsg = '';
        Iterable list = res;
        mVendorProductList = list.map((model) => ProductResponse.fromJson(model)).toList();
      });
    }).catchError(
      (error) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          mErrorMsg = 'No Products';
        });
      },
    );
  }

  Widget mOption(var value, var color, {maxLine = 1}) {
    return Text(
      value,
      style: primaryTextStyle(color: color),
      maxLines: maxLine,
    ).paddingOnly(left: 10, right: 16);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);
    String? addressText = "";

    if (mVendorModel != null) {
      if (mVendorModel!.address != null) {
        if (mVendorModel!.address!.address1!.isNotEmpty && addressText.isEmpty) {
          addressText = mVendorModel!.address!.address1;
        }
        if (mVendorModel!.address!.address2!.isNotEmpty) {
          if (addressText!.isEmpty) {
            addressText = mVendorModel!.address!.address2;
          } else {
            addressText += ", " + mVendorModel!.address!.address2!;
          }
        }

        if (mVendorModel!.address!.city!.isNotEmpty) {
          if (addressText!.isEmpty) {
            addressText = mVendorModel!.address!.city;
          } else {
            addressText += ", " + mVendorModel!.address!.city!;
          }
        }
        if (mVendorModel!.address!.postcode!.isNotEmpty) {
          if (addressText!.isEmpty) {
            addressText = mVendorModel!.address!.postcode;
          } else {
            addressText += " - " + mVendorModel!.address!.postcode!;
          }
        }
        if (mVendorModel!.address!.state!.isNotEmpty) {
          if (addressText!.isEmpty) {
            addressText = mVendorModel!.address!.state;
          } else {
            addressText += ", " + mVendorModel!.address!.state!;
          }
        }
        if (mVendorModel!.address!.country!.isNotEmpty) {
          if (addressText!.isEmpty) {
            addressText = mVendorModel!.address!.country;
          } else {
            addressText += ", " + mVendorModel!.address!.country!;
          }
        }
      }
    }

    final body = mVendorModel != null
        ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                mVendorModel!.shop!.banner!.isNotEmpty
                    ? Container(
                        height: 200,
                        decoration: BoxDecoration(
                          image: DecorationImage(fit: BoxFit.cover, image: CachedNetworkImageProvider(mVendorModel!.shop!.banner.validate())),
                        ),
                      ).cornerRadiusWithClipRRect(10).paddingAll(12)
                    : Container(
                        decoration: boxDecorationWithRoundedCorners(backgroundColor: Colors.grey.shade300, borderRadius: radius(10)), margin: EdgeInsets.all(10), height: 200, width: context.width()),
                Text(mVendorModel!.shop!.title != null ? mVendorModel!.shop!.title! : '', style: boldTextStyle(size: textSizeNormal))
                    .paddingOnly(left: 10, right: 16)
                    .visible(mVendorModel!.shop!.title!.isNotEmpty),
                6.height.visible(mVendorModel!.address!.phone != null),
                mOption(mVendorModel!.address!.phone != null ? mVendorModel!.address!.phone : '', Theme.of(context).textTheme.subtitle1!.color).visible(!mVendorModel!.address!.phone.isEmptyOrNull),
                6.height.visible(addressText!.isNotEmpty),
                mOption(addressText, Theme.of(context).textTheme.subtitle1!.color, maxLine: 3).visible(addressText.isNotEmpty),
                6.height.visible(addressText.isNotEmpty),
                Divider(color: view_color, thickness: 4),
                10.height,
                Text(appLocalization!.translate('lbl_product_list')!, style: boldTextStyle()).paddingLeft(12).visible(mVendorProductList.isNotEmpty),
                mVendorProductList.isNotEmpty
                    ? StaggeredGridView.countBuilder(
                        scrollDirection: Axis.vertical,
                        itemCount: mVendorProductList.length,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.only(left: 4, right: 8, top: 8, bottom: 8),
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        staggeredTileBuilder: (index) {
                          return StaggeredTile.fit(1);
                        },
                        itemBuilder: (context, index) {
                          return Product(mProductModel: mVendorProductList[index]);
                        },
                      )
                    : Text(appLocalization.translate('lbl_data_not_found')!, style: boldTextStyle()).paddingOnly(left: 4, right: 8)
              ],
            ),
          )
        : SizedBox();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: mTop(context, mVendorModel != null ? mVendorModel!.shop!.title : ' ', showBack: true) as PreferredSizeWidget?,
        body: BodyCornerWidget(
          child: mInternetConnection(
            Stack(
              children: <Widget>[
                body.visible(mVendorModel != null),
                Center(child: mProgress()).visible(isLoading),
                Text(mErrorMsg.validate(), style: boldTextStyle(size: 20, color: Theme.of(context).textTheme.subtitle1!.color)).center().visible(mErrorMsg.isNotEmpty),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
