import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mightystore/component/LayoutSelection.dart';
import 'package:mightystore/component/Product.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/models/CategoryData.dart';
import 'package:mightystore/models/ProductResponse.dart';
import 'package:mightystore/network/rest_apis.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/common.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import 'AppBarWidget.dart';

// ignore: must_be_immutable
class SubCategoryScreen extends StatefulWidget {
  static String tag = '/SubCategory';
  int? categoryId = 0;
  String? headerName = "";

  SubCategoryScreen(this.headerName, {this.categoryId});

  @override
  _SubCategoryScreenState createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  var scrollController = new ScrollController();

  List<ProductResponse> mProductModel = [];
  List<Category> mCategoryModel = [];

  bool isLoading = false;
  bool isLoadingMoreData = false;
  bool isLastPage = false;
  bool mIsLoggedIn = false;

  int page = 1;
  int crossAxisCount = 2;

  var sortType = -1;

  String errorMsg = '';

  @override
  void initState() {
    super.initState();
    init();
    fetchCategoryData();
    fetchSubCategoryData();
  }

  init() async {
    crossAxisCount = getIntAsync(CROSS_AXIS_COUNT, defaultValue: 2);
    mIsLoggedIn = getBoolAsync(IS_LOGGED_IN, defaultValue: false);
    scrollController.addListener(() {
      scrollHandler();
    });
    setState(() {});
  }

  scrollHandler() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !isLastPage) {
      page++;
      loadMoreCategoryData(page);
    }
  }

  Future loadMoreCategoryData(page) async {
    setState(() {
      isLoadingMoreData = true;
    });
    var data = {"category": widget.categoryId, "page": page, "perPage": TOTAL_ITEM_PER_PAGE};
    await searchProduct(data).then((res) {
      if (!mounted) return;
      ProductListResponse listResponse = ProductListResponse.fromJson(res);
      setState(() {
        if (page == 1) {
          mProductModel.clear();
        }
        mProductModel.addAll(listResponse.data!);
        isLoadingMoreData = false;
        isLastPage = false;
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLastPage = true;
        isLoadingMoreData = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  Future fetchCategoryData() async {
    setState(() {
      isLoading = true;
    });
    var data = {"category": widget.categoryId, "page": 1, "perPage": TOTAL_ITEM_PER_PAGE};
    await searchProduct(data).then((res) {
      if (!mounted) return;
      ProductListResponse listResponse = ProductListResponse.fromJson(res);
      setState(() {
        if (page == 1) {
          mProductModel.clear();
        }
        mProductModel.addAll(listResponse.data!);
        isLoading = false;
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {});
    });
  }

  Future fetchSubCategoryData() async {
    setState(() {
      isLoading = true;
    });
    await getSubCategories(widget.categoryId, page).then((res) {
      if (!mounted) return;
      setState(() {
        Iterable mCategory = res;
        mCategoryModel = mCategory.map((model) => Category.fromJson(model)).toList();
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {});
    });
  }

  Widget mSubCategory(List<Category> category) {
    return Container(
      margin: EdgeInsets.only(top: spacing_standard_new.toDouble()),
      height: MediaQuery.of(context).size.width * 0.12,
      child: ListView.builder(
        itemCount: category.length,
        padding: EdgeInsets.only(left: 16, right: 8),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () {
              SubCategoryScreen(mCategoryModel[i].name, categoryId: mCategoryModel[i].id).launch(context);
            },
            child: Container(
              margin: EdgeInsets.only(right: spacing_standard_new.toDouble()),
              decoration: boxDecorationWithRoundedCorners(borderRadius: radius(10), backgroundColor: colorAccent!),
              padding: EdgeInsets.fromLTRB(spacing_standard.toDouble(), spacing_standard.toDouble(), spacing_standard.toDouble(), spacing_standard.toDouble()),
              child: Row(
                children: <Widget>[
                  if (category[i].image != null) commonCacheImageWidget(category[i].image!.src, width: MediaQuery.of(context).size.width * 0.1, fit: BoxFit.contain),
                  4.width,
                  Text(parseHtmlString(category[i].name), style: primaryTextStyle(color: Theme.of(context).accentColor, size: textSizeSMedium)),
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

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: mTop(
          context,
          widget.headerName,
          showBack: true,
          actions: [
            IconButton(
                onPressed: () {
                  layoutSelectionBottomSheet(context);
                },
                icon: Image.asset('images/mightystore/dashboard.png', height: 24, width: 24, color: Colors.white)),
            mCart(context, mIsLoggedIn)
          ],
        ) as PreferredSizeWidget?,
        body: BodyCornerWidget(
          child: mInternetConnection(
            Stack(
              children: [
                errorMsg.isEmpty && mProductModel.isNotEmpty
                    ? SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            mSubCategory(mCategoryModel).visible(mCategoryModel.isNotEmpty),
                            StaggeredGridView.countBuilder(
                                scrollDirection: Axis.vertical,
                                itemCount: mProductModel.length,
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: EdgeInsets.only(left: 8, right: 8, bottom: 8,top: 16),
                                itemBuilder: (context, index) {
                                  return Product(mProductModel: mProductModel[index], width: context.width());
                                },
                                crossAxisCount: crossAxisCount,
                                staggeredTileBuilder: (index) {
                                  return StaggeredTile.fit(1);
                                },
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4),
                            mProgress().visible(isLoadingMoreData).center()
                          ],
                        ),
                      )
                    : Text(errorMsg),
                mProgress().paddingAll(8).center().visible(isLoading)
              ],
            ),
          ),
        ),
      ),
    );
  }

  void layoutSelectionBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return LayoutSelection(
          crossAxisCount: crossAxisCount,
          callBack: (crossValue) {
            crossAxisCount = crossValue;
            setState(() {});
          },
        );
      },
    );
  }
}
