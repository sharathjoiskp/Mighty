import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mightystore/component/LayoutSelectionCategory.dart';
import 'package:mightystore/models/CategoryData.dart';
import 'package:mightystore/network/rest_apis.dart';
import 'package:mightystore/screen/AppBarWidget.dart';
import 'package:mightystore/screen/EmptyScreen.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/common.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:mightystore/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';
import 'ViewAllScreen.dart';

class CategoriesScreen extends StatefulWidget {
  static String tag = '/CategoriesScreen';

  @override
  CategoriesScreenState createState() => CategoriesScreenState();
}

class CategoriesScreenState extends State<CategoriesScreen> {
  List<Category>? mCategoryModel;
  ScrollController scrollController = ScrollController();

  String errorMsg = '';

  bool isLoading = false, isLastPage = false;

  int crossAxisCount = 2;
  int page = 1;
  int noPage = 1;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    fetchCategoryData();
    crossAxisCount = getIntAsync(CATEGORY_CROSS_AXIS_COUNT, defaultValue: 2);
    scrollController.addListener(() {
      scrollHandler();
    });
    setState(() {});
  }

  scrollHandler() {
    setState(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !isLoading && isLastPage == false) {
        page++;
        loadMoreData(page);
      }
    });
  }

  Future fetchCategoryData() async {
    setState(() {
      isLoading = true;
    });
    await getCategories(1, TOTAL_CATEGORY_PER_PAGE).then((res) {
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
        errorMsg = error.toString();
      });
    });
  }

  Future loadMoreData(page) async {
    isLoading = true;
    setState(() {});
    await getCategories(page, TOTAL_CATEGORY_PER_PAGE).then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        Iterable list = res;
        mCategoryModel!.addAll(list.map((model) => Category.fromJson(model)).toList());
        if (mCategoryModel!.isEmpty) {
          isLastPage = true;
        }
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    });
  }

  void layoutSelectionBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return LayoutSelectionCategory(
          crossAxisCount: crossAxisCount,
          callBack: (crossValue) {
            crossAxisCount = crossValue;
            setState(() {});
          },
        );
      },
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var w = context.width();
    var appLocalization = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: mTop(context, appLocalization.translate('lbl_categories'), actions: [
        IconButton(
            onPressed: () {
              layoutSelectionBottomSheet(context);
            },
            icon: Image.asset(ic_dashboard, height: 20, width: 20, color: Colors.white))
      ]) as PreferredSizeWidget?,
      body: BodyCornerWidget(
        child: mInternetConnection(
          Stack(
            alignment: Alignment.topLeft,
            children: [
              mCategoryModel != null
                  ? mCategoryModel!.isNotEmpty
                      ? SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            children: [
                              8.height,
                              crossAxisCount != 1
                                  ? StaggeredGridView.countBuilder(
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      itemCount: mCategoryModel!.length,
                                      shrinkWrap: true,
                                      crossAxisCount: 2,
                                      padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            ViewAllScreen(mCategoryModel![index].name, isCategory: true, categoryId: mCategoryModel![index].id).launch(context);
                                          },
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                  decoration: boxDecorationWithRoundedCorners(
                                                      borderRadius: radius(8),
                                                      backgroundColor: Theme.of(context).colorScheme.background,
                                                      border: Border.all(color: Theme.of(context).colorScheme.background)),
                                                  child: mCategoryModel![index].image != null
                                                      ? commonCacheImageWidget(mCategoryModel![index].image!.src.validate(), height: 130, width: w, fit: BoxFit.cover).cornerRadiusWithClipRRect(8)
                                                      : Image.asset(ic_placeholder_logo, width: w, height: 130, fit: BoxFit.fill).cornerRadiusWithClipRRect(8)),
                                              Text(parseHtmlString(mCategoryModel![index].name.validate()), textAlign: TextAlign.center, style: primaryTextStyle(), maxLines: 1)
                                                  .paddingOnly(top: spacing_middle.toDouble(), left: spacing_standard.toDouble(), right: spacing_standard.toDouble())
                                            ],
                                          ),
                                        ).paddingAll(8);
                                      },
                                      staggeredTileBuilder: (int index) {
                                        return StaggeredTile.fit(1);
                                      },
                                    )
                                  : ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      itemCount: mCategoryModel!.length,
                                      shrinkWrap: true,
                                      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16,top: 8),
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            ViewAllScreen(mCategoryModel![index].name, isCategory: true, categoryId: mCategoryModel![index].id).launch(context);
                                          },
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              mCategoryModel![index].image != null
                                                  ? commonCacheImageWidget(mCategoryModel![index].image!.src, height: 80, width: 80, fit: BoxFit.cover).cornerRadiusWithClipRRect(8)
                                                  : Image.asset(ic_placeholder_logo, height: 80, width: 80, fit: BoxFit.cover).cornerRadiusWithClipRRect(8),
                                              2.width,
                                              Flexible(
                                                child: Text(parseHtmlString(mCategoryModel![index].name), textAlign: TextAlign.start, style: boldTextStyle(size: 18), maxLines: 2).paddingOnly(
                                                    top: spacing_middle.toDouble(), bottom: spacing_middle.toDouble(), left: spacing_standard.toDouble(), right: spacing_standard.toDouble()),
                                              )
                                            ],
                                          ).paddingBottom(16),
                                        );
                                      },
                                    ),
                              mProgress().center().visible(isLoading && page > 1),
                              50.height,
                            ],
                          ),
                        )
                      : EmptyScreen().center()
                  : SizedBox(),
              Center(child: mProgress().visible(isLoading && page == 1)),
            ],
          ),
        ),
      ),
    );
  }
}
