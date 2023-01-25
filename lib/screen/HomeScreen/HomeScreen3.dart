import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mightystore/component/HomeScreenComponent2/DashBoard2app_Widget.dart';
import 'package:mightystore/component/HomeScreenComponent3/DashBoard3Product.dart';
import 'package:mightystore/component/HomeScreenComponent3/DashBoard3Product2.dart';
import 'package:mightystore/component/HomeScreenComponent3/DashBoard3app_Widget.dart';
import 'package:mightystore/component/HomeScreenComponent3/VendorWidget3.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/models/CartModel.dart';
import 'package:mightystore/models/CategoryData.dart';
import 'package:mightystore/models/ProductResponse.dart';
import 'package:mightystore/models/SaleBannerResponse.dart';
import 'package:mightystore/models/SliderModel.dart';
import 'package:mightystore/network/rest_apis.dart';
import 'package:mightystore/screen/NoInternetScreen.dart';
import 'package:mightystore/screen/SaleScreen.dart';
import 'package:mightystore/screen/SearchScreen.dart';
import 'package:mightystore/screen/ViewAllScreen.dart';
import 'package:mightystore/screen/WebViewExternalProductScreen.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/common.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:mightystore/utils/dashed_ract.dart';
import 'package:mightystore/utils/images.dart';
import 'package:mightystore/utils/shared_pref.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../app_localizations.dart';
import '../AppBarWidget.dart';

class HomeScreen3 extends StatefulWidget {
  static String tag = '/HomeScreen1';

  @override
  HomeScreen3State createState() => HomeScreen3State();
}

class HomeScreen3State extends State<HomeScreen3> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  List<String?> mSliderImages = [];
  List<String?> mSaleBannerImages = [];
  List<ProductResponse> mNewestProductModel = [];
  List<ProductResponse> mFeaturedProductModel = [];
  List<ProductResponse> mDealProductModel = [];
  List<ProductResponse> mSellingProductModel = [];
  List<ProductResponse> mSaleProductModel = [];
  List<ProductResponse> mOfferProductModel = [];
  List<ProductResponse> mSuggestedProductModel = [];
  List<ProductResponse> mYouMayLikeProductModel = [];
  List<VendorResponse> mVendorModel = [];
  List<Category> mCategoryModel = [];
  List<Widget> data = [];
  List<SliderModel> mSliderModel = [];
  List<Salebanner> mSaleBanner = [];
  List<Widget> pages = [];
  CartResponse mCartModel = CartResponse();
  List<String?> mQuotes = [];

  PageController salePageController = PageController();
  PageController bannerPageController = PageController(initialPage: 0);
  int _currentPage = 0;
  int selectIndex = 0;

  int cartCount = 0;
  int count = 0;

  String mErrorMsg = '';

  bool mIsLoading = true;
  bool isWasConnectionLoss = false;
  bool isDone = false;

  Random rnd = new Random();

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  setTimer() {
    Timer.periodic(
      Duration(seconds: 10),
      (Timer timer) {
        if (_currentPage < 2) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        if (bannerPageController.hasClients) {
          bannerPageController.animateToPage(
            _currentPage,
            duration: Duration(milliseconds: 350),
            curve: Curves.easeIn,
          );
        }
      },
    );
  }

  init() async {
    await setValue(CARTCOUNT, appStore.count);
    fetchDashboardData();
    fetchCategoryData();
    setTimer();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        isWasConnectionLoss = true;
        Scaffold(body: NoInternetScreen()).launch(context);
      } else {
        if (isWasConnectionLoss) finish(context);
      }
    });
  }

  Future fetchCategoryData() async {
    await getCategories(1, TOTAL_CATEGORY_PER_PAGE).then((res) {
      if (!mounted) return;
      setState(() {
        Iterable mCategory = res;
        mCategoryModel = mCategory.map((model) => Category.fromJson(model)).toList();
      });
    }).catchError((error) {
      if (!mounted) return;
    });
  }

  Future fetchDashboardData() async {
    setState(() {});

    await isNetworkAvailable().then((bool) async {
      if (bool) {
        if (!await isGuestUser() && await isLoggedIn()) {
          await getCartList().then((res) {
            if (!mounted) return;
            setState(() {
              mCartModel = CartResponse.fromJson(res);
              if (mCartModel.data!.isNotEmpty) {
                appStore.setCount(mCartModel.totalQuantity);
              }
            });
          }).catchError((error) {
            log(error.toString());
            setState(() {});
          });
        }
        mIsLoading = true;
        await getDashboardApi().then((res) async {
          if (!mounted) return;
          mIsLoading = false;
          await setValue(DEFAULT_CURRENCY, parseHtmlString(res['currency_symbol']['currency_symbol']));
          await setValue(CURRENCY_CODE, res['currency_symbol']['currency']);
          await setValue(DASHBOARD_DATA, jsonEncode(res));
          setProductData(res);
          if (res['social_link'] != null) {
            await setValue(WHATSAPP, res['social_link']['whatsapp']);
            await setValue(FACEBOOK, res['social_link']['facebook']);
            await setValue(TWITTER, res['social_link']['twitter']);
            await setValue(INSTAGRAM, res['social_link']['instagram']);
            await setValue(CONTACT, res['social_link']['contact']);
            await setValue(PRIVACY_POLICY, res['social_link']['privacy_policy']);
            await setValue(TERMS_AND_CONDITIONS, res['social_link']['term_condition']);
            await setValue(COPYRIGHT_TEXT, res['social_link']['copyright_text']);
          }
          await setValue(PAYMENTMETHOD, res['payment_method']);
          await setValue(ENABLECOUPON, res['enable_coupons']);
        }).catchError((error) {
          if (!mounted) return;
          mIsLoading = false;
          mErrorMsg = error.toString();
        });

        isDone = true;
      } else {
        toast('You are not connected to Internet');
        if (!mounted) return;
        mIsLoading = false;
      }
      setState(() {});
    });
  }

  void setProductData(res) async {
    Iterable newest = res['newest'];
    mNewestProductModel = newest.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable featured = res['featured'];
    mFeaturedProductModel = featured.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable deal = res['deal_of_the_day'];
    mDealProductModel = deal.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable selling = res['best_selling_product'];
    mSellingProductModel = selling.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable sale = res['sale_product'];
    mSaleProductModel = sale.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable offer = res['offer'];
    mOfferProductModel = offer.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable suggested = res['suggested_for_you'];
    mSuggestedProductModel = suggested.map((model) => ProductResponse.fromJson(model)).toList();

    Iterable youMayLike = res['you_may_like'];
    mYouMayLikeProductModel = youMayLike.map((model) => ProductResponse.fromJson(model)).toList();

    if (res['vendors'] != null) {
      Iterable vendorList = res['vendors'];
      mVendorModel = vendorList.map((model) => VendorResponse.fromJson(model)).toList();
    }

    if (res['salebanner'] != null) {
      mSaleBannerImages.clear();
      Iterable bannerList = res['salebanner'];
      mSaleBanner = bannerList.map((model) => Salebanner.fromJson(model)).toList();
      mSaleBanner.forEach((s) => mSaleBannerImages.add(s.image));
    }

    mSliderImages.clear();
    Iterable list = res['banner'];
    mSliderModel = list.map((model) => SliderModel.fromJson(model)).toList();
    log("$mSliderModel");
    mSliderModel.forEach((s) => mSliderImages.add(s.image));

    setState(() {});
  }

  List<T?> map<T>(List list, Function handler) {
    List<T?> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  @override
  void dispose() {
    salePageController.dispose();
    bannerPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    mQuotes = [
      appLocalization.translate('msg_quote1'),
      appLocalization.translate('msg_quote2'),
      appLocalization.translate('msg_quote3'),
      appLocalization.translate('msg_quote4'),
      appLocalization.translate('msg_quote5'),
      appLocalization.translate('msg_quote6')
    ];

    Widget productList(List<ProductResponse> product) {
      return Container(
        margin: EdgeInsets.only(left: 8, right: 8, top: 8),
        child: StaggeredGridView.countBuilder(
          scrollDirection: Axis.vertical,
          itemCount: product.length >= TOTAL_DASHBOARD_ITEM ? TOTAL_DASHBOARD_ITEM : product.length,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, i) {
            return DashBoard3Product(mProductModel: product[i], width: context.width());
          },
          crossAxisCount: 2,
          staggeredTileBuilder: (index) {
            return StaggeredTile.fit(1);
          },
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
      );
    }

    Widget availableOfferAndDeal(String title, List<ProductResponse> product) {
      return Stack(
        children: [
          commonCacheImageWidget(ic_horizontal_bg, height: 285, width: context.width(), fit: BoxFit.cover),
          Container(height: 285, color: black.withOpacity(0.2)),
          Container(
            padding: EdgeInsets.only(left: spacing_standard.toDouble()),
            width: context.width() * 0.3,
            margin: EdgeInsets.only(top: context.height() * 0.17),
            child: Text(title, maxLines: 3, overflow: TextOverflow.ellipsis, style: GoogleFonts.alata(fontSize: 23, color: appStore.isDarkMode! ? context.iconColor : white)),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  HorizontalList(
                    padding: EdgeInsets.only(left: context.width() * 0.3, right: 8),
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: product.length > 6 ? 6 : product.length,
                    itemBuilder: (context, i) {
                      return DashBoard3Product2(mProductModel: product[i], width: context.width() * 0.42);
                    },
                  ),
                  viewAllDashBoard3(context, viewAll: builderResponse.dashboard!.youMayLikeProduct!.viewAll!).paddingOnly(right: 16).onTap(
                    () {
                      if (title == builderResponse.dashboard!.dealOfTheDay!.title) {
                        ViewAllScreen(title, isSpecialProduct: true, specialProduct: "deal_of_the_day").launch(context);
                      } else if (title == builderResponse.dashboard!.offerProduct!.title) {
                        ViewAllScreen(appLocalization.translate('lbl_offer'), isSpecialProduct: true, specialProduct: "offer").launch(context);
                      } else {
                        ViewAllScreen(title);
                      }
                    },
                  ).visible(product.length >= TOTAL_DASHBOARD_ITEM),
                ],
              ),
            ),
          )
        ],
      );
    }

    Widget _category() {
      return mCategoryModel.isNotEmpty
          ? Container(
              height: 260,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: mCategoryModel.length,
                padding: EdgeInsets.only(left: 8, right: 4, bottom: 2),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 250, childAspectRatio: 1.1),
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(left: 4, right: 8),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        mCategoryModel[index].image != null
                            ? commonCacheImageWidget(mCategoryModel[index].image!.src.validate(), height: 120, fit: BoxFit.cover).cornerRadiusWithClipRRect(8)
                            : commonCacheImageWidget(ic_placeholder_logo, height: 120, fit: BoxFit.cover).cornerRadiusWithClipRRect(8),
                        Container(decoration: boxDecorationWithRoundedCorners(borderRadius: BorderRadius.all(Radius.circular(8)), backgroundColor: black.withOpacity(0.3)), height: 120),
                        Text(parseHtmlString(mCategoryModel[index].name), maxLines: 2, textAlign: TextAlign.center, style: boldTextStyle(size: 14, color: white)).paddingOnly(bottom: 4)
                      ],
                    ),
                  ).onTap(() {
                    ViewAllScreen(mCategoryModel[index].name, isCategory: true, categoryId: mCategoryModel[index].id).launch(context);
                  });
                },
              ),
            )
          : SizedBox();
    }

    Widget carousel() {
      return mSliderModel.isNotEmpty
          ? Container(
              height: 200,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView(
                    controller: bannerPageController,
                    onPageChanged: (i) {
                      setState(() {});
                    },
                    children: mSliderModel.map((i) {
                      return Container(
                        decoration: boxDecorationWithRoundedCorners(borderRadius: radius(10), border: Border.all(color: textSecondaryColorGlobal.withOpacity(0.4))),
                        margin: EdgeInsets.only(left: 12, right: 12),
                        child: commonCacheImageWidget(i.image.validate(), height: 180, width: double.infinity, fit: BoxFit.fill).cornerRadiusWithClipRRect(10),
                      ).onTap(() {
                        if (i.url!.isNotEmpty) {
                          WebViewExternalProductScreen(mExternal_URL: i.url, title: i.title).launch(context);
                        } else {
                          toast('Sorry');
                        }
                      });
                    }).toList(),
                  ),
                  8.height,
                  DotIndicator(
                    pageController: bannerPageController,
                    pages: mSliderModel,
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
              ),
            )
          : SizedBox();
    }

    Widget mSaleBannerWidget() {
      return mSaleBanner.isNotEmpty
          ? ListView.builder(
              itemCount: mSaleBanner.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemBuilder: (context, i) {
                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 210,
                      padding: EdgeInsets.only(bottom: 20),
                      child: commonCacheImageWidget(mSaleBanner[i].image.validate(), width: double.infinity, fit: BoxFit.cover),
                    ).onTap(() {
                      SaleScreen(startDate: mSaleBanner[i].startDate, endDate: mSaleBanner[i].endDate, title: mSaleBanner[i].title).launch(context);
                    }),
                    Container(
                      margin: EdgeInsets.only(left: 30, right: 30),
                      width: context.width(),
                      padding: EdgeInsets.all(8),
                      decoration: boxDecorationRoundedWithShadow(8, backgroundColor: Theme.of(context).cardTheme.color!),
                      child: Column(
                        children: [
                          Text(mSaleBanner[i].title!, style: boldTextStyle(color: primaryColor)),
                          2.height,
                          Text(appLocalization.translate('lbl_sale_start_from')! + " " + mSaleBanner[i].startDate.validate() + " to " + mSaleBanner[i].endDate.validate(),
                              style: secondaryTextStyle(size: 12)),
                        ],
                      ),
                    )
                  ],
                ).paddingOnly(bottom: 16).visible(mSaleBanner[i].title!.isNotEmpty && mSaleBanner[i].image!.isNotEmpty);
              },
            )
          : SizedBox();
    }

    Widget _newProduct() {
      return Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(builderResponse.dashboard!.newProduct!.title!, style: GoogleFonts.alata(fontSize: 23, color: context.iconColor)),
              4.height,
              SizedBox(width: context.width() * 0.48, child: DashedRect(gap: 3, color: context.iconColor)),
            ],
          ).visible(mNewestProductModel.isNotEmpty),
          4.height,
          viewAllNewDashBoard3(context, viewAll: builderResponse.dashboard!.newProduct!.viewAll!).onTap(() {
            ViewAllScreen(builderResponse.dashboard!.newProduct!.title, isNewest: true).launch(context);
          }).visible(mNewestProductModel.length >= TOTAL_DASHBOARD_ITEM),
          productList(mNewestProductModel).visible(mNewestProductModel.isNotEmpty),
        ],
      );
    }

    Widget _featureProduct() {
      return Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              4.height,
              Text(
                builderResponse.dashboard!.featureProduct!.title!,
                style: GoogleFonts.alata(fontSize: 23, color: context.iconColor),
              ),
              4.height,
              SizedBox(width: context.width() * 0.51, child: DashedRect(gap: 3, color: context.iconColor)),
            ],
          ).visible(mFeaturedProductModel.isNotEmpty),
          4.height,
          viewAllNewDashBoard3(context, viewAll: builderResponse.dashboard!.featureProduct!.viewAll!).onTap(() {
            ViewAllScreen(builderResponse.dashboard!.featureProduct!.title, isFeatured: true).launch(context);
          }).visible(mFeaturedProductModel.length >= TOTAL_DASHBOARD_ITEM),
          productList(mFeaturedProductModel).visible(mFeaturedProductModel.isNotEmpty),
        ],
      );
    }

    Widget _dealOfTheDay() {
      return Column(
        children: [
          availableOfferAndDeal(builderResponse.dashboard!.dealOfTheDay!.title!, mDealProductModel).visible(mDealProductModel.isNotEmpty),
        ],
      );
    }

    Widget _bestSelling() {
      return Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              8.height,
              Text(builderResponse.dashboard!.bestSaleProduct!.title!, style: GoogleFonts.alata(fontSize: 23, color: context.iconColor)),
              4.height,
              SizedBox(width: context.width() * 0.35, child: DashedRect(gap: 3, color: context.iconColor)),
            ],
          ).visible(mSellingProductModel.isNotEmpty),
          4.height,
          viewAllNewDashBoard3(context, viewAll: builderResponse.dashboard!.bestSaleProduct!.viewAll!).onTap(() {
            ViewAllScreen(builderResponse.dashboard!.bestSaleProduct!.title, isBestSelling: true).launch(context);
          }).visible(mSellingProductModel.length >= TOTAL_DASHBOARD_ITEM),
          productList(mSellingProductModel).visible(mSellingProductModel.isNotEmpty),
        ],
      );
    }

    Widget _saleProduct() {
      return Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                builderResponse.dashboard!.saleProduct!.title!,
                style: GoogleFonts.alata(fontSize: 23, color: context.iconColor),
              ),
              4.height,
              SizedBox(width: context.width() * 0.5, child: DashedRect(gap: 3, color: context.iconColor)),
            ],
          ).visible(mSaleProductModel.isNotEmpty),
          4.height,
          viewAllNewDashBoard3(context, viewAll: builderResponse.dashboard!.saleProduct!.viewAll!).onTap(() {
            ViewAllScreen(builderResponse.dashboard!.saleProduct!.title, isSale: true).launch(context);
          }).visible(mSaleProductModel.length >= TOTAL_DASHBOARD_ITEM),
          productList(mSaleProductModel).visible(mSaleProductModel.isNotEmpty),
        ],
      );
    }

    Widget _offer() {
      return Column(
        children: [
          availableOfferAndDeal(builderResponse.dashboard!.offerProduct!.title!, mOfferProductModel).visible(mOfferProductModel.isNotEmpty),
        ],
      );
    }

    Widget _suggested() {
      return Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              8.height,
              Text(
                builderResponse.dashboard!.suggestionProduct!.title!,
                style: GoogleFonts.alata(fontSize: 23, color: context.iconColor),
              ),
              4.height,
              SizedBox(width: context.width() * 0.75, child: DashedRect(gap: 3, color: context.iconColor)),
            ],
          ).visible(mSuggestedProductModel.isNotEmpty),
          4.height,
          viewAllNewDashBoard3(context, viewAll: builderResponse.dashboard!.suggestionProduct!.viewAll!).onTap(() {
            ViewAllScreen(
              builderResponse.dashboard!.suggestionProduct!.title,
              isSpecialProduct: true,
              specialProduct: "suggested_for_you",
            ).launch(context);
          }).visible(mSuggestedProductModel.length >= TOTAL_DASHBOARD_ITEM),
          productList(mSuggestedProductModel).visible(mSuggestedProductModel.isNotEmpty),
        ],
      );
    }

    Widget _youMayLike() {
      return Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                builderResponse.dashboard!.youMayLikeProduct!.title!,
                style: GoogleFonts.alata(fontSize: 23, color: context.iconColor),
              ),
              4.height,
              SizedBox(width: context.width() * 0.44, child: DashedRect(gap: 3, color: context.iconColor)),
            ],
          ).visible(mYouMayLikeProductModel.isNotEmpty),
          4.height,
          viewAllNewDashBoard3(context, viewAll: builderResponse.dashboard!.youMayLikeProduct!.viewAll!).onTap(() {
            ViewAllScreen(
              builderResponse.dashboard!.youMayLikeProduct!.title,
              isSpecialProduct: true,
              specialProduct: "you_may_like",
            ).launch(context);
          }).visible(mYouMayLikeProductModel.length >= TOTAL_DASHBOARD_ITEM),
          productList(mYouMayLikeProductModel).visible(mYouMayLikeProductModel.isNotEmpty),
        ],
      );
    }

    Widget mBottom() {
      return Container(
        color: appStore.isDarkModeOn ? Theme.of(context).dividerColor.withOpacity(0.02) : Theme.of(context).cardTheme.color!.withOpacity(0.5),
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          children: [
            Container(width: 40, color: Theme.of(context).dividerColor, height: 4),
            10.height,
            Text("'" + mQuotes[rnd.nextInt(mQuotes.length)]! + "'", style: secondaryTextStyle(), textAlign: TextAlign.center),
          ],
        ),
      );
    }

    Widget body = ListView(
      shrinkWrap: true,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: builderResponse.dashboard == null ? 0 : builderResponse.dashboard!.sorting!.length,
          itemBuilder: (_, index) {
            if (builderResponse.dashboard!.sorting![index] == 'slider') {
              return carousel().visible(builderResponse.dashboard!.sliderView!.enable!);
            } else if (builderResponse.dashboard!.sorting![index] == 'categories') {
              return _category().visible(builderResponse.dashboard!.category!.enable!).paddingTop(8);
            } else if (builderResponse.dashboard!.sorting![index] == 'Sale_Banner') {
              return mSaleBannerWidget().visible(builderResponse.dashboard!.saleBanner!.enable!).paddingTop(8);
            } else if (builderResponse.dashboard!.sorting![index] == 'newest_product') {
              return _newProduct().visible(builderResponse.dashboard!.newProduct!.enable!).paddingTop(16);
            } else if (builderResponse.dashboard!.sorting![index] == 'vendor') {
              return mVendorDashBoard3Widget(context, mVendorModel, builderResponse.dashboard!.vendor!.title, builderResponse.dashboard!.vendor!.viewAll)
                  .visible(builderResponse.dashboard!.vendor!.enable!)
                  .paddingTop(8);
            } else if (builderResponse.dashboard!.sorting![index] == 'feature_products') {
              return _featureProduct().visible(builderResponse.dashboard!.featureProduct!.enable!).paddingTop(8);
            } else if (builderResponse.dashboard!.sorting![index] == 'deal_of_the_day') {
              return _dealOfTheDay().visible(builderResponse.dashboard!.dealOfTheDay!.enable!).paddingTop(8);
            } else if (builderResponse.dashboard!.sorting![index] == 'best_selling_product') {
              return _bestSelling().visible(builderResponse.dashboard!.bestSaleProduct!.enable!).paddingTop(8);
            } else if (builderResponse.dashboard!.sorting![index] == 'sale_product') {
              return _saleProduct().visible(builderResponse.dashboard!.saleProduct!.enable!).paddingTop(8);
            } else if (builderResponse.dashboard!.sorting![index] == 'offer') {
              return _offer().visible(builderResponse.dashboard!.offerProduct!.enable!).paddingTop(8);
            } else if (builderResponse.dashboard!.sorting![index] == 'suggested_for_you') {
              return _suggested().visible(builderResponse.dashboard!.suggestionProduct!.enable!).paddingTop(8);
            } else if (builderResponse.dashboard!.sorting![index] == 'you_may_like') {
              return _youMayLike().visible(builderResponse.dashboard!.youMayLikeProduct!.enable!).paddingTop(8);
            } else {
              return 0.height;
            }
          },
        ),
        mBottom().visible(!mIsLoading && isDone == true)
      ],
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: mTop(
          context,
          appLocalization.translate('app_name'),
          actions: [
            IconButton(
              icon: Icon(Icons.search_sharp, color: white),
              onPressed: () {
                SearchScreen().launch(context);
              },
            )
          ],
        ) as PreferredSizeWidget?,
        key: scaffoldKey,
        body: RefreshIndicator(
          backgroundColor: Theme.of(context).cardTheme.color,
          onRefresh: () {
            return fetchDashboardData();
          },
          child: BodyCornerWidget(
            child: Stack(
              alignment: Alignment.center,
              children: [
                body.visible(!mIsLoading),
                mDashBoard2Progress().center().visible(mIsLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
