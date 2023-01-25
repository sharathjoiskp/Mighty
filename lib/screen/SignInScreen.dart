import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/network/rest_apis.dart';
import 'package:mightystore/screen/AppBarWidget.dart';
import 'package:mightystore/screen/DashBoardScreen.dart';
import 'package:mightystore/screen/MobileNumberSignInScreen.dart';
import 'package:mightystore/screen/SignUpScreen.dart';
import 'package:mightystore/service/LoginService.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:mightystore/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

import '../app_localizations.dart';

class SignInScreen extends StatefulWidget {
  static String tag = '/SignInScreen';

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool passwordVisible = false;
  bool isLoading = false;

  TextEditingController usernameCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    if (Platform.isIOS) {
      //check for ios if developing for both android & ios
      TheAppleSignIn.onCredentialRevoked!.listen((_) {
        print("Credentials revoked");
      });
    }
    if (!getBoolAsync(IS_SOCIAL_LOGIN) && getBoolAsync(IS_REMEMBERED)) {
      usernameCont.text = getStringAsync(USER_EMAIL);
      passwordCont.text = getStringAsync(PASSWORD);
    }
    setState(() {});
  }

  save() async {}

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;
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
        if (res['store_profile_image'] != null) {
          await setValue(PROFILE_IMAGE, res['store_profile_image']);
        }
        await setValue(USER_DISPLAY_NAME, res['user_display_name']);
        await setValue(BILLING, jsonEncode(res['billing']));
        await setValue(SHIPPING, jsonEncode(res['shipping']));
        await setValue(IS_LOGGED_IN, true);
        await setValue(PASSWORD, passwordCont.text.toString());

        FirebaseAuth.instance.signOut();
        await setValue(IS_REMEMBERED, getBoolAsync(IS_REMEMBERED));
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
          await setValue(BILLING, jsonEncode(res['billing']));
          await setValue(SHIPPING, jsonEncode(res['shipping']));
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

    void onGoogleSignInTap() async {
      var service = LoginService();
      await service.signInWithGoogle().then((res) {
        socialLogin(res);
      }).catchError((e) {
        toast(e.toString());
      });
    }

    saveAppleDataWithoutEmail() async {
      await getSharedPref().then((pref) {
        log(getStringAsync('appleEmail'));
        log(getStringAsync('appleGivenName'));
        log(getStringAsync('appleFamilyName'));

        var req = {
          'email': getStringAsync('appleEmail'),
          'firstName': getStringAsync('appleGivenName'),
          'lastName': getStringAsync('appleFamilyName'),
          'photoURL': '',
          'accessToken': '12345678',
          'loginType': 'apple',
        };
        socialLogin(req);
      });
    }

    saveAppleData(result) async {
      await setValue('appleEmail', result.credential.email);
      await setValue('appleGivenName', result.credential.fullName.givenName);
      await setValue('appleFamilyName', result.credential.fullName.familyName);

      log('Email:- ${getStringAsync('appleEmail')}');
      log('appleGivenName:- ${getStringAsync('appleGivenName')}');
      log('appleFamilyName:- ${getStringAsync('appleFamilyName')}');

      var req = {
        'email': result.credential.email,
        'firstName': result.credential.fullName.givenName,
        'lastName': result.credential.fullName.familyName,
        'photoURL': '',
        'accessToken': '12345678',
        'loginType': 'apple',
      };
      socialLogin(req);
    }

    void appleLogIn() async {
      if (await TheAppleSignIn.isAvailable()) {
        final AuthorizationResult result = await TheAppleSignIn.performRequests([
          AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
        ]);
        switch (result.status) {
          case AuthorizationStatus.authorized:
            log("Result: $result"); //All the required credentials
            if (result.credential!.email == null) {
              saveAppleDataWithoutEmail();
            } else {
              saveAppleData(result);
            }
            break;
          case AuthorizationStatus.error:
            log("Sign in failed: ${result.error!.localizedDescription}");
            break;
          case AuthorizationStatus.cancelled:
            log('User cancelled');
            break;
        }
      } else {
        toast('Apple SignIn is not available for your device');
      }
    }

    Widget socialButtons = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(8),
          child: Image.asset(ic_google, width: 35, height: 35),
        ).onTap(() {
          onGoogleSignInTap();
        }).visible(enableSignWithGoogle == true),
        8.width,
        Container(
          padding: EdgeInsets.all(8),
          child: Image.asset(ic_mobile, width: 35, height: 35, color: appStore.isDarkModeOn ? white : Theme.of(context).iconTheme.color),
        ).onTap(() {
          MobileNumberSignInScreen().launch(context);
        }).visible(enableSignWithOtp == true),
        8.width,
        Container(
          padding: EdgeInsets.all(8),
          child: Image.asset(ic_apple, width: 35, height: 35, color: appStore.isDarkModeOn ? white : Theme.of(context).iconTheme.color),
        ).onTap(() {
          appleLogIn();
        }).visible(Platform.isIOS && enableSignWithApple == true),
      ],
    );
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: mTop(context, "", showBack: true) as PreferredSizeWidget?,
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(appLocalization.translate('lbl_dont_t_have_an_account')!, style: primaryTextStyle(size: 18, color: Theme.of(context).textTheme.subtitle1!.color)),
            Container(
              margin: EdgeInsets.only(left: 4),
              child: GestureDetector(
                  child: Text(
                    appLocalization.translate('lbl_sign_up_link')!,
                    style: TextStyle(fontSize: 18, color: primaryColor),
                  ),
                  onTap: () {
                    SignUpScreen().launch(context);
                  }),
            )
          ],
        ).paddingAll(16),
        body: BodyCornerWidget(
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      50.height,
                      Text(appLocalization.translate('lbl_welcome')!, style: boldTextStyle(color: primaryColor, size: 30)).paddingOnly(left: 16, right: 16),
                      Text(appLocalization.translate('lbl_back')!, style: primaryTextStyle(color: primaryColor, size: 30)).paddingOnly(left: 16, right: 16),
                      24.height,
                      EditText(
                        hintText: appLocalization.translate('hint_Username'),
                        isPassword: false,
                        isSecure: false,
                        mController: usernameCont,
                        validator: (String? v) {
                          if (v!.trim().isEmpty) return appLocalization.translate('error_username_require');

                          return null;
                        },
                      ).paddingOnly(left: 16, right: 16),
                      16.height,
                      EditText(
                        hintText: appLocalization.translate('hint_password'),
                        isPassword: true,
                        mController: passwordCont,
                        isSecure: true,
                        validator: (String? v) {
                          if (v!.trim().isEmpty) return appLocalization.translate('error_pwd_require');
                          return null;
                        },
                      ).paddingOnly(left: 16, right: 16),
                      8.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CustomTheme(
                                child: Checkbox(
                                  focusColor: primaryColor,
                                  activeColor: primaryColor,
                                  value: getBoolAsync(IS_REMEMBERED, defaultValue: false),
                                  onChanged: (bool? value) async {
                                    await setValue(IS_REMEMBERED, value);
                                    setState(() {});
                                  },
                                ),
                              ),
                              Text(appLocalization.translate('lbl_remember_me')!, style: secondaryTextStyle(size: 16)).onTap(() async {
                                await setValue(IS_REMEMBERED, !getBoolAsync(IS_REMEMBERED));
                                setState(() {});
                              })
                            ],
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(appLocalization.translate('lbl_forgot_password')!, style: secondaryTextStyle(size: 16, color: primaryColor)).onTap(() {
                              showDialog(context: context, builder: (BuildContext context) => CustomDialog());
                            }),
                          ).expand(),
                        ],
                      ).paddingRight(16),
                      20.height,
                      AppButton(
                              width: context.width(),
                              textStyle: primaryTextStyle(color: white),
                              text: appLocalization.translate('lbl_sign_in'),
                              onTap: () {
                                hideKeyboard(context);
                                if (formKey.currentState!.validate()) {
                                  formKey.currentState!.save();
                                  var request = {"username": "${usernameCont.text}", "password": "${passwordCont.text}"};
                                  isLoading = true;
                                  signInApi(request);
                                }
                              },
                              color: primaryColor)
                          .paddingOnly(left: 16, right: 16),
                      20.height,
                      socialButtons.visible(enableSocialSign == true)
                    ],
                  ).paddingOnly(top: 16, bottom: 16),
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

// ignore: must_be_immutable
class CustomDialog extends StatefulWidget {
  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  var email = TextEditingController();
  bool mIsLoading = false;

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;
    forgotPwdApi() async {
      hideKeyboard(context);
      var request = {'email': email.text};

      forgetPassword(request).then((res) {
        mIsLoading = false;
        toast('Successfully Send Email');
        finish(context);
      }).catchError((error) {
        mIsLoading = false;
        toast(error.toString());
      });
      setState(() {});
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: radius(10)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: boxDecorationWithRoundedCorners(borderRadius: radius(10), backgroundColor: Theme.of(context).cardTheme.color!),
        child: SingleChildScrollView(
          child: Stack(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(appLocalization.translate('lbl_forgot_password')!, style: boldTextStyle(color: primaryColor, size: 24))
                    .paddingOnly(left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble(), top: spacing_standard_new.toDouble()),
                16.height,
                EditText(
                    hintText: appLocalization.translate('hint_enter_your_email_id'),
                    isPassword: false,
                    mController: email,
                    validator: (String? v) {
                      if (v!.trim().isEmpty) return appLocalization.translate('error_email_required');
                      if (!v.trim().validateEmail()) return appLocalization.translate('error_wrong_email');
                      return null;
                    }).paddingOnly(left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble(), bottom: spacing_standard.toDouble()),
                AppButton(
                    width: context.width(),
                    text: appLocalization.translate('lbl_submit'),
                    textStyle: primaryTextStyle(color: white),
                    color: primaryColor,
                    onTap: () {
                      if (!accessAllowed) {
                        toast("Sorry");
                        return;
                      }
                      if (email.text.isEmpty)
                        toast(appLocalization.translate('hint_Email')! + (' ') + appLocalization.translate('error_field_required')!);
                      else if (!email.text.validateEmail()) {
                        toast(appLocalization.translate('error_wrong_email'));
                      } else
                        forgotPwdApi();
                    }).paddingAll(spacing_standard_new.toDouble())
              ],
            ),
            mProgress().center().visible(mIsLoading),
          ]),
        ),
      ),
    );
  }
}
