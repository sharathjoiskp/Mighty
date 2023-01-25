import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mightystore/app_localizations.dart';
import 'package:mightystore/component/BlogListComponent.dart';
import 'package:mightystore/models/BlogListResponse.dart';
import 'package:mightystore/network/rest_apis.dart';
import 'package:mightystore/screen/EmptyScreen.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import 'AppBarWidget.dart';

class BlogListScreen extends StatefulWidget {
  static String tag = '/BlogListScreen';

  @override
  BlogListScreenState createState() => BlogListScreenState();
}

class BlogListScreenState extends State<BlogListScreen> {
  List<Blog> mBlogList = [];

  ScrollController scrollController = new ScrollController();

  bool isLoading = false;

  int? page = 1, noPages;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    fetchBlogListData(1);
    scrollController.addListener(() {
      scrollHandler();
    });
  }

  scrollHandler() {
    setState(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !isLoading && noPages! > page!) {
        page = page! + 1;
        fetchBlogListData(page);
      }
    });
  }

  Future fetchBlogListData(int? page) async {
    setState(() {
      isLoading = true;
    });
    await getBlogList(page, TOTAL_BLOG_ITEM).then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        noPages = res['num_of_pages'];
        if (page == 1) mBlogList.clear();
        Iterable list = res['data'];
        mBlogList.addAll(list.map((model) => Blog.fromJson(model)).toList());
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;
    return SafeArea(
      child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: mTop(context, appLocalization.translate('lbl_blog'), showBack: true) as PreferredSizeWidget?,
          body: BodyCornerWidget(
            child: mInternetConnection(
              Stack(
                children: [
                  mBlogList.isNotEmpty
                      ? SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            children: [
                              BlogListComponent(mBlogList),
                              mProgress().center().visible(isLoading && page! > 1),
                              50.height,
                            ],
                          ),
                        )
                      : Center(child: EmptyScreen()).visible(!isLoading),
                  Center(child: mProgress().visible(isLoading && page == 1)),
                ],
              ),
            ),
          )),
    );
  }
}
