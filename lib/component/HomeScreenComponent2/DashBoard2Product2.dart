import 'package:flutter/material.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/models/ProductResponse.dart';
import 'package:mightystore/models/WishListResponse.dart';
import 'package:mightystore/network/rest_apis.dart';
import 'package:mightystore/screen/ProductDetailScreen/ProductDetailScreen.dart';
import 'package:mightystore/screen/ProductDetailScreen/ProductDetailScreen2.dart';
import 'package:mightystore/screen/ProductDetailScreen/ProductDetailScreen3.dart';
import 'package:mightystore/screen/SignInScreen.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:mightystore/utils/shared_pref.dart';
import 'package:nb_utils/nb_utils.dart';

class DashBoard2Product2 extends StatefulWidget {
  static String tag = '/Product';
  final double? width;
  final ProductResponse? mProductModel;

  DashBoard2Product2({Key? key, this.width, this.mProductModel}) : super(key: key);

  @override
  DashBoard2Product2State createState() => DashBoard2Product2State();
}

class DashBoard2Product2State extends State<DashBoard2Product2> {
  bool mIsInWishList = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    if (!await isGuestUser() && await isLoggedIn()) {
      if (widget.mProductModel!.isAddedWishList == false) {
        mIsInWishList = false;
      } else {
        mIsInWishList = true;
      }
    } else if (await isGuestUser()) {
      fetchPrefData();
    } else {}
  }

  void fetchPrefData() {
    if (appStore.mWishList.isNotEmpty) {
      appStore.mWishList.forEach((element) {
        if (element.proId == widget.mProductModel!.id) {
          mIsInWishList = true;
        }
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void checkLogin() async {
    if (!await isLoggedIn()) {
      SignInScreen().launch(context);
      return;
    } else {
      setState(() {
        if (mIsInWishList == true)
          removeWishListItem();
        else
          addToWishList();
        mIsInWishList = !mIsInWishList;
      });
    }
  }

  void removeWishListItem() async {
    if (!await isLoggedIn()) {
      SignInScreen().launch(context);
      return;
    }
    await removeWishList({
      'pro_id': widget.mProductModel!.id,
    }).then((res) {
      if (!mounted) return;
      setState(() {
        toast(res[msg]);
        log("removeWishList" + mIsInWishList.toString());
      });
    }).catchError((error) {
      setState(() {
        toast(error.toString());
      });
    });
  }

  void addToWishList() async {
    if (!await isLoggedIn()) {
      SignInScreen().launch(context);
      return;
    }
    var request = {'pro_id': widget.mProductModel!.id};
    await addWishList(request).then((res) {
      if (!mounted) return;
      setState(() {
        toast(res[msg]);
        log("addToWishList" + mIsInWishList.toString());
      });
    }).catchError((error) {
      setState(() {
        toast(error.toString());
      });
    });
  }

  void removePrefData() async {
    if (!await isGuestUser()) {
      checkLogin();
    } else {
      mIsInWishList = !mIsInWishList;
      var mList = <String?>[];
      widget.mProductModel!.images.forEachIndexed((element, index) {
        mList.add(element.src);
      });
      WishListResponse mWishListModel = WishListResponse();
      mWishListModel.name = widget.mProductModel!.name;
      mWishListModel.proId = widget.mProductModel!.id;
      mWishListModel.salePrice = widget.mProductModel!.salePrice;
      mWishListModel.regularPrice = widget.mProductModel!.regularPrice;
      mWishListModel.price = widget.mProductModel!.price;
      mWishListModel.gallery = mList;
      mWishListModel.stockQuantity = 1;
      mWishListModel.thumbnail = "";
      mWishListModel.full = widget.mProductModel!.images![0].src;
      mWishListModel.sku = "";
      mWishListModel.createdAt = "";
      if (mIsInWishList != true) {
        appStore.removeFromMyWishList(mWishListModel);
      } else {
        appStore.addToMyWishList(mWishListModel);
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var productWidth = MediaQuery.of(context).size.width;

    String? img = widget.mProductModel!.images!.isNotEmpty ? widget.mProductModel!.images!.first.src : '';

    return GestureDetector(
      onTap: () async {
        var result;
        if (getIntAsync(PRODUCT_DETAIL_VARIANT, defaultValue: 1) == 1) {
          result = await ProductDetailScreen(mProId: widget.mProductModel!.id).launch(context);
        } else if (getIntAsync(PRODUCT_DETAIL_VARIANT, defaultValue: 1) == 2) {
          result = await ProductDetailScreen2(mProId: widget.mProductModel!.id).launch(context);
        } else if (getIntAsync(PRODUCT_DETAIL_VARIANT, defaultValue: 1) == 3) {
          result = await ProductDetailScreen3(mProId: widget.mProductModel!.id).launch(context);
        } else {
          result = await ProductDetailScreen(mProId: widget.mProductModel!.id).launch(context);
        }
        if (result == null) {
          mIsInWishList = mIsInWishList;
          setState(() {});
        } else {
          mIsInWishList = result;
          setState(() {});
        }
      },
      child: Container(
        decoration: boxDecorationRoundedWithShadow(8,backgroundColor: context.cardColor),
        width: widget.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                commonCacheImageWidget(img.validate(), height: 180, width: productWidth, fit: BoxFit.cover).cornerRadiusWithClipRRectOnly(topRight: 8, topLeft: 8),
                mSale(widget.mProductModel!),
                Container(
                  margin: EdgeInsets.all(6),
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).cardTheme.color),
                  child: mIsInWishList == false ? Icon(Icons.favorite_border, color: Theme.of(context).textTheme.subtitle2!.color, size: 16) : Icon(Icons.favorite, color: Colors.red, size: 16),
                ).visible(!widget.mProductModel!.type!.contains("grouped")).onTap(() {
                  removePrefData();
                })
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.mProductModel!.name, style: primaryTextStyle(), maxLines: 1),
                2.height,
                Row(
                  children: [
                    PriceWidget(
                      price: widget.mProductModel!.onSale == true
                          ? widget.mProductModel!.salePrice.validate().isNotEmpty
                              ? double.parse(widget.mProductModel!.salePrice.toString()).toStringAsFixed(2)
                              : double.parse(widget.mProductModel!.price.validate()).toStringAsFixed(2)
                          : widget.mProductModel!.regularPrice!.isNotEmpty
                              ? double.parse(widget.mProductModel!.regularPrice.validate().toString()).toStringAsFixed(2)
                              : double.parse(widget.mProductModel!.price.validate().toString()).toStringAsFixed(2),
                      size: 14,
                      color: primaryColor,
                    ),
                    spacing_control.width,
                    PriceWidget(
                      price: widget.mProductModel!.regularPrice.validate().toString(),
                      size: 12,
                      isLineThroughEnabled: true,
                      color: Theme.of(context).textTheme.subtitle1!.color,
                    ).visible(widget.mProductModel!.salePrice.validate().isNotEmpty && widget.mProductModel!.onSale == true),
                  ],
                ).visible(!widget.mProductModel!.type!.contains("grouped")).paddingOnly(bottom: spacing_standard.toDouble()),
              ],
            ).paddingOnly(left: 8,right: 8,top: 8),
          ],
        ),
      ),
    );
  }
}
