import 'package:flutter/material.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/network/rest_apis.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';
import 'AppBarWidget.dart';

class ChangePasswordScreen extends StatefulWidget {
  static String tag = '/ChangePasswordScreen';

  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  var formKey = GlobalKey<FormState>();
  var passwordCont = TextEditingController();
  var oldPasswordCont = TextEditingController();
  var newPasswordCont = TextEditingController();
  bool isLoading = false;
  String userName = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setState(() {
      userName = getBoolAsync(IS_LOGGED_IN) != null ? getStringAsync(USERNAME) : '';
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: mTop(context, appLocalization.translate('lbl_change_pwd'), showBack: true) as PreferredSizeWidget?,
        body: BodyCornerWidget(
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Stack(
              children: <Widget>[
                SingleChildScrollView(
                    child: Column(
                  children: [
                    16.height,
                    EditText(
                        hintText: appLocalization.translate('hint_old_password'),
                        isPassword: true,
                        isSecure: true,
                        mController: oldPasswordCont,
                        validator: (String? v) {
                          if (v!.trim().isEmpty) return appLocalization.translate('error_old_pwd_require');
                          return null;
                        }),
                    16.height,
                    EditText(
                        hintText: appLocalization.translate('lbl_new_pwd'),
                        isPassword: true,
                        isSecure: true,
                        mController: newPasswordCont,
                        validator: (String? v) {
                          if (v!.trim().isEmpty) return appLocalization.translate('error_new_pwd_require');
                          return null;
                        }),
                    16.height,
                    EditText(
                        hintText: appLocalization.translate('hint_confirm_password'),
                        isPassword: true,
                        mController: passwordCont,
                        isSecure: true,
                        validator: (String? v) {
                          if (v!.trim().isEmpty) return appLocalization.translate('error_confirm_pwd_require');
                          if (!passwordCont.text.toString().contains(newPasswordCont.text.toString())) return appLocalization.translate('error_pwd_match');
                          return null;
                        }),
                    16.height,
                    AppButton(
                        width: context.width(),
                        textStyle: primaryTextStyle(color: white),
                        text: appLocalization.translate('lbl_change_now'),
                        onTap: () {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            isLoading = true;
                            var request = {'old_password': oldPasswordCont.text, 'new_password': passwordCont.text, 'username': userName};
                            setState(() {
                              isLoading = true;
                            });
                            changePassword(request).then((res) async {
                              setState(() {
                                isLoading = false;
                              });
                              await setValue(PASSWORD, passwordCont.text.trim());
                              hideKeyboard(context);
                              toast(res["message"]);
                              finish(context);
                            }).catchError((error) {
                              setState(() {
                                isLoading = false;
                              });
                              toast(error.toString());
                            });
                          } else {
                            toast('Enter Valid Password');
                          }
                        },
                        color: primaryColor)
                  ],
                ).paddingOnly(left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble())),
                Center(
                  child: Container(child: mProgress()),
                ).visible(isLoading)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
