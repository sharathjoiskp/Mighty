
import 'package:flutter/material.dart';
import 'package:mightystore/app_localizations.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/models/LayoutTypeSelectModel.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

class LayoutSelectionCategory extends StatefulWidget {
  final int? crossAxisCount;
  final Function? callBack;

  LayoutSelectionCategory({this.crossAxisCount, this.callBack});

  @override
  _LayoutSelectionCategoryState createState() => _LayoutSelectionCategoryState();
}

class _LayoutSelectionCategoryState extends State<LayoutSelectionCategory> {
  List<LayoutTypesSelection> select = [];
  int? crossvalue;

  @override
  void initState() {
    super.initState();
    init();
    crossvalue = widget.crossAxisCount;
  }

  init() async {
    select.clear();
    select.add(LayoutTypesSelection(image: 'images/mightystore/list.png', isSelected: false));
    select.add(LayoutTypesSelection(image: 'images/mightystore/twoGrid.png', isSelected: false));
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;
    return Container(
      color: primaryColor,
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(appLocalization.translate('lbl_layout')!, style: boldTextStyle(size: 18, color: Colors.white)),
          10.height,
          Container(
              height: 45,
              child: ListView.builder(
                  itemCount: select == null ? 0 : select.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                        margin: EdgeInsets.only(right: 10),
                        child: Container(
                            height: 45,
                            width: 45,
                            decoration: boxDecorationWithRoundedCorners(borderRadius: radius(10), backgroundColor: select[index].isSelected! ? Colors.black54.withOpacity(0.2) : Colors.white.withOpacity(0.2)),
                            child: IconButton(
                                icon: Image.asset(select[index].image!, height: 24, width: 24, color: select[index].isSelected! ? Colors.black : Colors.white),
                                onPressed: () async {
                                  init();
                                  select[index].isSelected = !select[index].isSelected!;
                                  setState(() {});
                                  if (index == 0)
                                    crossvalue = 1;
                                  else if (index == 1)
                                    crossvalue = 2;
                                  else if (index == 2)
                                    crossvalue = 3;
                                  else if (index == 3)
                                    crossvalue = 4;
                                  else
                                    crossvalue = 2;
                                  setValue(CATEGORY_CROSS_AXIS_COUNT, crossvalue);
                                  widget.callBack!(crossvalue);
                                  finish(context);
                                })));
                  }))
        ],
      ),
    );
  }
}