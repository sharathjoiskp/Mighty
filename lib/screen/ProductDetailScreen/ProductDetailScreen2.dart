import 'dart:async';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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
import 'package:mightystore/screen/ViewAllScreen.dart';
import 'package:mightystore/screen/ZoomImageScreen.dart';
import 'package:mightystore/utils/Countdown.dart';
import 'package:mightystore/utils/admob_utils.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/colors.dart';
import 'package:mightystore/utils/common.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:mightystore/utils/images.dart';
import 'package:mightystore/utils/shared_pref.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../app_localizations.dart';
import '../AppBarWidget.dart';
import 'ProductDetailScreen.dart';
import '../ReviewScreen.dart';
import '../SignInScreen.dart';
import '../VendorProfileScreen.dart';
import '../WebViewExternalProductScreen.dart';
import 'ProductDetailScreen3.dart';

class ProductDetailScreen2 extends StatefulWidget {
  final int? mProId;

  ProductDetailScreen2({Key? key, this.mProId}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen2> {
  ProductDetailResponse? productDetailNew;
  ProductDetailResponse? mainProduct;

  String mProfileImage = '';
  int? selectedOptionAvailableIn = 0;
  int? selectedOptionCategory;
  int? selectedCategory;
  int? selectedAvailableIn = 0;

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
    Timer.periodic(Duration(seconds: 10), (Timer timer) {
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
    adShow();
    productDetail();
    fetchReviewData();
    setTimer();
  }

  adShow() async {
    if (interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) => print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    enableAds ? interstitialAd!.show() : SizedBox();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: kReleaseMode ? getInterstitialAdUnitId()! : InterstitialAd.testAdUnitId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            interstitialAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            interstitialAd = null;
          },
        ));
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
    mIsLoggedIn = getBoolAsync(IS_LOGGED_IN);
    await getProductDetail(widget.mProId).then((res) {
      if (!mounted) return;
      setState(() {
        mIsLoading = false;
        Iterable mInfo = res;
        mProducts = mInfo.map((model) => ProductDetailResponse.fromJson(model)).toList();
        if (mProducts.isNotEmpty) {
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

          if (mainProduct!.type == "variable" || mainProduct!.type == "variation") {
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

            if (mainProduct!.type == "variable" || mainProduct!.type == "variation" && mProductsList.isNotEmpty) {
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
      log('error:$error');
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
      return DottedBorder(
        color: context.iconColor,
        strokeWidth: 1,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          '${discount.toInt()} % ${AppLocalizations.of(context)!.translate('lbl_off1')!}',
          style: primaryTextStyle(
            color: Colors.red,
            size: 14,
          ),
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
          builder: (BuildContext ctx, Duration? remaining) {
            var seconds = ((remaining!.inMilliseconds / 1000) % 60).toInt();
            var minutes = (((remaining.inMilliseconds / (1000 * 60)) % 60)).toInt();
            var hours = (((remaining.inMilliseconds / (1000 * 60 * 60)) % 24)).toInt();
            log(hours);
            return Container(
              decoration: boxDecorationWithRoundedCorners(borderRadius: radius(4), backgroundColor: colorAccent!.withOpacity(0.3)),
              child: Text(
                value! + " " + '${remaining.inDays}d ${hours}h ${minutes}m ${seconds}s',
                style: primaryTextStyle(size: textSizeSMedium),
              ).paddingAll(spacing_standard.toDouble()),
            ).paddingOnly(left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble(), top: 16, bottom: 16);
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
      padding: EdgeInsets.only(left: 4, right: 4),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemBuilder: (context, i) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mainProduct!.attributes![i].name, style: primaryTextStyle()).visible(mainProduct!.attributes![i].options.validate().isNotEmpty),
            4.height,
            Text(getAllAttribute(mainProduct!.attributes![i]), maxLines: 4, style: secondaryTextStyle()),
          ],
        ).paddingOnly(left: spacing_standard.toDouble());
      },
    );
  }

// ignore: missing_return
  mOtherAttribute() {
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
      return Container(
        width: context.width(),
        padding: EdgeInsets.only(top: 8, bottom: 16),
        margin: EdgeInsets.only(top: 8),
        decoration: boxDecorationRoundedWithShadow(0, backgroundColor: context.cardColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            8.height,
            Text(appLocalization!.translate("lbl_customer_review")!, style: boldTextStyle())
                .paddingOnly(left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble(), bottom: 4)
                .visible(mReviewModel.isNotEmpty),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            mProfileImage.isNotEmpty ? CircleAvatar(backgroundImage: NetworkImage(mProfileImage.validate()), radius: 16) : CircleAvatar(backgroundImage: Image.asset(User_Profile).image, radius: 16),
                            16.width,
                            Text(mReviewModel[index].reviewer!, style: primaryTextStyle()),
                          ],
                        ),
                        8.height,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            RatingBar.builder(
                              initialRating: mReviewModel[index].rating!.toDouble(),
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              ignoreGestures: true,
                              itemCount: 5,
                              itemSize: 16,
                              itemBuilder: (context, _) => Icon(Icons.star,
                                  color: mReviewModel[index].rating == 1
                                      ? redColor
                                      : mReviewModel[index].rating == 2
                                          ? yellowColor
                                          : mReviewModel[index].rating == 3
                                              ? yellowColor
                                              : Color(0xFF66953A),
                                  size: 14),
                              onRatingUpdate: (rating) {},
                            ),
                            8.width,
                            Text(reviewConvertDate(mReviewModel[index].dateCreated), style: secondaryTextStyle()),
                          ],
                        ),
                        4.height,
                        Text(parseHtmlString(mReviewModel[index].review), style: secondaryTextStyle(), maxLines: 3, overflow: TextOverflow.ellipsis),
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
            ).paddingAll(16).visible(mReviewModel.length >= 3 && mainProduct!.reviewsAllowed == true).onTap(() {
              ReviewScreen(mProductId: mainProduct!.id).launch(context);
            })
          ],
        ),
      ).visible(mReviewModel.isNotEmpty);
    }

    Widget upSaleProductList(List<UpsellId> product) {
      var productWidth = MediaQuery.of(context).size.width;
      return Container(
        width: context.width(),
        padding: EdgeInsets.only(top: 8, bottom: 8),
        margin: EdgeInsets.only(top: 8, bottom: 8),
        decoration: boxDecorationRoundedWithShadow(0, backgroundColor: context.cardColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            8.height,
            Text(builderResponse.dashboard!.youMayLikeProduct!.title!, style: boldTextStyle()).paddingLeft(spacing_standard_new.toDouble()),
            8.height,
            HorizontalList(
              itemCount: product.length,
              padding: EdgeInsets.only(left: 8),
              itemBuilder: (context, i) {
                return Container(
                  width: 160,
                  decoration: boxDecorationWithRoundedCorners(
                      borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(blurRadius: 0.3, spreadRadius: 0.2, color: gray.withOpacity(0.4))], backgroundColor: Theme.of(context).cardTheme.color!),
                  margin: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: boxDecorationWithRoundedCorners(
                          borderRadius: radius(8),
                          backgroundColor: Theme.of(context).colorScheme.background,
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF37D5D6),
                              Color(0xFF63A4FF),
                            ],
                            begin: FractionalOffset(0.0, 0.0),
                            end: FractionalOffset(1.0, 0.0),
                          ),
                        ),
                        child: commonCacheImageWidget(product[i].images!.first.src, height: 180, width: productWidth, fit: BoxFit.cover).cornerRadiusWithClipRRect(8),
                      ),
                      spacing_control.height,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                        ],
                      ).paddingOnly(left: 8, top: 8, bottom: 8,right: 8),
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
            )
          ],
        ),
      );
    }

    Widget mGroupAttribute(List<ProductDetailResponse> product) {
      return Container(
        width: context.width(),
        padding: EdgeInsets.only(top: 8, bottom: 8),
        margin: EdgeInsets.only(top: 8, bottom: 8),
        decoration: boxDecorationRoundedWithShadow(0, backgroundColor: context.cardColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(appLocalization!.translate('lbl_product_include')!, style: boldTextStyle()).paddingOnly(left: 12, top: spacing_standard.toDouble()),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: product.length,
              padding: EdgeInsets.only(left: 6, right: 6),
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product[i].name!, style: primaryTextStyle()),
                            4.height,
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
                            ),
                            8.height,
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: boxDecorationWithRoundedCorners(borderRadius: radius(8),backgroundColor: product[i].inStock == true ? primaryColor! : white, border: Border.all(color: primaryColor!)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                      product[i].type! == 'external'
                                          ? product[i].buttonText!
                                          : product[i].isAddedCart! == false
                                              ? appLocalization.translate('lbl_add_to_cart')!.toUpperCase()
                                              : appLocalization.translate('lbl_remove_cart')!.toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: primaryTextStyle(color: product[i].inStock == false ? primaryColor : white, size: 14)),
                                ],
                              ),
                            ).onTap(() {
                              if (product[i].inStock == true) {
                                if (product[i].type == 'external') {
                                  WebViewExternalProductScreen(mExternal_URL: product[i].externalUrl, title: appLocalization.translate('lbl_external_product')).launch(context);
                                } else {
                                  checkCart(proID: product[i].id);
                                  setState(() {});
                                }
                              }
                            }),
                          ],
                        ),
                      ),
                      commonCacheImageWidget(product[i].images![0].src, height: 105, width: 85, fit: BoxFit.cover).cornerRadiusWithClipRRect(8),
                    ],
                  ).paddingAll(8),
                );
              },
            )
          ],
        ),
      );
    }

    final videoSlider = mainProduct != null
        ? Column(
            children: [
              Container(
                height: 450,
                width: MediaQuery.of(context).size.width,
                decoration: boxDecorationWithRoundedCorners(borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)), backgroundColor: Theme.of(context).scaffoldBackgroundColor),
                child: PageView(
                  children: productImg,
                  controller: _pageController,
                  onPageChanged: (index) {
                    selectIndex = index;
                    setState(() {});
                  },
                ),
              ),
              DotIndicator(
                pageController: _pageController,
                pages: productImg,
                indicatorColor: primaryColor,
                unselectedIndicatorColor: grey.withOpacity(0.2),
                currentBoxShape: BoxShape.rectangle,
                boxShape: BoxShape.rectangle,
                borderRadius: radius(2),
                currentBorderRadius: radius(3),
                currentDotSize: 18,
                currentDotWidth: 6,
                dotSize: 6,
              ),
            ],
          )
        : SizedBox();

    final imgSlider = productDetailNew != null
        ? Column(
            children: [
              Container(
                height: 450,
                width: MediaQuery.of(context).size.width,
                decoration: boxDecorationWithRoundedCorners(borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)), backgroundColor: Theme.of(context).scaffoldBackgroundColor),
                child: PageView(
                  children: productImg1.map((i) {
                    return commonCacheImageWidget(
                      i.validate(),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ).cornerRadiusWithClipRRectOnly(topLeft: 20, topRight: 20).onTap(() {
                      ZoomImageScreen(mImgList: productDetailNew!.images).launch(context);
                    });
                  }).toList(),
                  controller: _pageController,
                  onPageChanged: (index) {
                    selectIndex = index;
                    setState(() {});
                  },
                ),
              ),
              DotIndicator(
                pageController: _pageController,
                pages: productImg1,
                indicatorColor: primaryColor,
                unselectedIndicatorColor: grey.withOpacity(0.2),
                currentBoxShape: BoxShape.rectangle,
                boxShape: BoxShape.rectangle,
                borderRadius: radius(2),
                currentBorderRadius: radius(3),
                currentDotSize: 18,
                currentDotWidth: 6,
                dotSize: 6,
              ),
            ],
          )
        : SizedBox();

    void checkWishList() async {
      if (!await isLoggedIn())
        SignInScreen().launch(context);
      else if (!await isGuestUser() && await isLoggedIn()) {
        if (mainProduct!.isAddedWishList!) {
          removeWishListItem();
        } else
          addToWishList();
      } else {
        setState(() {
          mIsInWishList = !mIsInWishList;
          log("IsInWish" + mIsInWishList.toString());
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
            log("wishlist: $mWishListModel");
            toast("Add to wishList");
          } else {
            appStore.removeFromMyWishList(mWishListModel);
            toast("Remove to wishList");
          }
          setState(() {});
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
              padding: EdgeInsets.all(spacing_standard.toDouble()),
              decoration: boxDecorationWithRoundedCorners(borderRadius: BorderRadius.circular(8), backgroundColor: Theme.of(context).cardTheme.color!, border: Border.all(color: primaryColor!)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  mIsInWishList == false ? Icon(Icons.favorite_border, color: primaryColor) : Icon(Icons.favorite, color: primaryColor),
                  // Icon(mIsInWishList ? Icons.favorite_outline : Icons.favorite, color: primaryColor),
                  4.width,
                  Text(mIsInWishList == false ? appLocalization!.translate('lbl_wish_list')!.toUpperCase() : appLocalization!.translate('lbl_wishlisted')!.toUpperCase(),
                      textAlign: TextAlign.center, style: boldTextStyle(color: primaryColor, wordSpacing: 2, size: 14)),
                ],
              ),
            ),
          ).visible(mainProduct!.isAddedWishList != null)
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
              decoration: boxDecorationWithRoundedCorners(borderRadius: BorderRadius.circular(8), backgroundColor: mainProduct!.inStock! ? context.primaryColor : textSecondaryColorGlobal.withOpacity(0.3)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, color: white),
                  4.width,
                  Text(
                    mainProduct!.inStock! == true
                        ? mainProduct!.type! == 'external'
                            ? mainProduct!.buttonText!
                            : isAddedToCart == false
                                ? appLocalization!.translate('lbl_add_to_bag')!.toUpperCase()
                                : appLocalization!.translate('lbl_remove_cart')!.toUpperCase()
                        : appLocalization!.translate('lbl_sold_out')!.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: boldTextStyle(color: white, wordSpacing: 1, size: 14),
                  ),
                ],
              ),
            ),
          )
        : SizedBox();

    final mPrice = mainProduct != null
        ? mainProduct!.onSale == true
            ? Row(
                children: [
                  PriceWidget(
                      price:
                          productDetailNew!.salePrice.toString().isNotEmpty ? double.parse(productDetailNew!.salePrice.toString()).toStringAsFixed(2) : double.parse(productDetailNew!.price.toString()).toStringAsFixed(2),
                      size: textSizeLargeMedium.toDouble(),
                      color: primaryColor),
                  PriceWidget(
                    price: double.parse(productDetailNew!.regularPrice.toString()).toStringAsFixed(2),
                    size: textSizeSMedium.toDouble(),
                    color: Theme.of(context).textTheme.subtitle1!.color,
                    isLineThroughEnabled: true,
                  ).paddingOnly(left: 4).visible(productDetailNew!.salePrice.toString().isNotEmpty && productDetailNew!.onSale == true),
                  8.width,
                  mDiscount().visible(productDetailNew!.salePrice.toString().isNotEmpty && productDetailNew!.onSale == true)
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
                Text(appLocalization!.translate('lbl_you_saved')! + " ", style: secondaryTextStyle()),
                PriceWidget(price: value.toStringAsFixed(2), size: textSizeLargeMedium.toDouble(), color: Theme.of(context).textTheme.subtitle1!.color)
              ],
            ).paddingOnly(left: 12, right: 8);
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

    final RenderObjectWidget body;
    if (mainProduct != null) {
      body = Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                productDetailNew!.images!.isNotEmpty
                    ? mainProduct!.woofVideoEmbed != null && mainProduct!.woofVideoEmbed!.url != ''
                        ? videoSlider
                        : imgSlider
                    : SizedBox(),
                Container(
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  margin: EdgeInsets.only(top: 8, bottom: 8),
                  decoration: boxDecorationRoundedWithShadow(0, backgroundColor: context.cardColor),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(mainProduct!.name!, style: boldTextStyle(size: 18)).expand(),
                          if (mainProduct!.onSale == true)
                            FittedBox(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(6, 2, 6, 2),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.all(Radius.circular(4))),
                                child: Text(appLocalization!.translate('lbl_sale')!, style: boldTextStyle(color: Colors.white, size: 12)),
                              ).cornerRadiusWithClipRRectOnly(topLeft: 0, bottomLeft: 4),
                            ),
                        ],
                      ).paddingOnly(left: 12, right: 12, bottom: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          mPrice,
                          FittedBox(
                            child: Container(
                              decoration: boxDecorationWithRoundedCorners(borderRadius: radius(4), backgroundColor: Theme.of(context).cardTheme.color!, border: Border.all(color: view_color)),
                              padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                              margin: EdgeInsets.only(right: 12),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(text: rating.toString() + " ", style: secondaryTextStyle(size: 10)),
                                    WidgetSpan(child: Icon(Icons.star, size: 14, color: bgCardColor)),
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
                      ).paddingOnly(left: 12, bottom: 8).visible(!mainProduct!.type!.contains("grouped")),
                      mSavePrice().visible(!mainProduct!.type!.contains("grouped")),
                    ],
                  ),
                ),
                if (mainProduct!.store != null)
                  Container(
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    margin: EdgeInsets.only(top: 8, bottom: 8),
                    decoration: boxDecorationRoundedWithShadow(0, backgroundColor: context.cardColor),
                    child: Row(
                      children: [
                        Text(appLocalization!.translate('lbl_trade_in')!, style: primaryTextStyle()).visible(mainProduct!.store!.shopName.validate().isNotEmpty),
                        8.width,
                        Text(mainProduct!.store!.shopName != null ? mainProduct!.store!.shopName.validate() : '', style: boldTextStyle(color: primaryColor)).expand(),
                        Icon(Icons.arrow_forward_ios_outlined, color: context.iconColor, size: 16)
                      ],
                    ).paddingOnly(left: 12, right: 12).onTap(() {
                      VendorProfileScreen(mVendorId: mainProduct!.store!.id).launch(context);
                    }),
                  ).visible(mainProduct!.store!.shopName.validate().isNotEmpty),
                if (mainProduct!.onSale!) mainProduct!.dateOnSaleFrom!.isNotEmpty ? mSpecialPrice(appLocalization!.translate('lbl_special_msg')) : SizedBox(),
                Column(
                  children: [
                    if (mainProduct!.type == "variable" || mainProduct!.type == "variation")
                      Container(
                        width: context.width(),
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        margin: EdgeInsets.only(top: 8, bottom: 8),
                        decoration: boxDecorationRoundedWithShadow(0, backgroundColor: context.cardColor),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(appLocalization!.translate('lbl_Available')!, style: boldTextStyle()).paddingOnly(left: 12, right: 12, top: 8),
                            Wrap(
                              children: mProductOptions.map((e) {
                                int index = mProductOptions.indexOf(e);
                                return Container(
                                  margin: EdgeInsets.all(4),
                                  padding: EdgeInsets.all(8),
                                  decoration:
                                      boxDecorationWithRoundedCorners(backgroundColor: selectedOptionAvailableIn == index ? bgCardColor : context.cardColor, border: Border.all(width: 0.1, color: context.iconColor)),
                                  child: Text(e!, style: secondaryTextStyle(color: selectedOptionAvailableIn == index ? black : textSecondaryColour)),
                                ).onTap(() {
                                  setState(
                                    () {
                                      mSelectedVariation = e;
                                      selectedOptionAvailableIn = index;
                                      mProducts.forEach((product) {
                                        if (mProductVariationsIds[index] == product.id) {
                                          this.productDetailNew = product;
                                        }
                                      });
                                      setPriceDetail();
                                      mImage();
                                    },
                                  );
                                });
                              }).toList(),
                            ).paddingOnly(top: 8, left: 4)
                          ],
                        ),
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
                      mOtherAttribute(),
                  ],
                ),
                Container(
                        width: context.width(),
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        margin: EdgeInsets.only(top: 8, bottom: 8),
                        decoration: boxDecorationRoundedWithShadow(0, backgroundColor: context.cardColor),
                        child: mUpcomingSale()).visible(mainProduct!.onSale!&&mainProduct!.dateOnSaleFrom != ""),
                Container(
                  width: context.width(),
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  margin: EdgeInsets.only(top: 8, bottom: 8),
                  decoration: boxDecorationRoundedWithShadow(0, backgroundColor: context.cardColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appLocalization!.translate('lbl_product_details')!, style: boldTextStyle())
                          .paddingOnly(left: 12, right: 12, top: 8)
                          .visible(productDetailNew!.description!.isNotEmpty || mainProduct!.attributes!.isNotEmpty),
                      HtmlWidget(postContent: productDetailNew!.description.toString().trim()).paddingOnly(right: 6, left: 6).visible(productDetailNew!.description!.isNotEmpty),
                      mSetAttribute().paddingBottom(8).visible(mainProduct!.attributes!.isNotEmpty),
                    ],
                  ),
                ).visible(productDetailNew!.description!.isNotEmpty || mainProduct!.attributes!.isNotEmpty),
                Container(
                  width: context.width(),
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  margin: EdgeInsets.only(top: 8, bottom: 8),
                  decoration: boxDecorationRoundedWithShadow(0, backgroundColor: context.cardColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appLocalization.translate('lbl_short_description')!, style: boldTextStyle()).paddingOnly(top: 8, left: 12, right: 12).visible(mainProduct!.shortDescription.toString().isNotEmpty),
                      HtmlWidget(postContent: mainProduct!.shortDescription).paddingOnly(left: 6, right: 10).visible(mainProduct!.shortDescription.toString().isNotEmpty),
                    ],
                  ),
                ).visible(mainProduct!.shortDescription.toString().isNotEmpty),
                Container(
                  width: context.width(),
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  margin: EdgeInsets.only(top: 8, bottom: 8),
                  decoration: boxDecorationRoundedWithShadow(0, backgroundColor: context.cardColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appLocalization.translate('lbl_category')!, style: boldTextStyle()).paddingOnly(left: 12, right: 12, top: spacing_standard.toDouble()),
                      4.height,
                      Wrap(
                          children: mainProduct!.categories!.map(
                        (e) {
                          return Container(
                            margin: EdgeInsets.only( left: 10, top: 8, bottom: 8),
                            padding: EdgeInsets.only(right: 8, left: 8, bottom: 8, top: 8),
                            decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, border: Border.all(width: 0.1, color: context.iconColor)),
                            child: Text(e.name!, style: secondaryTextStyle()),
                          ).onTap(() {
                            ViewAllScreen(e.name, isCategory: true, categoryId: e.id).launch(context);
                          });
                        },
                      ).toList()),
                    ],
                  ),
                ),
                if (mainProduct!.upSellIds != null) upSaleProductList(mainProduct!.upSellId!).visible(mainProduct!.upSellId!.isNotEmpty),
                _review(),
              ],
            ),
          ),
        ],
      );
    } else {
      body = SizedBox();
    }

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
              actions: [
                mCart(context, mIsLoggedIn, color: white),
              ],
              title: Text(mainProduct != null ? mainProduct!.name! : ' ', style: boldTextStyle(color: Colors.white, size: textSizeLargeMedium)),
              automaticallyImplyLeading: false),
          body: BodyCornerWidget(
            child: mView(
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: <Widget>[
                    mainProduct != null ? body : SizedBox(),
                    Center(child: mProgress()).visible(mIsLoading),
                  ],
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
              children: [Expanded(child: mFavourite, flex: 1), 16.width, Expanded(child: mCartData, flex: 1)],
            ).paddingOnly(top: spacing_standard.toDouble(), bottom: spacing_standard.toDouble(), right: spacing_standard_new.toDouble(), left: spacing_standard_new.toDouble()).visible(!mIsGroupedProduct),
          ).visible(mainProduct != null),
        ),
      ),
    );
  }
}
