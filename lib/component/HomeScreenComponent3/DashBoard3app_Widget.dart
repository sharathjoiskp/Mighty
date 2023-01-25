import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/models/ProductResponse.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class DashBoard3PriceWidget extends StatefulWidget {
  static String tag = '/PriceWidget';
  var price;
  double? size = 22.0;
  Color? color;
  var isLineThroughEnabled = false;

  DashBoard3PriceWidget({Key? key, this.price, this.color, this.size, this.isLineThroughEnabled = false}) : super(key: key);

  @override
  PriceWidgetState createState() => PriceWidgetState();
}

class PriceWidgetState extends State<DashBoard3PriceWidget> {
  var currency = '₹';
  Color? primaryColor;

  @override
  void initState() {
    super.initState();
    get();
  }

  get() async {
    setState(() {
      currency = getStringAsync(DEFAULT_CURRENCY);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLineThroughEnabled) {
      return Text('$currency${widget.price.toString().replaceAll(".00", "")}', style: boldTextStyle(size: widget.size!.toInt(), color: widget.color != null ? widget.color : primaryColor));
    } else {
      return widget.price.toString().isNotEmpty
          ? Text('$currency${widget.price.toString().replaceAll(".00", "")}', style: TextStyle(fontSize: widget.size, color: widget.color ?? textPrimaryColor, decoration: TextDecoration.lineThrough))
          : Text('');
    }
  }
}

Widget mDashBoard3Sale(ProductResponse product) {
  return Positioned(
    left: 0,
    top: 0,
    child: Container(
      decoration: boxDecorationWithRoundedCorners(backgroundColor: Colors.red, borderRadius: radius(0)),
      child: Text("Sale", style: secondaryTextStyle(color: white, size: 12)),
      padding: EdgeInsets.fromLTRB(6, 2, 6, 2),
    ),
  ).visible(product.onSale == true);
}

Widget viewAllNewDashBoard3(BuildContext context, {String? viewAll}) {
  return GestureDetector(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(viewAll!, style: secondaryTextStyle(size: 14, color: appStore.isDarkMode! ? white : gray)).paddingTop(3),
        Icon(Icons.chevron_right, size: 24, color: appStore.isDarkMode! ? white : gray),
      ],
    ),
  );
}

Widget viewAllDashBoard3(BuildContext context, {String? viewAll}) {
  return GestureDetector(
    child: Container(
        width: 80,
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(border: Border.all(color: appStore.isDarkMode! ? context.iconColor : white), borderRadius: BorderRadius.circular(8)),
        child: Text(viewAll!, style: boldTextStyle(color: appStore.isDarkMode! ? context.iconColor : white), textAlign: TextAlign.center)),
  );
}
