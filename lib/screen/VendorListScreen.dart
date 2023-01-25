import 'package:flutter/material.dart';
import 'package:mightystore/component/VendorListComponent.dart';
import 'package:mightystore/models/ProductResponse.dart';
import 'package:mightystore/network/rest_apis.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:nb_utils/nb_utils.dart';
import '../app_localizations.dart';
import 'AppBarWidget.dart';

class VendorListScreen extends StatefulWidget {
  static String tag = '/VendorListScreen';

  @override
  _VendorListScreenState createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  List<VendorResponse> mVendorList = [];
  bool isLoading = false;
  String mErrorMsg = '';

  @override
  void initState() {
    super.initState();
    fetchVendorData();
  }

  Future fetchVendorData() async {
    setState(() {
      isLoading = true;
    });
    await getVendor().then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        Iterable list = res;
        mVendorList = list.map((model) => VendorResponse.fromJson(model)).toList();
        mErrorMsg = '';
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        mErrorMsg = error.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: mTop(context, appLocalization.translate('lbl_vendors'), showBack: true) as PreferredSizeWidget?,
        body: BodyCornerWidget(
          child: mInternetConnection(
            mVendorList.isNotEmpty
                ? Stack(
                    children: <Widget>[
                      VendorListComponent(mVendorList: mVendorList),
                      mProgress().center().visible(isLoading),
                    ],
                  )
                : Center(child: mProgress()),
          ),
        ),
      ),
    );
  }
}
