import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mightystore/component/LayoutSelection.dart';
import 'package:mightystore/component/Product.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/models/CategoryData.dart';
import 'package:mightystore/models/ProductAttribute.dart';
import 'package:mightystore/models/ProductResponse.dart';
import 'package:mightystore/models/SearchRequest.dart';
import 'package:mightystore/network/rest_apis.dart';
import 'package:mightystore/screen/SubCategoryScreen.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/common.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:mightystore/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import 'AppBarWidget.dart';
import 'ProductDetailScreen/ProductDetailScreen.dart';
import 'ProductDetailScreen/ProductDetailScreen2.dart';
import 'ProductDetailScreen/ProductDetailScreen3.dart';

// ignore: must_be_immutable
class ViewAllScreen extends StatefulWidget {
  static String tag = '/ViewAllScreen';
  bool? isFeatured = false;
  bool? isNewest = false;
  bool? isSpecialProduct = false;
  bool? isBestSelling = false;
  bool? isSale = false;
  bool? isCategory = false;
  int? categoryId = 0;
  String? specialProduct = "";
  String? startDate = "";
  String? endDate = "";
  String? headerName = "";

  ViewAllScreen(this.headerName, {this.isFeatured, this.isSale, this.isCategory, this.categoryId, this.isNewest, this.isSpecialProduct, this.isBestSelling, this.specialProduct, this.startDate, this.endDate});

  @override
  ViewAllScreenState createState() => ViewAllScreenState();
}

class ViewAllScreenState extends State<ViewAllScreen> {
  String errorMsg = '';
  List<ProductResponse> mProductModel = [];
  List<Category> mCategoryModel = [];
  List<ProductAttribute> mAttributes = [];
  var searchRequest = SearchRequest();
  var scrollController = ScrollController();
  int page = 1;
  int? noPages;
  int crossAxisCount = 2;
  bool mIsLoggedIn = false;
  bool isLastPage = false, isListViewSelected = false, isLoading = false, isLoadingMoreData = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    var crossAxisCount1 = getIntAsync(CROSS_AXIS_COUNT, defaultValue: 2);
    mIsLoggedIn = getBoolAsync(IS_LOGGED_IN, defaultValue: false);
    setState(() {
      crossAxisCount = crossAxisCount1;
    });

    if (widget.isCategory == true) {
      fetchCategoryData();
      fetchSubCategoryData();
    } else {
      searchRequest.onSale = widget.isSale != null
          ? widget.isSale!
              ? "_sale_price"
              : ""
          : "";
      searchRequest.featured = widget.isFeatured != null
          ? widget.isFeatured!
              ? "product_visibility"
              : ""
          : "";
      searchRequest.bestSelling = widget.isBestSelling != null
          ? widget.isBestSelling!
              ? "total_sales"
              : ""
          : "";
      searchRequest.newest = widget.isNewest != null
          ? widget.isNewest!
              ? "newest"
              : ""
          : "";
      searchRequest.specialProduct = widget.isSpecialProduct != null
          ? widget.isSpecialProduct!
              ? widget.specialProduct
              : ""
          : "";
      page = 1;
      getAllProducts();
    }
    scrollController.addListener(() {
      scrollHandler();
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  Widget _productListWidget(ProductResponse product, BuildContext context) {
    String img = product.images!.isNotEmpty ? product.images!.first.src.validate() : '';

    return Container(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            height: 90,
            width: 90,
            decoration: boxDecorationWithRoundedCorners(borderRadius: radius(8), backgroundColor: Theme.of(context).colorScheme.background),
            child: Stack(children: [commonCacheImageWidget(img, height: 120, width: 90, fit: BoxFit.cover).cornerRadiusWithClipRRect(8), mSale(product)])),
        10.width,
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          8.height,
          Text(product.name, style: primaryTextStyle(), maxLines: 2),
          8.height,
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              PriceWidget(price: product.salePrice.validate().isNotEmpty ? product.salePrice.toString() : product.price.validate(), size: 14, color: primaryColor),
              4.width,
              PriceWidget(price: product.regularPrice.validate().toString(), size: 12, isLineThroughEnabled: true, color: Theme.of(context).textTheme.subtitle1!.color).visible(product.salePrice.validate().isNotEmpty)
            ])
          ]).paddingOnly(bottom: spacing_standard.toDouble()),
        ]).expand(),
      ]).paddingAll(8),
    );
  }

  scrollHandler() {
    if (widget.isCategory == true) {
      setState(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent && noPages! > page && !isLoading) {
          page++;
          //loadMoreCategoryData(page);
          loadMoreCategoryProduct(page);
        }
      });
    } else {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent && noPages! > page && !isLoading) {
        page++;
        getAllProducts();
      }
    }
  }

  Future loadMoreCategoryProduct(page) async {
    setState(() {
      isLoadingMoreData = true;
      isLoading = true;
    });
    var data = {"category": widget.categoryId, "page": page, "perPage": TOTAL_ITEM_PER_PAGE};
    await searchProduct(data).then((res) {
      if (!mounted) return;
      setState(() {
        isLoadingMoreData = false;
        isLoading = false;
        ProductListResponse listResponse = ProductListResponse.fromJson(res);
        setState(() {
          if (page == 1) {
            mProductModel.clear();
          }
          noPages = listResponse.numOfPages;
          mProductModel.addAll(listResponse.data!);
          isLoadingMoreData = false;
          if (mProductModel.isEmpty) {
            isLastPage = true;
          }
        });
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoadingMoreData = false;
        isLoading = false;
      });
    });
  }

  Future loadMoreCategoryData(page) async {
    setState(() {
      isLoadingMoreData = true;
    });
    isLoading = true;
    await getAllCategories(widget.categoryId, page, TOTAL_ITEM_PER_PAGE).then((res) {
      if (!mounted) return;
      setState(() {
        isLoadingMoreData = false;
        isLoading = false;
        Iterable list = res;
        mProductModel.addAll(list.map((model) => ProductResponse.fromJson(model)).toList());
        if (mProductModel.isEmpty) {
          isLastPage = true;
        }
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoadingMoreData = false;
        isLoading = false;
      });
    });
  }

  Future fetchCategoryData() async {
    setState(() {
      isLoading = true;
    });

    var data = {"category": widget.categoryId, "page": 1, "perPage": TOTAL_ITEM_PER_PAGE};

    print("Request $data");

    await searchProduct(data).then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        ProductListResponse listResponse = ProductListResponse.fromJson(res);
        setState(() {
          if (page == 1) {
            mProductModel.clear();
          }
          noPages = listResponse.numOfPages;
          mProductModel.addAll(listResponse.data!);
          isLoading = false;
        });
        print("Model" + mProductModel.toString());
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      print("Error:" + error.toString());
    });
  }

  Future fetchSubCategoryData() async {
    setState(() {
      isLoading = true;
    });
    await getSubCategories(widget.categoryId, page).then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        Iterable mCategory = res;
        mCategoryModel = mCategory.map((model) => Category.fromJson(model)).toList();
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    });
  }

  Widget mSubCategory(List<Category> category) {
    return Container(
      height: 90,
      child: ListView.builder(
        itemCount: category.length,
        padding: EdgeInsets.only(right: 12, left: 12),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () {
              SubCategoryScreen(mCategoryModel[i].name, categoryId: mCategoryModel[i].id).launch(context);
            },
            child: Container(
              margin: EdgeInsets.only(right: spacing_standard_new.toDouble()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  mCategoryModel[i].image != null
                      ? CircleAvatar(backgroundColor:context.cardColor,backgroundImage: NetworkImage(mCategoryModel[i].image!.src.validate()), radius: 25)
                      : CircleAvatar(backgroundColor:context.cardColor,backgroundImage: AssetImage(ic_placeholder_logo), radius: 25),
                  2.height,
                  Text(parseHtmlString(category[i].name), style: primaryTextStyle(size: textSizeSMedium))
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    setValue(CARTCOUNT, appStore.count);

    Widget _gridProducts = StaggeredGridView.countBuilder(
        scrollDirection: Axis.vertical,
        itemCount: mProductModel.length,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 4, right: 4),
        itemBuilder: (context, index) {
          return Product(mProductModel: mProductModel[index], width: context.width());
        },
        crossAxisCount: 2,
        staggeredTileBuilder: (index) {
          return StaggeredTile.fit(1);
        });

    Widget _listProduct = ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: mProductModel.length,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.only(right: 8, left: 8, bottom: 8),
      itemBuilder: (context, index) {
        return GestureDetector(
            onTap: () {
              if (getIntAsync(PRODUCT_DETAIL_VARIANT, defaultValue: 1) == 1) {
                ProductDetailScreen(mProId: mProductModel[index].id).launch(context);
              } else if (getIntAsync(PRODUCT_DETAIL_VARIANT, defaultValue: 1) == 2) {
                ProductDetailScreen2(mProId: mProductModel[index].id).launch(context);
              } else if (getIntAsync(PRODUCT_DETAIL_VARIANT, defaultValue: 1) == 3) {
                ProductDetailScreen3(mProId: mProductModel[index].id).launch(context);
              } else {
                ProductDetailScreen(mProId: mProductModel[index].id).launch(context);
              }
            },
            child: _productListWidget(mProductModel[index], context));
      },
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: mTop(context, parseHtmlString(widget.headerName), showBack: true, actions: [
          IconButton(
              onPressed: () {
                layoutSelectionBottomSheet(context);
              },
              icon: Image.asset(ic_dashboard, height: 20, width: 20, color: Colors.white)),
          mCart(context, mIsLoggedIn)
        ]) as PreferredSizeWidget?,
        body: BodyCornerWidget(
          child: mInternetConnection(
            Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      mSubCategory(mCategoryModel).visible(widget.isCategory != null && widget.isCategory! && mCategoryModel != null && mCategoryModel.isNotEmpty),
                      crossAxisCount == 1 ? _listProduct.visible(mProductModel.isNotEmpty) : _gridProducts.visible(mProductModel.isNotEmpty),
                      mProgress().visible(isLoading && page > 1).center()
                    ],
                  ),
                ),
                Center(child: mProgress().paddingAll(spacing_large.toDouble()).visible(isLoading && page == 1))
              ],
            ),
          ),
        ),
      ),
    );
  }

  getAllProducts() async {
    setState(() {
      isLoading = true;
      searchRequest.page = page;
    });
    await searchProduct(searchRequest.toJson()).then((res) {
      if (!mounted) return;
      log(res);
      ProductListResponse listResponse = ProductListResponse.fromJson(res);
      setState(() {
        if (page == 1) {
          mProductModel.clear();
        }
        noPages = listResponse.numOfPages;
        mProductModel.addAll(listResponse.data!);
        isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        isLoading = false;
        errorMsg = "No Data Found";
        if (page == 1) {
          mProductModel.clear();
        }
      });
    });
  }

  void layoutSelectionBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return LayoutSelection(
          crossAxisCount: crossAxisCount,
          callBack: (crossvalue) {
            crossAxisCount = crossvalue;
            setState(() {});
          },
        );
      },
    );
  }
}
