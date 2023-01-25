import 'package:flutter/material.dart';
import 'package:mightystore/models/BlogListResponse.dart';
import 'package:mightystore/screen/BlogDescriptionScreen.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/common.dart';
import 'package:mightystore/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class BlogListComponent extends StatefulWidget {
  static String tag = '/BlogListComponent';
  List<Blog> mBlogList;

  BlogListComponent(this.mBlogList);

  @override
  BlogListComponentState createState() => BlogListComponentState();
}

class BlogListComponentState extends State<BlogListComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    List<Blog> mBlogList = widget.mBlogList;
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: mBlogList.length,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return GestureDetector(
            onTap: () {
              log(mBlogList[index].iD);
              BlogDescriptionScreen(mId: mBlogList[index].iD).launch(context);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    decoration: boxDecorationWithRoundedCorners(borderRadius: radius(8), backgroundColor: Theme.of(context).colorScheme.background, border: Border.all(color: Theme.of(context).colorScheme.background)),
                    child: mBlogList[index].image != null
                        ? commonCacheImageWidget(mBlogList[index].image, width: 120, height: 120, fit: BoxFit.fill).cornerRadiusWithClipRRect(8)
                        : Image.asset(ic_placeholder_logo, height: 120, width: 120, fit: BoxFit.fill).cornerRadiusWithClipRRect(8)),
                10.width,
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(mBlogList[index].postTitle.validate(), style: boldTextStyle(size: 18), maxLines: 2, overflow: TextOverflow.ellipsis),
                  4.height,
                  Text(parseHtmlString(mBlogList[index].postContent.validate()), maxLines: 3, style: secondaryTextStyle()),
                  4.height,
                  Align(alignment: Alignment.topRight, child: Text(mBlogList[index].readableDate.validate(), style: secondaryTextStyle(), textAlign: TextAlign.justify))
                ]).expand(),
              ],
            ).paddingOnly(left: 16, right: 16, bottom: 16,top: 8));
      },
    );
  }
}
