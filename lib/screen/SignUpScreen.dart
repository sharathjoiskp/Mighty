import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/network/rest_apis.dart';
import 'package:mightystore/screen/DashBoardScreen.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';
import 'AppBarWidget.dart';

class SignUpScreen extends StatefulWidget {
  static String tag = '/SignUpScreen';
  final String? userName;

  const SignUpScreen({Key? key, this.userName}) : super(key: key);

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  var isLoading = false;
  var fNameCont = TextEditingController();
  var lNameCont = TextEditingController();
  var emailCont = TextEditingController();
  var usernameCont = TextEditingController();
  var passwordCont = TextEditingController();
  var confirmPasswordCont = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  signUpApi() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);
      var request = {
        'first_name': fNameCont.text,
        'last_name': lNameCont.text,
        'user_email': emailCont.text,
        'user_login': widget.userName != null
            ? widget.userName!.isNotEmpty
                ? widget.userName
                : usernameCont.text
            : usernameCont.text,
        'user_pass': widget.userName != null
            ? widget.userName!.isNotEmpty
                ? widget.userName
                : passwordCont.text
            : passwordCont.text,
      };
      log("Request" + request.toString());
      setState(() {
        isLoading = true;
      });
      createCustomer(request).then((res) {
        if (!mounted) return;
        if (widget.userName != null) {
          if (widget.userName!.isNotEmpty) {
            var request = {"username": widget.userName, "password": widget.userName};
            log("Request" + request.toString());
            signInApi(request);
          } else {
            toast('Register Successfully');
            finish(context);
          }
        } else {
          toast('Register Successfully');
          Navigator.pop(context);
        }
        setState(() {
          isLoading = false;
        });
      }).catchError((error) {
        setState(() {
          isLoading = false;
        });
        toast(error.toString());
      });
    }
  }

  void socialLogin(req) async {
    setState(() {
      isLoading = true;
    });
    await socialLoginApi(req).then((res) async {
      if (!mounted) return;
      await getCustomer(res['user_id']).then((response) async {
        if (!mounted) return;

        await setValue(IS_SOCIAL_LOGIN, true);
        await setValue(AVATAR, req['photoURL']);
        await setValue(USER_ID, res['user_id']);
        await setValue(FIRST_NAME, res['first_name']);
        await setValue(LAST_NAME, res['last_name']);
        await setValue(USER_EMAIL, res['user_email']);
        await setValue(USERNAME, res['user_nicename']);
        await setValue(TOKEN, res['token']);
        await setValue(USER_DISPLAY_NAME, res['user_display_name']);
        await setValue(IS_LOGGED_IN, true);
        setState(() {
          isLoading = false;
        });
        DashBoardScreen().launch(context, isNewTask: true);
      }).catchError((error) {
        setState(() {
          isLoading = false;
        });
        toast(error.toString());
      });
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      toast(error.toString());
    });
  }

  void signInApi(req) async {
    setState(() {
      isLoading = true;
    });
    await login(req).then((res) async {
      if (!mounted) return;
      await setValue(USER_ID, res['user_id']);
      await setValue(FIRST_NAME, res['first_name']);
      await setValue(LAST_NAME, res['last_name']);
      await setValue(USER_EMAIL, res['user_email']);
      await setValue(USERNAME, res['user_nicename']);
      await setValue(TOKEN, res['token']);
      await setValue(AVATAR, res['avatar']);
      if (res['profile_image'] != null) {
        await setValue(PROFILE_IMAGE, res['profile_image']);
      }
      await setValue(USER_DISPLAY_NAME, res['user_display_name']);
      await setValue(BILLING, jsonEncode(res['billing']));
      await setValue(SHIPPING, jsonEncode(res['shipping']));
      await setValue(IS_LOGGED_IN, true);
      if (widget.userName!.isNotEmpty) {
        await setValue(IS_SOCIAL_LOGIN, true);
      }
      setState(() {
        isLoading = false;
      });
      DashBoardScreen().launch(context, isNewTask: true);
    }).catchError((error) {
      print("Error" + error.toString());
      setState(() {
        isLoading = false;
      });
      toast(error.toString());
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
        appBar: mTop(context, "", showBack: true) as PreferredSizeWidget?,
        bottomNavigationBar: createRichText(
            textAlign: TextAlign.center,
            list: [
          TextSpan(text:appLocalization.translate('lbl_already_have_account'), style: primaryTextStyle(size: 18, color: Theme.of(context).textTheme.subtitle1!.color)),
          TextSpan(text:appLocalization.translate('lbl_sign_in')!, style: TextStyle(fontSize: 18, color: primaryColor))
        ]).onTap((){
          finish(context);
        }).paddingAll(16),
        body: BodyCornerWidget(
          child: Stack(
            children: <Widget>[
              Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: SingleChildScrollView(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      Text(appLocalization.translate('lbl_create_account')!, style: boldTextStyle(color: primaryColor, size: 30)),
                      16.height,
                      Row(
                        children: [
                          Expanded(
                            child: EditText(
                                hintText: appLocalization.translate('hint_first_name'),
                                isPassword: false,
                                mController: fNameCont,
                                validator: (String? v) {
                                  if (v!.trim().isEmpty) return appLocalization.translate('error_first_name_required');
                                  if (!v.trim().isAlpha()) return appLocalization.translate('error_only_alphabet');
                                  return null;
                                }),
                          ),
                          8.width,
                          Expanded(
                            child: EditText(
                                hintText: appLocalization.translate('hint_last_name'),
                                isPassword: false,
                                mController: lNameCont,
                                validator: (String? v) {
                                  if (v!.trim().isEmpty) return appLocalization.translate('error_last_name_required');
                                  if (!v.trim().isAlpha()) return appLocalization.translate('error_only_alphabet');
                                  return null;
                                }),
                          )
                        ],
                      ),
                      spacing_standard_new.height,
                      EditText(
                          hintText: appLocalization.translate('lbl_email'),
                          isPassword: false,
                          mController: emailCont,
                          validator: (String? v) {
                            if (v!.trim().isEmpty) return appLocalization.translate('error_email_required');
                            if (!v.trim().validateEmail()) return appLocalization.translate('error_wrong_email');
                            return null;
                          }),
                      spacing_standard_new.height,
                      EditText(
                          hintText: appLocalization.translate('hint_Username'),
                          isPassword: false,
                          mController: usernameCont,
                          validator: (String? v) {
                            if (v!.trim().isEmpty) return appLocalization.translate('error_username_require');
                            return null;
                          }).visible(widget.userName.isEmptyOrNull),
                      spacing_standard_new.height,
                      EditText(
                          hintText: appLocalization.translate('hint_password'),
                          isPassword: true,
                          isSecure: true,
                          mController: passwordCont,
                          validator: (String? v) {
                            if (v!.trim().isEmpty) return appLocalization.translate('error_pwd_require');
                            return null;
                          }).visible(widget.userName.isEmptyOrNull),
                      spacing_standard_new.height.visible(widget.userName.isEmptyOrNull),
                      EditText(
                          hintText: appLocalization.translate('hint_confirm_password'),
                          isPassword: true,
                          isSecure: true,
                          mController: confirmPasswordCont,
                          validator: (String? v) {
                            if (v!.trim().isEmpty) return appLocalization.translate('error_confirm_pwd_require');
                            if (confirmPasswordCont.text != passwordCont.text) return appLocalization.translate('error_pwd_not_match');
                            return null;
                          }).visible(widget.userName.isEmptyOrNull),
                      spacing_standard_new.height,
                      AppButton(
                          width: context.width(),
                          text: appLocalization.translate('lbl_sign_up_link'),
                          textStyle: primaryTextStyle(color: white),
                          color: primaryColor,
                          onTap: () {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              isLoading = true;
                              signUpApi();
                            }
                          }),
                      16.height
                    ]).paddingAll(16),
                  ),
                ),
              ),
              isLoading ? Container(child: mProgress(), alignment: Alignment.center) : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
