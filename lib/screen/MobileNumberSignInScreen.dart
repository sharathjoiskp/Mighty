import 'dart:convert';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mightystore/app_localizations.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/network/rest_apis.dart';
import 'package:mightystore/screen/SignUpScreen.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:mightystore/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import 'AppBarWidget.dart';
import 'DashBoardScreen.dart';

class MobileNumberSignInScreen extends StatefulWidget {
  MobileNumberSignInScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MobileNumberSignInScreenState createState() => _MobileNumberSignInScreenState();
}

class _MobileNumberSignInScreenState extends State<MobileNumberSignInScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _verificationId;
  late String phoneNo;
  late String code;
  String? smsOTP;
  String? data;
  var passwordCont = TextEditingController();
  bool isLoading = false;

  void verifyPhoneNumber() async {
    PhoneVerificationCompleted verificationCompleted = (AuthCredential phoneAuthCredential) async {
      // await _auth.signInWithCredential(phoneAuthCredential);
    };
    PhoneVerificationFailed verificationFailed = (FirebaseAuthException authException) {
      if (authException.code == 'invalid-phone-number') {
        toast('The provided phone number is not valid.');
        throw 'The provided phone number is not valid.';
      } else {
        toast(authException.toString());
        throw authException.toString();
      }
    };
    PhoneCodeSent codeSent = (String verificationId, [int? forceResendingToken]) async {
      toast('Please check your phone for the verification code.');
      _verificationId = verificationId;
      smsOTPDialog(context).then((value) {});
    };
    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout = (String verificationId) {
      //_verificationId = verificationId;
    };
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: this.phoneNo, verificationCompleted: verificationCompleted, verificationFailed: verificationFailed, codeSent: codeSent, codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    } catch (e) {
      toast("Failed to Verify Phone Number: $e");
    }
  }

  void signInWithPhoneNumber() async {
    isLoading = true;
    setState(() {});

    AuthCredential credential = PhoneAuthProvider.credential(verificationId: _verificationId, smsCode: smsOTP.validate());

    await FirebaseAuth.instance.signInWithCredential(credential).then((result) async {
      var request = {"username": this.data, "password": this.data};
      signInApi(request);
    }).catchError((e) {
      log(e);
      toast(e.toString());
      isLoading = false;
      setState(() {});
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
      await setValue(IS_SOCIAL_LOGIN, true);
      await setValue(IS_LOGGED_IN, true);
      setState(() {
        isLoading = false;
      });
      DashBoardScreen().launch(context, isNewTask: true);
    }).catchError((error) {
      log("Error" + error.toString());
      setState(() {
        isLoading = false;
      });
      if (error.toString() == "Unknown username. Check again or try your email address.") {
        finish(context);
        SignUpScreen(userName: this.data.toString()).launch(context);
      }
    });
  }

  Future<bool?> smsOTPDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(AppLocalizations.of(context)!.translate('lbl_enter_sms_code')!, style: boldTextStyle(color: Theme.of(context).textTheme.subtitle1!.color)),
          content: Container(
            height: 85,
            child: Column(
              children: [
                PinEntryTextField(
                  onSubmit: (value) {
                    this.smsOTP = value;
                  },
                ),
              ],
            ),
          ),
          contentPadding: EdgeInsets.all(10),
          actions: <Widget>[
            AppButton(
                width: context.width(),
                text: AppLocalizations.of(context)!.translate('lbl_done'),
                onTap: () {
                  hideKeyboard(context);
                  Navigator.pop(context);
                  signInWithPhoneNumber();
                },
                textStyle: primaryTextStyle(color: white),
                color: primaryColor),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: mTop(context, "", showBack: true) as PreferredSizeWidget?,
        resizeToAvoidBottomInset: false,
        body: BodyCornerWidget(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  commonCacheImageWidget(ic_mobileVerify, height: 150),
                  24.height,
                  Container(
                    decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: Theme.of(context).cardTheme.color!, borderRadius: radius(8), border: Border.all(color: Theme.of(context).textTheme.subtitle1!.color!)),
                    padding: EdgeInsets.only(left: 8),
                    child: Row(
                      children: <Widget>[
                        CountryCodePicker(
                          onChanged: (value) {
                            log("Value" + value.dialCode!);
                            this.code = value.dialCode.toString();
                          },
                          backgroundColor: Colors.transparent,
                          showFlag: true,
                          padding: EdgeInsets.all(4),
                          dialogBackgroundColor: Theme.of(context).cardTheme.color,
                          boxDecoration: boxDecorationWithRoundedCorners(borderRadius: radius(4), backgroundColor: Theme.of(context).cardTheme.color!) as BoxDecoration?,
                          textStyle: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1!.color),
                        ),
                        Container(
                          height: 30.0,
                          width: 1.0,
                          color: primaryColor,
                          margin: EdgeInsets.only(left: 10.0, right: 10.0),
                        ),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            style: secondaryTextStyle(size: 18),
                            controller: passwordCont,
                            decoration: InputDecoration(
                              counterText: "",
                              contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                              hintText: appLocalization.translate('lbl_enter_mobile_number'),
                              hintStyle: secondaryTextStyle(size: 18),
                              border: InputBorder.none,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  24.height,
                  AppButton(
                      width: context.width(),
                      text: appLocalization.translate('lbl_verify_now'),
                      onTap: () {
                        hideKeyboard(context);
                        this.phoneNo = this.code + passwordCont.text.toString();
                        this.data = passwordCont.text.toString();
                        verifyPhoneNumber();
                      },
                      textStyle: primaryTextStyle(color: white),
                      color: primaryColor),
                ],
              ).center().paddingAll(16),
              Center(child: mProgress()).visible(isLoading),
            ],
          ),
        ),
      ),
    );
  }
}
