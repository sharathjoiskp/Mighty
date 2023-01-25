import 'package:flutter/material.dart';
import 'package:mightystore/models/BlogResponse.dart';
import 'package:mightystore/network/rest_apis.dart';
import 'package:mightystore/screen/AppBarWidget.dart';
import 'package:mightystore/screen/WebViewExternalProductScreen.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/common.dart';
import 'package:mightystore/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class BlogDescriptionScreen extends StatefulWidget {
  static String tag = '/BlogDescriptionScreen';
  final int? mId;

  BlogDescriptionScreen({Key? key, this.mId}) : super(key: key);

  @override
  BlogDescriptionScreenState createState() => BlogDescriptionScreenState();
}

class BlogDescriptionScreenState extends State<BlogDescriptionScreen> {
  BlogResponse? post;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    fetchBlogDetail();
  }

  Future fetchBlogDetail() async {
    setState(() {
      isLoading = true;
    });
    log(widget.mId);
    await getBlogDetail(widget.mId).then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        post = BlogResponse.fromJson(res);
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        log("error" + error.toString());
        isLoading = false;
      });
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: mTop(
          context,
          post != null ? post!.postTitle.validate() : "",
          showBack: true,
          actions: [
            post != null
                ? IconButton(
                    icon: Icon(Icons.share_rounded, color: white),
                    onPressed: () {
                      WebViewExternalProductScreen(mExternal_URL: post!.shareUrl, title: post != null ? post!.postTitle.validate() : "").launch(context);
                    })
                : SizedBox()
          ],
        ) as PreferredSizeWidget?,
        body: BodyCornerWidget(
          child: mInternetConnection(
            Stack(
              children: [
                post != null
                    ? SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            10.height,
                            Text(post!.postTitle.validate(), style: boldTextStyle(size: 22)),
                            16.height,
                            post!.image.isEmptyOrNull
                                ? Image.asset(ic_placeholder_logo, width: context.width(), height: context.height() * 0.4, fit: BoxFit.fill)
                                : commonCacheImageWidget(post!.image.validate(), width: context.width(), height: context.height() * 0.4, fit: BoxFit.fill).cornerRadiusWithClipRRect(16),
                            8.height,
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [Text(post!.postAuthorName.validate(), style: boldTextStyle()), Text(post!.postDate.validate(), style: secondaryTextStyle())]),
                            8.height,
                            Text(parseHtmlString(post!.postContent.validate()), style: secondaryTextStyle(), textAlign: TextAlign.justify)
                          ],
                        ).paddingOnly(left: 16, right: 16, bottom: 16),
                      ).visible(!isLoading)
                    : SizedBox(),
                Center(child: mProgress()).visible(isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
