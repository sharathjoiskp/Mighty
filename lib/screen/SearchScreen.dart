import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mightystore/component/Product.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/models/ProductAttribute.dart';
import 'package:mightystore/models/ProductResponse.dart';
import 'package:mightystore/models/SearchRequest.dart';
import 'package:mightystore/network/rest_apis.dart';
import 'package:mightystore/screen/EmptyScreen.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';

class SearchScreen extends StatefulWidget {
  static String tag = '/SearchScreen';

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  List<ProductResponse> mProductModel = [];
  List<ProductAttribute> mAttributes = [];
  List<Terms> mTerms = [];
  List<Attribute> mAttributeModel = [];
  bool isLoading = false;
  int page = 1;
  var mErrorMsg = '';
  var searchText = "";
  var isSearchDone = false;
  var controller = TextEditingController();
  var focusNode = FocusNode();
  var isAttributesLoaded = false;
  var searchRequest = SearchRequest();
  var scrollController = new ScrollController();
  int? noPages;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {
        searchText = controller.text;
      });
    });
    init();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  init() async {
    getAttributes();
    scrollController.addListener(() {
      scrollHandler();
    });
  }

  void onTextChange(String value) async {
    log(value);
    setState(() {
      searchText = value;
      searchRequest.text = value;
      page = 1;
    });
    searchProducts();
  }

  scrollHandler() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent && noPages! > page && !isLoading) {
      page++;
      searchProducts();
    }
  }

  searchProducts() async {
    setState(() {
      isLoading = true;
    });
    var req = {"text": searchText, "attribute": searchRequest.attribute ?? [], "price": searchRequest.price ?? [], "page": page};
    log(searchRequest.toJson());
    await searchProduct(req).then((res) {
      if (!mounted) return;
      log(res);
      setState(() {
        isLoading = false;
      });
      ProductListResponse listResponse = ProductListResponse.fromJson(res);
      setState(() {
        isSearchDone = true;
        if (page == 1) {
          mProductModel.clear();
        }
        noPages = listResponse.numOfPages;
        mProductModel.addAll(listResponse.data!);
        isLoading = false;
        if (mProductModel.isEmpty) {
          mErrorMsg = "No Data Found";
        }
      });
    }).catchError((error) {
      log(error);
      setState(() {
        isLoading = false;
        mErrorMsg = "No Data Found";
        isSearchDone = true;
        if (page == 1) {
          mProductModel.clear();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    setValue(CARTCOUNT, appStore.count);

    var appLocalization = AppLocalizations.of(context)!;
    Widget body = StaggeredGridView.countBuilder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      crossAxisCount: 2,
      staggeredTileBuilder: (index) {
        return StaggeredTile.fit(1);
      },
      mainAxisSpacing: 0,
      crossAxisSpacing: 0,
      padding: EdgeInsets.only(left: 8, right: 8),
      physics: NeverScrollableScrollPhysics(),
      itemCount: mProductModel.length,
      itemBuilder: (_, index) {
        return Product(mProductModel: mProductModel[index]);
      },
    );

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80.0),
          child: Stack(
            children: [
              Container(
                height: 75,
                color: primaryColor,
              ),
              AppBar(
                  elevation: 0,
                  backgroundColor: primaryColor,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: white),
                    onPressed: () {
                      finish(context);
                    },
                  ),
                  title: TextFormField(
                    autofocus: true,
                    controller: controller,
                    focusNode: focusNode,
                    textInputAction: TextInputAction.search,
                    onFieldSubmitted: onTextChange,
                    cursorColor: Colors.white,
                    style: secondaryTextStyle(color: Colors.white, size: 16),
                    decoration: InputDecoration(
                        hintText: appLocalization.translate('lbl_search'),
                        hintStyle: secondaryTextStyle(color: Colors.white, size: 16),
                        border: OutlineInputBorder(borderRadius: radius(10), borderSide: BorderSide.none),
                        contentPadding: EdgeInsets.only(left: 0, right: 0)),
                  ),
                  actions: [
                    IconButton(
                        icon: Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            controller.clear();
                          });
                        }).visible(searchText.isNotEmpty),
                    IconButton(
                        onPressed: () {
                          if (!isAttributesLoaded) {
                            toast(appLocalization.translate("lbl_please_wait"));
                            return;
                          }
                          showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                              builder: (context) => FilterScreen(mAttributeModel, mTerms, (List<Map<String?, Object?>> attribute) {
                                    setState(() {
                                      searchRequest.attribute = attribute.cast<Map<String, Object>>();
                                      page = 1;
                                    });
                                    searchProducts();
                                  }));
                        },
                        icon: Icon(Icons.filter_list, size: 24, color: Colors.white))
                  ],
                  automaticallyImplyLeading: false),
              Container(
                margin: EdgeInsets.only(top: 60),
                decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)), color: Theme.of(context).scaffoldBackgroundColor),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                  controller: scrollController,
                  child: Column(children: [
                    body,
                    mProgress().paddingAll(spacing_standard_new.toDouble()).visible(isLoading && page > 1),
                  ])).visible(mProductModel.isNotEmpty),
              Center(child: mProgress()).visible(isLoading && page == 1),
              Center(child: EmptyScreen()).visible(mErrorMsg.isNotEmpty && !isLoading && mProductModel.isEmpty),
            ],
          ),
        ),
      ),
    );
  }

  void getAttributes() async {
    await getProductAttribute().then((res) {
      if (!mounted) return;
      ProductAttribute mAttributess = ProductAttribute.fromJson(res);
      List<Terms> list = [];
      List<Attribute> list1 = [];
      mAttributess.attribute!.forEach((element) {
        list1.add(element);
        list.add(Terms(name: element.name, isParent: true, isSelected: false));
        element.terms!.forEach((term) {
          list.add(term);
        });
      });
      setState(() {
        isAttributesLoaded = true;
        mTerms.addAll(list);
        mAttributeModel.addAll(list1);
      });
    }).catchError((error) {
      log(error);
      setState(() {
        isAttributesLoaded = false;
      });
    });
  }
}

int selectedIndex = 0;

// ignore: must_be_immutable
class FilterScreen extends StatefulWidget {
  List<Attribute> mAttributeModel = [];
  List<Terms> mTerms = [];
  final void Function(List<Map<String?, Object?>>) onDataChange;

  FilterScreen(this.mAttributeModel, this.mTerms, this.onDataChange);

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    selectedIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;
    return SafeArea(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        margin: EdgeInsets.only(top: 25),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            ListView(
              children: [
                50.height,
                Divider(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: isMobile ? 3 : 2,
                      child: ListView.separated(
                          separatorBuilder: (context, index) {
                            return SizedBox();
                          },
                          scrollDirection: Axis.vertical,
                          itemCount: widget.mAttributeModel.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            var selectedCount = 0;
                            widget.mAttributeModel[index].total = selectedCount;
                            return Container(

                              padding: EdgeInsets.fromLTRB(16, 10, 10, 10),
                              margin: EdgeInsets.all(8),
                              decoration: boxDecorationWithRoundedCorners(backgroundColor: selectedIndex == index ? primaryColor!.withOpacity(0.2) : Colors.transparent,),
                              child: Text(
                                widget.mAttributeModel[index].name!,
                                style: primaryTextStyle(color: selectedIndex == index ? primaryColor : Theme.of(context).textTheme.subtitle2!.color),
                                maxLines: 2,
                              ),
                            ).onTap(() {
                              setState(() {
                                selectedIndex = index;
                                setState(() {});
                              });
                            });
                          }),
                    ),
                    Container(height: context.height(),width: 0.4,color: context.dividerColor,),
                    Expanded(flex: isMobile ? 5 : 7, child: getCurrentList(selectedIndex))
                  ],
                )
              ],
            ),
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                height: 50,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(appLocalization.translate("action_filter")!, style: boldTextStyle()),
                    Text(appLocalization.translate("lbl_clear_all")!.toUpperCase(), style: boldTextStyle(color: primaryColor)).onTap(() {
                      setState(() {
                        widget.mTerms.forEach((term) {
                          term.isSelected = false;
                        });
                      });
                    }),
                  ],
                ).paddingOnly(left: 16, right: 16, bottom: 4),
              ),
            ),
            Container(
              width: double.infinity,
              height: 50,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Container(
                        height: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          boxShadow: <BoxShadow>[
                            BoxShadow(color: Theme.of(context).hoverColor.withOpacity(0.8), blurRadius: 15.0, offset: Offset(0.0, 0.75)),
                          ],
                        ),
                        child: Text(
                          appLocalization.translate("lbl_close")!.toUpperCase(),
                          style: secondaryTextStyle(size: 18),
                        )).onTap(() {
                      setState(() {
                        finish(context);
                      });
                    }),
                  ),
                  Expanded(
                      child: Container(
                    height: double.infinity,
                    alignment: Alignment.center,
                    color: primaryColor,
                    child: Text(appLocalization.translate("lbl_apply")!, style: secondaryTextStyle(size: 18, color: white)),
                  ).onTap(
                    () {
                      var map = Map<String?, List<int?>>();
                      widget.mAttributeModel.forEach((storeProductAttribute) {
                        storeProductAttribute.terms!.forEach((element) {
                          if (element.isSelected!) {
                            if (map.containsKey(element.taxonomy)) {
                              map[element.taxonomy]?.add(element.termId);
                            } else {
                              List<int?> list = [];
                              list.add(element.termId);
                              map[element.taxonomy] = list;
                            }
                          }
                        });
                      });
                      List<Map<String?, Object?>> list = [];
                      map.keys.forEach((key) {
                        Map<String?, Object?> attribute = Map<String?, Object?>();
                        attribute[key] = map[key];
                        list.add(attribute);
                      });
                      widget.onDataChange(list);
                      finish(context);
                    },
                  )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getCurrentList(int index) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: widget.mAttributeModel[index].terms!.length,
      itemBuilder: (context, i) {
        return Container(
          padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
          child: Row(
            children: <Widget>[
              Container(
                width: 18,
                height: 18,
                padding: EdgeInsets.all(2),
                decoration: boxDecorationWithRoundedCorners(
                  borderRadius: radius(10),
                  border: Border.all(
                    color: widget.mAttributeModel[index].terms![i].isSelected! ? primaryColor! : Theme.of(context).textTheme.subtitle2!.color!,
                  ),
                ),
                child: Icon(
                  Icons.done,
                  color: primaryColor,
                  size: 12,
                ).visible(widget.mAttributeModel[index].terms![i].isSelected!),
              ),
              16.width,
              Expanded(
                child: Text(
                  widget.mAttributeModel[index].terms![i].name!,
                  style: secondaryTextStyle(size: 16, color: widget.mAttributeModel[index].terms![i].isSelected! ? primaryColor : Theme.of(context).textTheme.subtitle1!.color),
                ),
              ),
            ],
          ).onTap(
            () {
              setState(() {
                widget.mAttributeModel[index].terms![i].isSelected = !widget.mAttributeModel[index].terms![i].isSelected!;
              });
            },
          ),
        );
      },
    );
  }
}
