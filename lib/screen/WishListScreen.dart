import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/models/CartModel.dart';
import 'package:mightystore/models/WishListResponse.dart';
import 'package:mightystore/network/rest_apis.dart';
import 'package:mightystore/screen/DashBoardScreen.dart';
import 'package:mightystore/screen/SignInScreen.dart';
import 'package:mightystore/screen/SignUpScreen.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/colors.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:mightystore/utils/images.dart';
import 'package:mightystore/utils/shared_pref.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';
import 'AppBarWidget.dart';
import 'ProductDetailScreen/ProductDetailScreen.dart';
import 'ProductDetailScreen/ProductDetailScreen2.dart';
import 'ProductDetailScreen/ProductDetailScreen3.dart';
import 'SearchScreen.dart';

class WishListScreen extends StatefulWidget {
  static String tag = '/WishListScreen';

  @override
  WishListScreenState createState() => WishListScreenState();
}

class WishListScreenState extends State<WishListScreen> {
  List<WishListResponse> mWishListModel = [];
  bool isLoading = false;
  bool mIsLoggedIn = false;
  String mErrorMsg = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setState(() {
      mIsLoggedIn = getBoolAsync(IS_LOGGED_IN, defaultValue: false);
    });
    if (!await isGuestUser() && await isLoggedIn()) {
      fetchWishListData();
    } else if (await isGuestUser()) {
      fetchPrefWishListData();
    } else {
      setState(() {
        mIsLoggedIn = false;
        mErrorMsg = 'An Empty shopping basket is a lonely shopping basket. Go On, add shopping';
      });
    }
  }

  Future fetchWishListData() async {
    setState(() {
      isLoading = true;
    });
    await getWishList().then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        Iterable list = res;
        mWishListModel = list.map((model) => WishListResponse.fromJson(model)).toList();
        mErrorMsg = 'No Products';
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        mErrorMsg = 'No Products';
      });
    });
  }

  fetchPrefWishListData() {
    if (appStore.mWishList.isEmpty) {
      mErrorMsg = 'No Products';
    } else {
      setState(() {
        isLoading = false;
        mWishListModel = appStore.mWishList;
      });
    }
  }

  Future addToCartApi(mProId) async {
    var removeWishListRequest = {
      'pro_id': mProId,
    };
    removeWishList(removeWishListRequest).then((res) {
      if (!mounted) return;
      var request = {
        'pro_id': mProId,
        'quantity': 1,
      };
      addToCart(request).then((res) {
        toast(res[msg]);
        fetchWishListData();
      }).catchError((error) {
        toast(error.toString());
        fetchWishListData();
      });
    }).catchError((error) {});
  }

  Future removeWishListItem(mProId) async {
    var removeWishListRequest = {
      'pro_id': mProId,
    };
    removeWishList(removeWishListRequest).then((res) {
      if (!mounted) return;
      fetchWishListData();
    }).catchError((error) {
      toast(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    Widget mWishList = StaggeredGridView.countBuilder(
      scrollDirection: Axis.vertical,
      itemCount: mWishListModel.length,
      shrinkWrap: true,
      padding: EdgeInsets.only(left: 10, right: 10, top: 16),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () async {
            var result;
            if (getIntAsync(PRODUCT_DETAIL_VARIANT, defaultValue: 1) == 1) {
              result = await ProductDetailScreen(mProId: mWishListModel[index].proId).launch(context);
            } else if (getIntAsync(PRODUCT_DETAIL_VARIANT, defaultValue: 1) == 2) {
              result = await ProductDetailScreen2(mProId: mWishListModel[index].proId).launch(context);
            } else if (getIntAsync(PRODUCT_DETAIL_VARIANT, defaultValue: 1) == 3) {
              result = await ProductDetailScreen3(mProId: mWishListModel[index].proId).launch(context);
            } else {
              result = await ProductDetailScreen(mProId: mWishListModel[index].proId).launch(context);
            }
            if (result) fetchWishListData();
          },
          child: Container(
            decoration: boxDecorationWithRoundedCorners(backgroundColor: Theme.of(context).cardTheme.color!, border: Border.all(color: Theme.of(context).colorScheme.background)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    mWishListModel[index].full == null
                        ? commonCacheImageWidget(mWishListModel[index].gallery![0].validate(), height: 150, width: context.width(), fit: BoxFit.cover)
                            .cornerRadiusWithClipRRectOnly(topLeft: 8, topRight: 8)
                        : commonCacheImageWidget(mWishListModel[index].full, height: 150, width: context.width(), fit: BoxFit.cover)
                            .visible(mWishListModel[index].full!.isNotEmpty)
                            .cornerRadiusWithClipRRectOnly(topLeft: 8, topRight: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: boxDecorationWithRoundedCorners(backgroundColor: Colors.red, borderRadius: radiusOnly(topLeft: 8)),
                          child: Text(appLocalization.translate('lbl_sale')!, style: secondaryTextStyle(color: white, size: 12)),
                          padding: EdgeInsets.fromLTRB(6, 2, 6, 2),
                        ).visible(mWishListModel[index].salePrice!.isNotEmpty),
                        Container(
                          margin: EdgeInsets.all(6),
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).cardTheme.color),
                          child: Icon(Icons.close, color: Theme.of(context).textTheme.subtitle2!.color, size: 16),
                        ).onTap(() async {
                          if (!await isGuestUser() && await isLoggedIn()) {
                            removeWishListItem(mWishListModel[index].proId);
                          } else {
                            appStore.removeFromMyWishList(mWishListModel[index]);
                            setState(() {});
                          }
                        }),
                      ],
                    )
                  ],
                ),
                8.height,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(mWishListModel[index].name!, style: primaryTextStyle(), maxLines: 2).paddingOnly(left: spacing_standard.toDouble(), right: spacing_standard.toDouble()),
                    spacing_standard.height,
                    Row(
                      children: <Widget>[
                        PriceWidget(
                          price: mWishListModel[index].salePrice!.isNotEmpty ? mWishListModel[index].salePrice.toString() : mWishListModel[index].price.toString(),
                          size: textSizeMedium.toDouble(),
                          color: primaryColor,
                        ),
                        4.width,
                        PriceWidget(price: mWishListModel[index].regularPrice.toString(), size: 14, color: Theme.of(context).textTheme.subtitle1!.color, isLineThroughEnabled: true)
                            .visible(mWishListModel[index].salePrice.validate().isNotEmpty),
                      ],
                    ).paddingSymmetric(horizontal: spacing_standard.toDouble()),
                    Divider(color: view_color),
                    if (mWishListModel[index].inStock != true)
                      Text(appLocalization.translate('lbl_sold_out')!, style: boldTextStyle(color: appStore.isDarkMode==true ? Colors.grey : context.dividerColor)).paddingOnly(top: 6, bottom: 10).center()
                    else
                      Text(appLocalization.translate('lbl_add_to_basket')!, style: boldTextStyle(color: primaryColor))
                          .onTap(
                            () async {
                              if (!await isGuestUser()) {
                                addToCartApi(mWishListModel[index].proId);
                              } else {
                                CartModel mCartModel = CartModel();
                                mCartModel.name = mWishListModel[index].name;
                                mCartModel.proId = mWishListModel[index].proId;
                                mCartModel.salePrice = mWishListModel[index].salePrice.toDouble();
                                mCartModel.regularPrice = mWishListModel[index].regularPrice.toDouble();
                                mCartModel.price = mWishListModel[index].price.toDouble();
                                mCartModel.gallery = mWishListModel[index].gallery;
                                mCartModel.quantity = "1";
                                mCartModel.stockQuantity = "1";
                                mCartModel.stockStatus = "";
                                mCartModel.thumbnail = "";
                                mCartModel.full = mWishListModel[index].full;
                                mCartModel.sku = "";
                                mCartModel.createdAt = "";
                                if (mWishListModel[index].salePrice!.isNotEmpty) {
                                  mCartModel.onSale = true;
                                } else {
                                  mCartModel.onSale = false;
                                }
                                appStore.increment();
                                toast("Successfully Added to Cart");
                                appStore.removeFromMyWishList(mWishListModel[index]);
                                appStore.addToCartList(mCartModel);
                                setState(() {});
                              }
                            },
                          )
                          .paddingOnly(top: 6, bottom: 10)
                          .center(),
                  ],
                )
              ],
            ),
          ),
        );
      },
      crossAxisCount: 2,
      staggeredTileBuilder: (index) {
        return StaggeredTile.fit(1);
      },
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: mTop(context, appLocalization.translate('lbl_wish_list'), actions: [
        IconButton(
            icon: Icon(Icons.search_sharp, color: white),
            onPressed: () {
              SearchScreen().launch(context);
            })
      ]) as PreferredSizeWidget?,
      body: BodyCornerWidget(
        child: Stack(
          children: [
            !mIsLoggedIn
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(ic_heart, height: 80, width: 80, color: primaryColor),
                      20.height,
                      Text(appLocalization.translate("msg_wishlist")!, style: primaryTextStyle(size: 20), textAlign: TextAlign.center).paddingOnly(left: 20, right: 20),
                      8.height,
                      Text(appLocalization.translate("lbl_wishlist_msg")!, style: secondaryTextStyle(size: 14), textAlign: TextAlign.center).paddingOnly(left: 20, right: 20),
                      30.height,
                      AppButton(
                              width: context.width(),
                              textStyle: primaryTextStyle(color: white),
                              text: appLocalization.translate('lbl_sign_in'),
                              onTap: () {
                                SignInScreen().launch(context);
                              },
                              color: primaryColor)
                          .paddingOnly(left: 16, right: 16),
                      16.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(appLocalization.translate('lbl_dont_t_have_an_account')!, style: primaryTextStyle(size: 18, color: Theme.of(context).textTheme.subtitle1!.color)),
                          Container(
                              margin: EdgeInsets.only(left: 4),
                              child: GestureDetector(
                                  child: Text(appLocalization.translate('lbl_sign_up_link')!, style: TextStyle(fontSize: 18, color: primaryColor)),
                                  onTap: () {
                                    SignUpScreen().launch(context);
                                  }))
                        ],
                      ).paddingAll(16)
                    ],
                  ).visible(!isLoading)
                : mWishListModel.isNotEmpty
                    ? Stack(
                        children: <Widget>[
                          mWishList.visible(mWishListModel.isNotEmpty),
                          mProgress().center().visible(isLoading),
                        ],
                      ).visible(mIsLoggedIn)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(ic_heart, height: 90, width: 90, color: primaryColor),
                          20.height,
                          Text(appLocalization.translate('lbl_your_wishlist_empty')!, style: boldTextStyle(size: 20), textAlign: TextAlign.center).paddingOnly(left: 20, right: 20),
                          8.height,
                          Text(appLocalization.translate('lbl_wishlist_empty_msg')!, style: secondaryTextStyle(size: 14), textAlign: TextAlign.center).paddingOnly(left: 20, right: 20),
                          30.height,
                          AppButton(
                            width: context.width(),
                            textStyle: primaryTextStyle(color: white),
                            text: appLocalization.translate('lbl_start_shopping'),
                            onTap: () {
                              DashBoardScreen().launch(context);
                            },
                            color: primaryColor,
                          ).paddingOnly(left: 16, right: 16),
                        ],
                      ).visible(!isLoading),
            Center(child: mProgress()).visible(isLoading)
          ],
        ),
      ),
    );
  }
}
