import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:mightystore/component/HtmlWidget.dart';
import 'package:mightystore/component/VideoPlayDialog.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/models/CartModel.dart';
import 'package:mightystore/models/ProductDetailResponse.dart';
import 'package:mightystore/models/ProductReviewModel.dart';
import 'package:mightystore/models/WishListResponse.dart';
import 'package:mightystore/network/rest_apis.dart';
import 'package:mightystore/screen/AppBarWidget.dart';
import 'package:mightystore/screen/ViewAllScreen.dart';
import 'package:mightystore/screen/ZoomImageScreen.dart';
import 'package:mightystore/utils/Countdown.dart';
import 'package:mightystore/utils/admob_utils.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/colors.dart';
import 'package:mightystore/utils/common.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:mightystore/utils/shared_pref.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../app_localizations.dart';
import '../ReviewScreen.dart';
import '../SignInScreen.dart';
import '../VendorProfileScreen.dart';
import '../WebViewExternalProductScreen.dart';
import 'ProductDetailScreen2.dart';
import 'ProductDetailScreen3.dart';

class ProductDetailScreen extends StatefulWidget {
  final int? mProId;

  ProductDetailScreen({Key? key, this.mProId}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductDetailResponse? productDetailNew;
  ProductDetailResponse? mainProduct;

  List<ProductDetailResponse> mProducts = [];
  List<ProductReviewModel> mReviewModel = [];
  List<ProductDetailResponse> mProductsList = [];
  List<String?> mProductOptions = [];
  List<int> mProductVariationsIds = [];
  List<ProductDetailResponse> product = [];
  List<Widget> productImg = [];
  List<String?> productImg1 = [];

  InterstitialAd? interstitialAd;
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();
  PageController _pageController = PageController(
    initialPage: 0,
  );

  bool mIsGroupedProduct = false;
  bool mIsExternalProduct = false;
  bool isAddedToCart = false;
  bool mIsInWishList = false;
  bool mIsLoading = true;
  bool mIsLoggedIn = false;

  double rating = 0.0;
  double discount = 0.0;

  int selectIndex = 0;
  int _currentPage = 0;

  String videoType = '';
  String? mSelectedVariation = '';
  String mExternalUrl = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  setTimer() {
    Timer.periodic(Duration(seconds: 15), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  init() async {
    enableAdsLoading ? buildInterstitialAd() : SizedBox();

    productDetail();
    fetchReviewData();
    setTimer();
  }

  InterstitialAd? buildInterstitialAd() {
    InterstitialAd.load(
        adUnitId: getInterstitialAdUnitId()!,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(onAdFailedToLoad: (LoadAdError error) {
          throw error.message;
        }, onAdLoaded: (InterstitialAd ad) {
          ad.show();
        }));
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Future<void> dispose() async {
    _pageController.dispose();
    super.dispose();
  }

  Future productDetail() async {
    mIsLoggedIn = getBoolAsync(IS_LOGGED_IN, defaultValue: false);
    await getProductDetail(widget.mProId).then((res) {
      if (!mounted) return;
      setState(() {
        mIsLoading = false;
        Iterable mInfo = res;
        mProducts = mInfo.map((model) => ProductDetailResponse.fromJson(model)).toList();
        if (mProducts != null && mProducts.isNotEmpty) {
          productDetailNew = mProducts[0];
          mainProduct = mProducts[0];

          rating = double.parse(mainProduct!.averageRating!);
          productDetailNew!.variations!.forEach((element) {
            mProductVariationsIds.add(element);
          });
          if (getBoolAsync(IS_GUEST_USER) == true) {
            if (appStore.mCartList.isNotEmpty) {
              appStore.mCartList.forEach((element) {
                if (element.proId == mainProduct!.id) {
                  isAddedToCart = true;
                }
              });
            }
            if (appStore.mWishList.isNotEmpty) {
              appStore.mWishList.forEach((element) {
                if (element.proId == mainProduct!.id) {
                  mIsInWishList = true;
                }
              });
            }
          } else {
            if (mainProduct!.isAddedCart!) {
              isAddedToCart = true;
            } else {
              isAddedToCart = false;
            }

            if (mainProduct!.isAddedWishList!) {
              mIsInWishList = true;
            } else {
              mIsInWishList = false;
            }
          }
          mProductsList.clear();

          for (var i = 0; i < mProducts.length; i++) {
            if (i != 0) {
              mProductsList.add(mProducts[i]);
            }
          }

          if (mainProduct!.type == "variable") {
            mProductOptions.clear();
            mProductsList.forEach((product) {
              var option = '';

              product.attributes!.forEach((attribute) {
                if (option.isNotEmpty) {
                  option = '$option - ${attribute.option.validate()}';
                } else {
                  option = attribute.option.validate();
                }
              });

              if (product.onSale!) {
                option = '$option [Sale]';
              }

              mProductOptions.add(option);
            });
            if (mProductOptions.isNotEmpty) mSelectedVariation = mProductOptions.first;

            if (mainProduct!.type == "variable" && mProductsList.isNotEmpty) {
              productDetailNew = mProductsList[0];
              mProducts = mProducts;
            }
            log('mProductOptions');
          } else if (mainProduct!.type == 'grouped') {
            mIsGroupedProduct = true;
            product.clear();
            product.addAll(mProductsList);
          }

          if (mainProduct!.woofVideoEmbed != null) {
            if (mainProduct!.woofVideoEmbed!.url != '') {
              if (mainProduct!.woofVideoEmbed!.url.validate().contains(VideoTypeYouTube)) {
                videoType = VideoTypeYouTube;
              } else if (mainProduct!.woofVideoEmbed!.url.validate().contains(VideoTypeIFrame)) {
                videoType = VideoTypeIFrame;
              } else {
                videoType = VideoTypeCustom;
              }
              productImg.add(
                Stack(
                  fit: StackFit.expand,
                  children: [
                    commonCacheImageWidget(
                      mainProduct!.images![0].src.validate(),
                      fit: BoxFit.cover,
                      height: 400,
                      width: double.infinity,
                    ).cornerRadiusWithClipRRectOnly(topLeft: 20, topRight: 20).paddingOnly(bottom: 24),
                    Icon(Icons.play_circle_fill_outlined, size: 40, color: Colors.black12).center(),
                  ],
                ).onTap(() {
                  VideoPlayDialog(data: mainProduct!.woofVideoEmbed).launch(context);
                }),
              );
            }
          }
          mImage();
          setPriceDetail();
        }
      });
    }).catchError((error) {
      log(error);
      mIsLoading = false;
      toast(error.toString());
      setState(() {});
    });
  }

  Future fetchReviewData() async {
    setState(() {
      mIsLoading = true;
    });
    await getProductReviews(widget.mProId).then((res) {
      if (!mounted) return;
      setState(() {
        mIsLoading = false;
        Iterable list = res;
        mReviewModel = list.map((model) => ProductReviewModel.fromJson(model)).toList();
      });
    }).catchError((error) {
      setState(() {
        mIsLoading = false;
      });
    });
  }

// Set Price Detail
  Widget setPriceDetail() {
    setState(() {
      if (productDetailNew!.onSale!) {
        double mrp = double.parse(productDetailNew!.regularPrice!).toDouble();
        double discountPrice = double.parse(productDetailNew!.price!).toDouble();
        discount = ((mrp - discountPrice) / mrp) * 100;
      }
    });
    return SizedBox();
  }

  void mImage() {
    setState(() {
      productImg1.clear();
      productDetailNew!.images!.forEach((element) {
        productImg1.add(element.src);
      });
    });
  }

  Widget mDiscount() {
    if (mainProduct!.onSale!)
      return Container(
        child: Text(
          "(" + '${discount.toInt()} % ${AppLocalizations.of(context)!.translate('lbl_off1')! + ")"}',
          style: primaryTextStyle(color: Colors.red),
        ),
      );
    else
      return SizedBox();
  }

  Widget mSpecialPrice(String? value) {
    if (mainProduct != null) {
      if (mainProduct!.dateOnSaleFrom != "") {
        var endTime = mainProduct!.dateOnSaleTo.toString() + " 23:59:59.000";
        var endDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(endTime);
        var currentDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(DateTime.now().toString());
        var format = endDate.subtract(Duration(days: currentDate.day, hours: currentDate.hour, minutes: currentDate.minute, seconds: currentDate.second));
        log(format);

        return Countdown(
          duration: Duration(days: format.day, hours: format.hour, minutes: format.minute, seconds: format.second),
          onFinish: () {
            log('finished!');
          },
          builder: (context, remaining) {
            var seconds = ((remaining!.inMilliseconds / 1000) % 60).toInt();
            var minutes = (((remaining.inMilliseconds / (1000 * 60)) % 60)).toInt();
            var hours = (((remaining.inMilliseconds / (1000 * 60 * 60)) % 24)).toInt();
            return Container(
              padding: EdgeInsets.only(left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble(), top: 16, bottom: 16),
              decoration: boxDecorationWithRoundedCorners(borderRadius: radius(4), backgroundColor: colorAccent!.withOpacity(0.3)),
              child: Text(
                value! + " " + '${remaining.inDays}d ${hours}h ${minutes}m ${seconds}s',
                style: primaryTextStyle(size: textSizeSMedium),
              ).paddingAll(spacing_standard.toDouble()),
            );
          },
        );
      } else {
        return SizedBox();
      }
    } else {
      return SizedBox();
    }
  }

  void removeWishListItem() async {
    if (!await isLoggedIn()) {
      SignInScreen().launch(context);
      return;
    }
    await removeWishList({
      'pro_id': mainProduct!.id,
    }).then((res) {
      if (!mounted) return;
      productDetail();
      setState(() {
        toast(res[msg]);
        mIsInWishList = false;
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
    var request = {'pro_id': mainProduct!.id};
    await addWishList(request).then((res) {
      if (!mounted) return;
      productDetail();
      setState(() {
        toast(res[msg]);
        mIsInWishList = true;
      });
    }).catchError((error) {
      setState(() {
        toast(error.toString());
      });
    });
  }

// get Additional Information
  String getAllAttribute(Attribute attribute) {
    String attributes = "";
    for (var i = 0; i < attribute.options!.length; i++) {
      attributes = attributes + attribute.options![i];
      if (i < attribute.options!.length - 1) {
        attributes = attributes + ", ";
      }
    }
    return attributes;
  }

// Set additional information
  Widget mSetAttribute() {
    return ListView.builder(
      itemCount: mainProduct!.attributes!.length,
      padding: EdgeInsets.only(left: 8, right: 8),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemBuilder: (context, i) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mainProduct!.attributes![i].name + " : ", style: boldTextStyle()),
            Text(getAllAttribute(mainProduct!.attributes![i]), maxLines: 4, style: secondaryTextStyle()).paddingTop(4),
          ],
        ).paddingOnly(left: spacing_standard.toDouble());
      },
    );
  }

// ignore: missing_return
  Widget? mOtherAttribute() {
    toast('Product type not supported');
    finish(context);
  }

  @override
  Widget build(BuildContext context) {
    setValue(CARTCOUNT, appStore.count);

    var appLocalization = AppLocalizations.of(context);

    // API calling for add to cart
    Future addToCartApi(proId, int quantity, {returnExpected = false}) async {
      if (!await isLoggedIn()) {
        SignInScreen().launch(context);
        return;
      }

      setState(() {
        mIsLoading = true;
      });

      var request = {
        "pro_id": proId,
        "quantity": quantity,
      };
      setState(() {
        mIsLoading = true;
      });
      await addToCart(request).then((res) {
        toast(appLocalization!.translate('msg_add_cart'));
        mIsLoading = false;
        isAddedToCart = true;
        mIsLoading = false;
        appStore.increment();
        productDetail();
        setState(() {});
        return returnExpected;
      }).catchError((error) {
        toast(error.toString());
        setState(() {
          mIsLoading = false;
        });
        return returnExpected;
      });
    }

// API calling for remove cart
    Future removeToCartApi(proId, {returnExpected = false}) async {
      if (!await isLoggedIn()) {
        SignInScreen().launch(context);
        return;
      }

      var request = {
        "pro_id": proId,
      };

      await removeCartItem(request).then((res) {
        toast(appLocalization!.translate('msg_remove_cart'));
        isAddedToCart = false;
        appStore.decrement();
        productDetail();

        return returnExpected;
      }).catchError((error) {
        toast(error.toString());
        setState(() {});
        return returnExpected;
      });
    }

    void checkCart({int? proID}) async {
      if (!await isGuestUser()) {
        if (isAddedToCart) {
          removeToCartApi(proID.toString().isEmptyOrNull ? mainProduct!.id : proID);
        } else {
          addToCartApi(proID.toString().isEmptyOrNull ? mainProduct!.id : proID, 1);
        }
      } else {
        isAddedToCart = !isAddedToCart;
        List<String?> mList = [];
        mainProduct!.images.forEachIndexed((element, index) {
          mList.add(element.src);
        });
        CartModel mCartModel = CartModel();
        mCartModel.name = mainProduct!.name;
        mCartModel.proId = proID.toString().isEmptyOrNull ? mainProduct!.id : proID;
        mCartModel.onSale = mainProduct!.onSale;
        mCartModel.salePrice = mainProduct!.salePrice;
        mCartModel.regularPrice = mainProduct!.regularPrice;
        mCartModel.price = mainProduct!.price;
        mCartModel.gallery = mList;
        mCartModel.quantity = "1";
        mCartModel.stockQuantity = "1";
        mCartModel.stockStatus = "";
        mCartModel.thumbnail = "";
        mCartModel.full = mainProduct!.images![0].src;
        mCartModel.cartId = mainProduct!.id;
        mCartModel.sku = "";
        mCartModel.createdAt = "";
        if (isAddedToCart == false) {
          appStore.decrement();
          toast(appLocalization!.translate('msg_remove_cart'));
          appStore.removeFromCartList(mCartModel);
        } else {
          appStore.increment();
          toast(appLocalization!.translate('msg_add_cart'));
          appStore.addToCartList(mCartModel);
        }
        setState(() {});
      }
    }

    Widget mUpcomingSale() {
      if (mainProduct != null) {
        if (mainProduct!.dateOnSaleFrom != "") {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(thickness: 6, color: appStore.isDarkMode! ? white.withOpacity(0.2) : Theme.of(context).textTheme.headline4!.color),
              Text(
                appLocalization!.translate('lbl_upcoming_sale_on_this_item')!,
                style: boldTextStyle(),
              ).paddingAll(16),
              Container(
                margin: EdgeInsets.only(left: 16, right: 16, bottom: 10),
                decoration: boxDecorationWithRoundedCorners(borderRadius: radius(8), backgroundColor: primaryColor!.withOpacity(0.2)),
                width: context.width(),
                padding: EdgeInsets.fromLTRB(2, 8, 2, 8),
                child: Marquee(
                  directionMarguee: DirectionMarguee.oneDirection,
                  child: Text(
                    appLocalization.translate('lbl_sale_start_from')! +
                        " " +
                        mainProduct!.dateOnSaleFrom! +
                        " " +
                        appLocalization.translate('lbl_to')! +
                        " " +
                        mainProduct!.dateOnSaleTo! +
                        ". " +
                        appLocalization.translate('lbl_ge_amazing_discounts_on_the_products')!,
                    style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle2!.color, size: textSizeMedium),
                  ).paddingLeft(16),
                ),
              ),
            ],
          );
        } else {
          return SizedBox();
        }
      } else {
        return SizedBox();
      }
    }

    Widget _review() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appLocalization!.translate("lbl_customer_review")!,
            style: boldTextStyle(),
          ).paddingOnly(top: 8, bottom: 8, left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble()).visible(mReviewModel != null && mReviewModel.isNotEmpty),
          ListView.separated(
              separatorBuilder: (context, index) {
                return Divider();
              },
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: mReviewModel.length >= 5 ? 5 : mReviewModel.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 6, right: 6, top: 2, bottom: 2),
                        decoration: BoxDecoration(
                            color: mReviewModel[index].rating == 1
                                ? redColor
                                : mReviewModel[index].rating == 2
                                    ? yellowColor
                                    : mReviewModel[index].rating == 3
                                        ? yellowColor
                                        : Color(0xFF66953A),
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              mReviewModel[index].rating.toString(),
                              style: primaryTextStyle(color: whiteColor, size: 14),
                            ),
                            4.width,
                            Icon(Icons.star_border, size: 16, color: whiteColor)
                          ],
                        ),
                      ),
                      8.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(mReviewModel[index].reviewer!, style: boldTextStyle()),
                              Container(
                                height: 10,
                                color: Theme.of(context).textTheme.subtitle1!.color,
                                width: 2,
                                margin: EdgeInsets.only(left: 8, right: 8),
                              ),
                              Text(reviewConvertDate(mReviewModel[index].dateCreated), style: secondaryTextStyle()),
                            ],
                          ),
                          5.height,
                          Text(parseHtmlString(mReviewModel[index].review), style: primaryTextStyle()),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(appLocalization.translate("lbl_view_all_customer_review")!, style: boldTextStyle(color: Theme.of(context).accentColor)),
              Icon(Icons.chevron_right),
            ],
          )
              .onTap(() {
                ReviewScreen(mProductId: mainProduct!.id).launch(context);
              })
              .paddingAll(16)
              .visible(mReviewModel.length >= 5 && mainProduct!.reviewsAllowed == true),
        ],
      );
    }

    Widget upSaleProductList(List<UpsellId> product) {
      var productWidth = MediaQuery.of(context).size.width;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          8.height,
          Text(builderResponse.dashboard!.youMayLikeProduct!.title!, style: boldTextStyle()).paddingLeft(spacing_standard_new.toDouble()),
          Container(
            margin: EdgeInsets.only(top: spacing_standard.toDouble(), bottom: spacing_standard_new.toDouble()),
            height: 275,
            child: ListView.builder(
              itemCount: product.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 8),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, i) {
                return Container(
                  height: 260,
                  width: 160,
                  margin: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: boxDecorationWithRoundedCorners(borderRadius: radius(8), backgroundColor: Theme.of(context).colorScheme.background),
                        child: Stack(
                          children: [
                            commonCacheImageWidget(product[i].images!.first.src.validate().toString(), height: 150, width: productWidth, fit: BoxFit.cover).cornerRadiusWithClipRRect(8),
                          ],
                        ),
                      ),
                      spacing_control.height,
                      Text(product[i].name!, style: primaryTextStyle(size: textSizeSMedium), maxLines: 2),
                      spacing_standard.height,
                      Row(
                        children: [
                          PriceWidget(price: product[i].salePrice.toString().isNotEmpty ? product[i].salePrice.toString() : product[i].price.toString(), size: 14, color: primaryColor),
                          4.width,
                          PriceWidget(price: product[i].regularPrice.toString(), size: 12, isLineThroughEnabled: true, color: Theme.of(context).textTheme.subtitle2!.color)
                              .visible(product[i].salePrice.toString().isNotEmpty),
                        ],
                      ),
                      spacing_standard.height,
                    ],
                  ),
                ).onTap(() {
                  if (getIntAsync(PRODUCT_DETAIL_VARIANT, defaultValue: 1) == 1) {
                    ProductDetailScreen(mProId: product[i].id).launch(context);
                  } else if (getIntAsync(PRODUCT_DETAIL_VARIANT, defaultValue: 1) == 2) {
                    ProductDetailScreen2(mProId: product[i].id).launch(context);
                  } else if (getIntAsync(PRODUCT_DETAIL_VARIANT, defaultValue: 1) == 3) {
                    ProductDetailScreen3(mProId: product[i].id).launch(context);
                  } else {
                    ProductDetailScreen(mProId: product[i].id).launch(context);
                  }
                });
              },
            ),
          )
        ],
      );
    }

    Widget mGroupAttribute(List<ProductDetailResponse> product) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Divider(thickness: 6, color: appStore.isDarkMode! ? white.withOpacity(0.2) : Theme.of(context).textTheme.headline4!.color),
          Text(appLocalization!.translate('lbl_product_include')!, style: boldTextStyle()).paddingOnly(left: 16, top: spacing_standard.toDouble()),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: product.length,
            padding: EdgeInsets.only(left: 16, right: 16),
            itemBuilder: (context, i) {
              return GestureDetector(
                onTap: () {
                  if (getIntAsync(PRODUCT_DETAIL_VARIANT, defaultValue: 1) == 1) {
                    ProductDetailScreen(mProId: product[i].id).launch(context);
                  } else if (getIntAsync(PRODUCT_DETAIL_VARIANT, defaultValue: 1) == 2) {
                    ProductDetailScreen2(mProId: product[i].id).launch(context);
                  } else if (getIntAsync(PRODUCT_DETAIL_VARIANT, defaultValue: 1) == 3) {
                    ProductDetailScreen3(mProId: product[i].id).launch(context);
                  } else {
                    ProductDetailScreen(mProId: product[i].id).launch(context);
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(spacing_standard.toDouble()),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      commonCacheImageWidget(product[i].images![0].src.validate().toString(), height: 85, width: 85, fit: BoxFit.cover).cornerRadiusWithClipRRect(8),
                      4.width,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            8.height,
                            Text(product[i].name!, style: boldTextStyle()).paddingOnly(left: spacing_standard.toDouble(), right: spacing_standard.toDouble()),
                            16.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: boxDecorationWithRoundedCorners(
                                      borderRadius: radius(8), backgroundColor: product[i].inStock == true ? primaryColor! : white, border: Border.all(color: primaryColor!)),
                                  child: Text(
                                      product[i].type! == 'external'
                                          ? product[i].buttonText!
                                          : product[i].isAddedCart == false
                                              ? appLocalization.translate('lbl_add_to_cart')!.toUpperCase()
                                              : appLocalization.translate('lbl_remove_cart')!.toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: boldTextStyle(color: product[i].inStock == false ? primaryColor : white, size: 14)),
                                ).onTap(() {
                                  log("product[i].buttonText!:" + product[i].buttonText!);
                                  if (product[i].type == 'external') {
                                    WebViewExternalProductScreen(mExternal_URL: mExternalUrl, title: appLocalization.translate('lbl_external_product')).launch(context);
                                  } else {
                                    checkCart(proID: product[i].id);
                                    setState(() {});
                                  }
                                }),
                                Row(
                                  children: [
                                    PriceWidget(
                                        price: product[i].salePrice.toString().validate().isNotEmpty ? product[i].salePrice.toString() : product[i].price.toString().validate(),
                                        size: 14,
                                        color: Theme.of(context).textTheme.subtitle2!.color),
                                    spacing_control_half.width,
                                    PriceWidget(price: product[i].regularPrice.toString(), size: 12, isLineThroughEnabled: true, color: Theme.of(context).textTheme.subtitle2!.color)
                                        .visible(product[i].salePrice.toString().isNotEmpty),
                                  ],
                                )
                              ],
                            ).paddingOnly(left: 8, right: 8),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          )
        ],
      );
    }

    final videoSlider = mainProduct != null
        ? Container(
            height: 450,
            width: MediaQuery.of(context).size.width,
            decoration: boxDecorationWithRoundedCorners(
                borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)), backgroundColor: Theme.of(context).scaffoldBackgroundColor),
            margin: EdgeInsets.only(bottom: 16),
            child: Stack(
              children: [
                PageView(
                  children: productImg,
                  controller: _pageController,
                  onPageChanged: (index) {
                    selectIndex = index;
                    setState(() {});
                  },
                ),
                AnimatedPositioned(
                  duration: Duration(seconds: 1),
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: DotIndicator(pages: productImg, indicatorColor: primaryColor, pageController: _pageController),
                ),
              ],
            ),
          )
        : SizedBox();

    final imgSlider = productDetailNew != null
        ? Container(
            height: 450,
            width: MediaQuery.of(context).size.width,
            decoration: boxDecorationWithRoundedCorners(
                borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)), backgroundColor: Theme.of(context).scaffoldBackgroundColor),
            margin: EdgeInsets.only(bottom: 16),
            child: Stack(
              children: [
                PageView(
                  children: productImg1.map((i) {
                    return commonCacheImageWidget(
                      i.validate(),
                      fit: BoxFit.cover,
                      height: 400,
                      width: double.infinity,
                    ).cornerRadiusWithClipRRectOnly(topLeft: 20, topRight: 20).paddingOnly(bottom: 24).onTap(() {
                      ZoomImageScreen(mImgList: productDetailNew!.images).launch(context);
                    });
                  }).toList(),
                  controller: _pageController,
                  onPageChanged: (index) {
                    selectIndex = index;
                    setState(() {});
                  },
                ),
                AnimatedPositioned(
                  duration: Duration(seconds: 1),
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: DotIndicator(pages: productImg1, indicatorColor: primaryColor, pageController: _pageController),
                ),
              ],
            ),
          )
        : SizedBox();

    void checkWishList() async {
      if (!await isLoggedIn())
        SignInScreen().launch(context);
      else if (!await isGuestUser() && await isLoggedIn()) {
        if (mainProduct!.isAddedWishList!)
          removeWishListItem();
        else
          addToWishList();
      } else {
        setState(() {
          mIsInWishList = !mIsInWishList;
          print("IsInWish" + mIsInWishList.toString());
          List<String?> mList = [];
          mainProduct!.images.forEachIndexed((element, index) {
            mList.add(element.src);
          });
          WishListResponse mWishListModel = WishListResponse();
          mWishListModel.name = mainProduct!.name;
          mWishListModel.proId = mainProduct!.id;
          mWishListModel.salePrice = mainProduct!.salePrice;
          mWishListModel.regularPrice = mainProduct!.regularPrice;
          mWishListModel.price = mainProduct!.price;
          mWishListModel.gallery = mList;
          mWishListModel.stockQuantity = 1;
          mWishListModel.thumbnail = "";
          mWishListModel.full = mainProduct!.images![0].src;
          mWishListModel.sku = "";
          mWishListModel.createdAt = "";
          if (mIsInWishList == true) {
            appStore.addToMyWishList(mWishListModel);
          } else {
            appStore.removeFromMyWishList(mWishListModel);
          }
        });
      }
    }

    // Check Wish list
    final mFavourite = mainProduct != null
        ? GestureDetector(
            onTap: () {
              checkWishList();
              setState(() {});
            },
            child: Container(
              padding: EdgeInsets.all(spacing_middle.toDouble()),
              decoration: boxDecorationWithRoundedCorners(borderRadius: radius(8), backgroundColor: Theme.of(context).cardTheme.color!, border: Border.all(color: primaryColor!)),
              child: Text(mIsInWishList == false ? appLocalization!.translate('lbl_wish_list')!.toUpperCase() : appLocalization!.translate('lbl_wishlisted')!.toUpperCase(),
                  textAlign: TextAlign.center, style: boldTextStyle(color: primaryColor, wordSpacing: 2)),
            ),
          ).paddingOnly(bottom: spacing_control.toDouble()).visible(mainProduct!.isAddedWishList != null)
        : SizedBox();

    final mCartData = mainProduct != null
        ? GestureDetector(
            onTap: () {
              if (mainProduct!.inStock == true) {
                if (mIsExternalProduct) {
                  WebViewExternalProductScreen(mExternal_URL: mExternalUrl, title: appLocalization!.translate('lbl_external_product')).launch(context);
                } else {
                  checkCart();
                  setState(() {});
                }
              }
            },
            child: Container(
              padding: EdgeInsets.all(spacing_middle.toDouble()),
              decoration: boxDecorationWithRoundedCorners(borderRadius: radius(8), backgroundColor: mainProduct!.inStock! ? primaryColor! : textSecondaryColorGlobal.withOpacity(0.3)),
              child: Text(
                mainProduct!.inStock! == true
                    ? mainProduct!.type! == 'external'
                        ? mainProduct!.buttonText!
                        : isAddedToCart == false
                            ? appLocalization!.translate('lbl_add_to_cart')!.toUpperCase()
                            : appLocalization!.translate('lbl_remove_cart')!.toUpperCase()
                    : appLocalization!.translate('lbl_sold_out')!.toUpperCase(),
                textAlign: TextAlign.center,
                style: boldTextStyle(color: white, wordSpacing: 2),
              ),
            ),
          )
        : SizedBox();

    final mPrice = mainProduct != null
        ? mainProduct!.onSale == true
            ? Row(
                children: [
                  PriceWidget(
                      price: productDetailNew!.salePrice.toString().isNotEmpty
                          ? double.parse(productDetailNew!.salePrice.validate().toString()).toStringAsFixed(2)
                          : double.parse(productDetailNew!.price.validate().toString()).toStringAsFixed(2),
                      size: textSizeLargeMedium.toDouble(),
                      color: primaryColor),
                  PriceWidget(
                    price: double.parse(productDetailNew!.regularPrice.validate().toString()).toStringAsFixed(2),
                    size: textSizeSMedium.toDouble(),
                    color: Theme.of(context).textTheme.subtitle1!.color,
                    isLineThroughEnabled: true,
                  ).paddingOnly(left: 4).visible(productDetailNew!.salePrice.validate().toString().isNotEmpty && productDetailNew!.onSale == true),
                  8.width,
                  mDiscount().visible(productDetailNew!.salePrice.validate().toString().isNotEmpty && productDetailNew!.onSale == true)
                ],
              )
            : Row(
                children: [
                  PriceWidget(price: double.parse(productDetailNew!.price.toString()).toStringAsFixed(2), size: textSizeLargeMedium.toDouble(), color: primaryColor),
                ],
              )
        : SizedBox();

    Widget mSavePrice() {
      if (mainProduct != null) {
        if (mainProduct!.onSale!) {
          var value = double.parse(productDetailNew!.regularPrice.toString()) - double.parse(productDetailNew!.price.toString());
          if (value > 0) {
            return Row(
              children: [
                Text(appLocalization!.translate('lbl_you_saved')! + " ", style: secondaryTextStyle(size: 16)),
                PriceWidget(
                  price: value.toStringAsFixed(2),
                  size: textSizeLargeMedium.toDouble(),
                  color: Theme.of(context).textTheme.subtitle1!.color,
                )
              ],
            ).paddingOnly(top: 4, left: 16, right: 8);
          } else {
            return SizedBox();
          }
        } else {
          return SizedBox();
        }
      } else {
        return SizedBox();
      }
    }

    Widget mExternalAttribute() {
      setPriceDetail();
      mIsExternalProduct = true;
      mExternalUrl = mainProduct!.externalUrl.toString();
      return SizedBox();
    }

    final body = mainProduct != null
        ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                productDetailNew!.images!.isNotEmpty
                    ? mainProduct!.woofVideoEmbed != null && mainProduct!.woofVideoEmbed!.url != ''
                        ? videoSlider
                        : imgSlider
                    : SizedBox(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(mainProduct!.name!, style: boldTextStyle(size: 18)).paddingOnly(left: 16, right: 16).expand(),
                        if (mainProduct!.onSale == true)
                          FittedBox(
                            child: Container(
                              padding: EdgeInsets.fromLTRB(6, 4, 6, 2),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.all(Radius.circular(4))),
                              child: Text(appLocalization!.translate('lbl_sale')!, style: boldTextStyle(color: Colors.white, size: 12)),
                            ).cornerRadiusWithClipRRectOnly(topLeft: 0, bottomLeft: 4).paddingOnly(left: 16, right: 16),
                          ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        mPrice,
                        FittedBox(
                          child: Container(
                            decoration: boxDecorationWithRoundedCorners(borderRadius: radius(4), backgroundColor: Theme.of(context).cardTheme.color!, border: Border.all(color: view_color)),
                            padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                            margin: EdgeInsets.only(right: 8),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(text: rating.toString() + " ", style: secondaryTextStyle(size: 12)),
                                  WidgetSpan(child: Icon(Icons.star, size: 14, color: yellowColor)),
                                ],
                              ),
                            ),
                          ),
                        ).onTap(() async {
                          final double? result = await ReviewScreen(mProductId: mainProduct!.id).launch(context);
                          if (result == null) {
                            rating = rating;
                            setState(() {});
                          } else {
                            rating = result;
                            setState(() {});
                          }
                        }).visible(mainProduct!.reviewsAllowed == true)
                      ],
                    ).paddingOnly(top: 4, left: 16, right: 8).visible(!mainProduct!.type!.contains("grouped")),
                    mSavePrice().visible(!mainProduct!.type!.contains("grouped")),
                    if (mainProduct!.store != null && !mainProduct!.store!.shopName.validate().isEmptyOrNull)
                      Divider(thickness: 6, color: Theme.of(context).textTheme.headline4!.color).visible(mainProduct!.store!.shopName!.validate().isNotEmpty),
                    if (mainProduct!.store != null && !mainProduct!.store!.shopName.validate().isEmptyOrNull)
                      Row(
                        children: [
                          Text(appLocalization!.translate('lbl_sold_by')!, style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1!.color))
                              .visible(mainProduct!.store!.shopName.validate().isNotEmpty),
                          8.width,
                          GestureDetector(
                            onTap: () {
                              VendorProfileScreen(mVendorId: mainProduct!.store!.id).launch(context);
                            },
                            child: Text(mainProduct!.store!.shopName != null ? mainProduct!.store!.shopName.validate() : '', style: boldTextStyle(color: primaryColor)),
                          )
                        ],
                      ).paddingOnly(top: 8, left: 16, right: 8, bottom: 8),
                    Divider(thickness: 6, color: appStore.isDarkMode! ? white.withOpacity(0.2) : Theme.of(context).textTheme.headline4!.color)
                        .visible(mainProduct!.onSale! && mainProduct!.dateOnSaleFrom!.isNotEmpty),
                    if (mainProduct!.onSale!) mainProduct!.dateOnSaleFrom!.isNotEmpty ? mSpecialPrice(appLocalization!.translate('lbl_special_msg')) : SizedBox(),
                    if (mainProduct!.type == "variable")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Divider(thickness: 6, color: appStore.isDarkMode! ? white.withOpacity(0.2) : Theme.of(context).textTheme.headline4!.color),
                          Text(appLocalization!.translate('lbl_Available')!, style: boldTextStyle()).paddingOnly(left: 16, right: 16),
                          Container(
                            margin: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8, top: 8),
                            decoration: boxDecorationWithRoundedCorners(borderRadius: radius(8), backgroundColor: Theme.of(context).colorScheme.background),
                            padding: EdgeInsets.only(left: 8, right: 8),
                            child: Theme(
                              data: Theme.of(context).copyWith(canvasColor: Theme.of(context).cardTheme.color),
                              child: DropdownButton(
                                value: mSelectedVariation,
                                isExpanded: true,
                                underline: SizedBox(),
                                onChanged: (dynamic value) {
                                  setState(() {
                                    mSelectedVariation = value;
                                    int index = mProductOptions.indexOf(value);
                                    mProducts.forEach((product) {
                                      if (mProductVariationsIds[index] == product.id) {
                                        this.productDetailNew = product;
                                      }
                                    });
                                    setPriceDetail();
                                    mImage();
                                  });
                                },
                                items: mProductOptions.map((value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: Text(value!, style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1!.color)),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      )
                    else if (mainProduct!.type == "grouped")
                      mGroupAttribute(product)
                    else if (mainProduct!.type == "simple")
                      Container()
                    else if (mainProduct!.type == "external")
                      Column(
                        children: [
                          mExternalAttribute(),
                        ],
                      )
                    else
                      mOtherAttribute()!,
                    mUpcomingSale().visible(!mainProduct!.onSale!),
                    Divider(thickness: 6, color: appStore.isDarkMode! ? white.withOpacity(0.2) : Theme.of(context).textTheme.headline4!.color).visible(productDetailNew!.description!.isNotEmpty),
                    Text(appLocalization!.translate('lbl_product_details')!, style: boldTextStyle())
                        .paddingOnly(top: 8, left: 16, right: 16)
                        .visible(productDetailNew!.description!.isNotEmpty || mainProduct!.attributes!.isNotEmpty),
                    HtmlWidget(postContent: productDetailNew!.description).paddingOnly(left: 8, right: 16).visible(productDetailNew!.description!.isNotEmpty),
                    mSetAttribute().paddingBottom(12),
                    Divider(thickness: 6, color: appStore.isDarkMode! ? white.withOpacity(0.2) : Theme.of(context).textTheme.headline4!.color)
                        .visible(mainProduct!.shortDescription.toString().isNotEmpty),
                    Text(appLocalization.translate('lbl_short_description')!, style: boldTextStyle())
                        .paddingOnly(top: 8, left: 16, right: 16)
                        .visible(mainProduct!.shortDescription.toString().isNotEmpty),
                    HtmlWidget(postContent: mainProduct!.shortDescription).paddingOnly(left: 8, right: 16).visible(mainProduct!.shortDescription.toString().isNotEmpty),
                    Divider(thickness: 6, height: 0, color: appStore.isDarkMode! ? white.withOpacity(0.2) : Theme.of(context).textTheme.headline4!.color),
                    Text(appLocalization.translate('lbl_category')!, style: boldTextStyle()).paddingOnly(top: 8, left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble()),
                    Wrap(
                      children: mainProduct!.categories!.map((e) {
                        return Container(
                                margin: EdgeInsets.only(right: 8, bottom: 10),
                                padding: EdgeInsets.all(8),
                                decoration:
                                    boxDecorationWithRoundedCorners(borderRadius: radius(8), backgroundColor: appStore.isDarkMode! ? white.withOpacity(0.2) : Theme.of(context).colorScheme.background),
                                child: Text(e.name!, style: secondaryTextStyle()))
                            .onTap(() {
                          ViewAllScreen(e.name, isCategory: true, categoryId: e.id).launch(context);
                        });
                      }).toList(),
                    ).paddingOnly(top: spacing_standard_new.toDouble(), left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble()),
                    Divider(thickness: 6, color: appStore.isDarkMode! ? white.withOpacity(0.2) : Theme.of(context).textTheme.headline4!.color).visible(mainProduct!.upSellId!.isNotEmpty),
                    if (mainProduct!.upSellIds != null) upSaleProductList(mainProduct!.upSellId!).visible(mainProduct!.upSellId!.isNotEmpty),
                    Divider(thickness: 6, color: appStore.isDarkMode! ? white.withOpacity(0.2) : Theme.of(context).textTheme.headline4!.color).visible(mReviewModel.isNotEmpty),
                    8.height,
                    _review(),
                    spacing_xxLarge.height,
                  ],
                )
              ],
            ),
          )
        : SizedBox();

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, mIsInWishList);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: primaryColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: primaryColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: white),
              onPressed: () {
                Navigator.pop(context, mIsInWishList);
              },
            ),
            actions: [mCart(context, mIsLoggedIn, color: white)],
            title: Text(mainProduct != null ? mainProduct!.name! : ' ', style: boldTextStyle(color: Colors.white, size: textSizeLargeMedium)),
            automaticallyImplyLeading: false,
          ),
          body: BodyCornerWidget(
            child: mView(
                mInternetConnection(
                  Stack(
                    alignment: Alignment.bottomLeft,
                    children: <Widget>[
                      mainProduct != null ? body : SizedBox(),
                      Center(child: mProgress()).visible(mIsLoading),
                    ],
                  ),
                ),
                context),
          ),
          bottomNavigationBar: Container(
            width: context.width(),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: <BoxShadow>[
                BoxShadow(color: Theme.of(context).hoverColor.withOpacity(0.8), blurRadius: 15.0, offset: Offset(0.0, 0.75)),
              ],
            ),
            child: Row(
              children: [
                mFavourite.expand(flex: 1),
                16.width,
                mCartData.expand(flex: 1),
              ],
            ).paddingSymmetric(vertical: spacing_standard.toDouble(), horizontal: spacing_standard_new.toDouble()).visible(!mIsGroupedProduct),
          ).visible(mainProduct != null),
        ),
      ),
    );
  }
}
