import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/models/ProductDetailResponse.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ZoomImageScreen extends StatefulWidget {
  final mProductImage;
  final List<ImageModel>? mImgList;

  ZoomImageScreen({Key? key, this.mProductImage, this.mImgList}) : super(key: key);

  @override
  _ZoomImageScreenState createState() => _ZoomImageScreenState();
}

class _ZoomImageScreenState extends State<ZoomImageScreen> {
  List<Widget> productImg = [];

  Future productDetail() async {
    widget.mImgList!.forEach((element) {
      productImg.add(commonCacheImageWidget(element.src.toString(), fit: BoxFit.cover, height: 400, width: double.infinity));
    });
  }

  @override
  void dispose() {
    setStatusBarColor(primaryColor!, statusBarBrightness: Brightness.light);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: mTop(context, "", showBack: true) as PreferredSizeWidget?,
        body: Container(
          child: PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(widget.mImgList![index].src!), initialScale: PhotoViewComputedScale.contained, heroAttributes: PhotoViewHeroAttributes(tag: widget.mImgList![index].id!));
            },
            backgroundDecoration: boxDecorationWithRoundedCorners(borderRadius: radius(0), backgroundColor: Theme.of(context).scaffoldBackgroundColor) as BoxDecoration?,
            itemCount: widget.mImgList!.length,
            loadingBuilder: (context, event) => Center(
              child: Container(
                alignment: Alignment.center,
                child: Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 4,
                  margin: EdgeInsets.all(4),
                  shape: RoundedRectangleBorder(borderRadius: radius(50)),
                  child: Container(
                    width: 45,
                    height: 45,
                    padding: EdgeInsets.all(8.0),
                    child: Theme(
                      data: ThemeData(accentColor: primaryColor),
                      child: CircularProgressIndicator(strokeWidth: 3, value: event == null ? 0 : event.cumulativeBytesLoaded / event.expectedTotalBytes!),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
