import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/models/Countries.dart';
import 'package:mightystore/models/CustomerResponse.dart';
import 'package:mightystore/network/rest_apis.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/colors.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:mightystore/utils/images.dart';
import 'package:mightystore/utils/shared_pref.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';
import 'AppBarWidget.dart';

class EditProfileScreen extends StatefulWidget {
  static String tag = '/EditProfileScreen';

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController txtFirstName = TextEditingController();
  TextEditingController txtLastName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();

  TextEditingController txtBillingFirstName = TextEditingController();
  TextEditingController txtBillingLastName = TextEditingController();
  TextEditingController txtBillingCompanyName = TextEditingController();
  TextEditingController txtBillingAddress1 = TextEditingController();
  TextEditingController txtBillingAddress2 = TextEditingController();
  TextEditingController txtBillingCity = TextEditingController();
  TextEditingController txtBillingPinCode = TextEditingController();
  TextEditingController txtBillingMobile = TextEditingController();
  TextEditingController txtBillingEmail = TextEditingController();

  TextEditingController txtShippingFirstName = TextEditingController();
  TextEditingController txtShippingLastName = TextEditingController();
  TextEditingController txtShippingCompanyName = TextEditingController();
  TextEditingController txtShippingAddress1 = TextEditingController();
  TextEditingController txtShippingAddress2 = TextEditingController();
  TextEditingController txtShippingCity = TextEditingController();
  TextEditingController txtShippingPinCode = TextEditingController();

  bool mIsLoading = true;
  bool isCheckBoxSelected = false;
  bool loadFromFile = false;

  List<Country> billingCountryList = [];
  List<CountryState> billingStateList = [];
  List<CountryState> shippingStateList = [];
  File? imageFile;
  String avatar = '';
  int? id;
  Country? selectedBillingCountry;
  CountryState? selectedBillingState;
  Country? selectedShippingCountry;
  CountryState? selectedShippingState;
  var _controller = ScrollController();

  List<MetaDataResponse>? mUser;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    avatar = getStringAsync(PROFILE_IMAGE);
    if (!await isGuestUser()) {
      getCustomerData();
    } else {
      getCustomerInfo();
    }
    Timer(
      Duration(seconds: 1),
      () => _controller.jumpTo(_controller.position.minScrollExtent),
    );
  }

  Future<void> getCustomerInfo() async {
    mIsLoading = false;

    if (getStringAsync(GUEST_USER_DATA).isNotEmpty) {
      Customer mUserData = Customer.fromJson(jsonDecode(getStringAsync(GUEST_USER_DATA)));
      txtFirstName.text = mUserData.firstName!;
      txtLastName.text = mUserData.lastName!;
      txtEmail.text = mUserData.email;
      txtBillingFirstName.text = mUserData.billing!.firstName!;
      txtBillingLastName.text = mUserData.billing!.lastName!;
      txtBillingCompanyName.text = mUserData.billing!.company!;
      txtBillingAddress1.text = mUserData.billing!.address1!;
      txtBillingAddress2.text = mUserData.billing!.address2!;
      txtBillingCity.text = mUserData.billing!.city!;
      txtBillingPinCode.text = mUserData.billing!.postcode!;
      txtBillingMobile.text = mUserData.billing!.phone!;
      txtBillingEmail.text = mUserData.billing!.email!;
      txtShippingFirstName.text = mUserData.shipping!.firstName!;
      txtShippingLastName.text = mUserData.shipping!.lastName!;
      txtShippingCompanyName.text = mUserData.shipping!.company!;
      txtShippingAddress1.text = mUserData.shipping!.address1!;
      txtShippingAddress2.text = mUserData.shipping!.address2!;
      txtShippingCity.text = mUserData.shipping!.city!;
      txtShippingPinCode.text = mUserData.shipping!.postcode!;
      isCheckBoxSelected = false;
      await setValue(FIRST_NAME, mUserData.shipping!.firstName);
      await setValue(LAST_NAME, mUserData.shipping!.lastName);
    }

    String countries = getStringAsync(COUNTRIES);
    if (countries != null) {
      await getCountries().then((value) async {
        await setValue(COUNTRIES, jsonEncode(value));
        setCountryStatePrefData(value);
      }).catchError((error) {
        setState(() {
          mIsLoading = false;
        });
        toast(error);
      });
    } else {
      setState(() {
        mIsLoading = false;
      });
      setCountryStatePrefData(jsonDecode(countries));
    }
    setState(() {});
  }

  setCountryStatePrefData(List<dynamic> value) {
    var txtBillingCountry, txtBillingState, txtShippingCountry, txtShippingState;
    if (getStringAsync(GUEST_USER_DATA).isNotEmpty) {
      Customer mUserData = Customer.fromJson(jsonDecode(getStringAsync(GUEST_USER_DATA)));
      txtBillingCountry = mUserData.billing!.country;
      txtBillingState = mUserData.billing!.state;
      txtShippingCountry = mUserData.shipping!.country;
      txtShippingState = mUserData.shipping!.state;
    }

    Iterable list = value;
    var countries = list.map((model) => Country.fromJson(model)).toList();
    setState(() {
      mIsLoading = false;
      billingCountryList.addAll(countries);
      if (billingCountryList.isNotEmpty) {
        selectedBillingCountry = billingCountryList[0];
        selectedShippingCountry = billingCountryList[0];
        if (txtBillingCountry != null || txtShippingCountry != null) {
          billingCountryList.forEach((element) {
            if (txtBillingCountry != null && txtBillingCountry.toString().isNotEmpty && element.code == txtBillingCountry) {
              selectedBillingCountry = element;
            }
            if (txtShippingCountry != null && txtShippingCountry.toString().isNotEmpty && element.code == txtShippingCountry) {
              selectedShippingCountry = element;
            }
          });
        }
        billingStateList.clear();
        shippingStateList.clear();
        billingStateList.addAll(selectedBillingCountry!.states!);
        shippingStateList.addAll(selectedShippingCountry!.states!);
        selectedBillingState = billingStateList.isNotEmpty ? billingStateList[0] : null;
        selectedShippingState = shippingStateList.isNotEmpty ? shippingStateList[0] : null;

        if (txtBillingState != null) {
          billingStateList.forEach((element) {
            if (txtBillingState != null && txtBillingState.toString().isNotEmpty && element.name == txtBillingState) {
              selectedBillingState = element;
            }
          });
        }

        if (txtShippingState != null) {
          shippingStateList.forEach((element) {
            if (txtShippingState != null && txtShippingState.toString().isNotEmpty && element.name == txtShippingState) {
              selectedShippingState = element;
            }
          });
        }
      }
    });
  }

  Future getCustomerData() async {
    id = getIntAsync(USER_ID);

    setState(() {
      mIsLoading = true;
    });

    await getCustomer(id).then((res) async {
      mIsLoading = false;
      if (!mounted) return;
      txtFirstName.text = res['first_name'];
      txtLastName.text = res['last_name'];
      txtEmail.text = res['email'];
      txtBillingFirstName.text = res['billing']['first_name'];
      txtBillingLastName.text = res['billing']['last_name'];
      txtBillingCompanyName.text = res['billing']['company'];
      txtBillingAddress1.text = res['billing']['address_1'];
      txtBillingAddress2.text = res['billing']['address_2'];
      txtBillingCity.text = res['billing']['city'];
      txtBillingPinCode.text = res['billing']['postcode'];

      txtBillingMobile.text = res['billing']['phone'];
      txtBillingEmail.text = res['billing']['email'];

      txtShippingFirstName.text = res['shipping']['first_name'];
      txtShippingLastName.text = res['shipping']['last_name'];
      txtShippingCompanyName.text = res['shipping']['company'];
      txtShippingAddress1.text = res['shipping']['address_1'];
      txtShippingAddress2.text = res['shipping']['address_2'];
      txtShippingCity.text = res['shipping']['city'];
      txtShippingPinCode.text = res['shipping']['postcode'];

      isCheckBoxSelected = false;
      await setValue(FIRST_NAME, res['first_name']);
      await setValue(LAST_NAME, res['last_name']);
      String countries = getStringAsync(COUNTRIES);

      if (countries != null) {
        await getCountries().then((value) async {
          await setValue(COUNTRIES, jsonEncode(value));
          setCountryStateData(value, res);
        }).catchError((error) {
          setState(() {
            mIsLoading = false;
          });
          toast(error);
        });
      } else {
        setState(() {
          mIsLoading = false;
        });
        setCountryStateData(jsonDecode(countries), res);
      }
      setState(() {});
    }).catchError((error) {
      if (!mounted) return;
      mIsLoading = false;
      log("Error1: " + error.toString());
    });
  }

  setCountryStateData(List<dynamic> value, res) {
    var txtBillingCountry = res['billing']['country'];
    var txtBillingState = res['billing']['state'];
    var txtShippingCountry = res['shipping']['country'];
    var txtShippingState = res['shipping']['state'];

    Iterable list = value;
    var countries = list.map((model) => Country.fromJson(model)).toList();
    setState(() {
      mIsLoading = false;
      billingCountryList.addAll(countries);
      if (billingCountryList.isNotEmpty) {
        selectedBillingCountry = billingCountryList[0];
        selectedShippingCountry = billingCountryList[0];
        if (txtBillingCountry != null || txtShippingCountry != null) {
          billingCountryList.forEach((element) {
            if (txtBillingCountry != null && txtBillingCountry.toString().isNotEmpty && element.code == txtBillingCountry) {
              selectedBillingCountry = element;
            }
            if (txtShippingCountry != null && txtShippingCountry.toString().isNotEmpty && element.code == txtShippingCountry) {
              selectedShippingCountry = element;
            }
          });
        }
        billingStateList.clear();
        shippingStateList.clear();
        billingStateList.addAll(selectedBillingCountry!.states!);
        shippingStateList.addAll(selectedShippingCountry!.states!);
        selectedBillingState = billingStateList.isNotEmpty ? billingStateList[0] : null;
        selectedShippingState = shippingStateList.isNotEmpty ? shippingStateList[0] : null;

        if (txtBillingState != null) {
          billingStateList.forEach((element) {
            if (txtBillingState != null && txtBillingState.toString().isNotEmpty && element.code == txtBillingState) {
              selectedBillingState = element;
            }
          });
        }

        if (txtShippingState != null) {
          shippingStateList.forEach((element) {
            if (txtShippingState != null && txtShippingState.toString().isNotEmpty && element.code == txtShippingState) {
              selectedShippingState = element;
            }
          });
        }
      }
    });
  }

  void fillShipping() {
    if (isCheckBoxSelected) {
      txtShippingFirstName.text = txtBillingFirstName.text;
      txtShippingLastName.text = txtBillingLastName.text;
      txtShippingCompanyName.text = txtBillingCompanyName.text;
      txtShippingAddress1.text = txtBillingAddress1.text;
      txtShippingAddress2.text = txtBillingAddress2.text;
      txtShippingCity.text = txtBillingCity.text;
      txtShippingPinCode.text = txtBillingPinCode.text;
      selectedShippingCountry = selectedBillingCountry;
      shippingStateList.clear();
      shippingStateList.addAll(selectedShippingCountry!.states!);
      selectedShippingState = shippingStateList.isNotEmpty ? selectedBillingState : null;
    } else {
      txtShippingFirstName.text = '';
      txtShippingLastName.text = '';
      txtShippingCompanyName.text = '';
      txtShippingAddress1.text = '';
      txtShippingAddress2.text = '';
      txtShippingCity.text = '';
      txtShippingPinCode.text = '';
    }
    log(txtShippingFirstName.text);

    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    setStatusBarColor(primaryColor!, statusBarIconBrightness: Brightness.light);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;
    saveUser() async {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();

        setState(() {
          mIsLoading = true;
        });
        hideKeyboard(context);

        var mBilling = Billing();
        mBilling.firstName = txtBillingFirstName.text;
        mBilling.lastName = txtBillingLastName.text;
        mBilling.company = txtBillingCompanyName.text;
        mBilling.address1 = txtBillingAddress1.text;
        mBilling.address2 = txtBillingAddress2.text;
        mBilling.city = txtBillingCity.text;
        mBilling.postcode = txtBillingPinCode.text;
        mBilling.country = selectedBillingCountry != null ? selectedBillingCountry!.code.toString() : "";
        mBilling.state = selectedBillingState != null ? selectedBillingState!.code.toString() : "";
        mBilling.email = txtBillingEmail.text;
        mBilling.phone = txtBillingMobile.text;

        var mShipping = Shipping();
        mShipping.firstName = txtShippingFirstName.text;
        mShipping.lastName = txtShippingLastName.text;
        mShipping.company = txtShippingCompanyName.text;
        mShipping.address1 = txtShippingAddress1.text;
        mShipping.address2 = txtShippingAddress2.text;
        mShipping.city = txtShippingCity.text;
        mShipping.postcode = txtShippingPinCode.text;
        mShipping.country = selectedShippingCountry != null ? selectedShippingCountry!.code.toString() : "";
        mShipping.state = selectedShippingState != null ? selectedShippingState!.code.toString() : "";

        if (await isGuestUser()) {
          setState(() {
            mIsLoading = false;
          });
          var mCustomer = Customer();
          mCustomer.firstName = "Guest";
          mCustomer.email = "Guest@gmail.com";
          mCustomer.lastName = "Guest";
          mCustomer.billing = mBilling;
          mCustomer.shipping = mShipping;
          await removeKey(GUEST_USER_DATA);
          await setValue(GUEST_USER_DATA, jsonEncode(mCustomer));
          await removeKey(SHIPPING);
          await setValue(BILLING, jsonEncode(mBilling));
          await setValue(SHIPPING, jsonEncode(mShipping));
          toast('Profile Saved');
          finish(context, true);
        } else {
          var request = {
            'email': txtEmail.text,
            'first_name': txtFirstName.text,
            'last_name': txtLastName.text,
            'billing': mBilling,
            'shipping': mShipping,
          };
          await updateCustomer(id, request).then((res) async {
            if (!mounted) return;
            setState(() {
              mIsLoading = false;
            });
            await setValue(FIRST_NAME, txtFirstName.text);
            await setValue(LAST_NAME, txtLastName.text);
            await setValue(USER_EMAIL, txtEmail.text);

            await setValue(BILLING, jsonEncode(mBilling));
            await setValue(SHIPPING, jsonEncode(mShipping));

            toast('Profile Saved');
            finish(context, true);
          }).catchError((error) {
            toast(error.toString());
            mIsLoading = false;
          });
        }
      }
    }

    Future<void> uploadImg() async {
      if (imageFile != null) {
        ConfirmAction? res = await showConfirmDialogs(
          context,
          appLocalization.translate("msg_image_confirmation"),
          appLocalization.translate("lbl_yes"),
          appLocalization.translate("lbl_no"),
        );

        if (res == ConfirmAction.ACCEPT) {
          mIsLoading = true;
          setState(() {});
          var base64Image = base64Encode(imageFile!.readAsBytesSync());
          log(base64Image);
          if (!await isGuestUser()) {
            await updateProfile(file: imageFile != null ? File(imageFile!.path) : null).then((res) async {
              if (!mounted) return;
              mIsLoading = false;
            }).catchError((error) {
              mIsLoading = false;
              toast(error.toString());
            });
          } else {
            mIsLoading = false;
            toast("Successfully image set");
            setState(() {});
          }
        }
      }
    }

    imgFromCamera() async {
      File image = File((await ImagePicker().getImage(source: ImageSource.camera, imageQuality: 100))!.path);

      setState(() {
        imageFile = image;
      });
      uploadImg();
    }

    imgFromGallery() async {
      File image = File((await ImagePicker().getImage(source: ImageSource.gallery, imageQuality: 50))!.path);

      setState(() {
        imageFile = image;
      });
      uploadImg();
    }

    void showPicker(context) {
      showModalBottomSheet(
          context: context,
          backgroundColor: Theme.of(context).cardTheme.color,
          builder: (BuildContext bc) {
            return SafeArea(
              child: Container(
                child: Wrap(
                  children: <Widget>[
                    ListTile(
                        leading: Icon(Icons.photo_library, color: Theme.of(context).iconTheme.color),
                        title: Text(appLocalization.translate('lbl_photo_library')!),
                        onTap: () {
                          imgFromGallery();
                          finish(context);
                        }),
                    ListTile(
                      leading: Icon(Icons.photo_camera, color: Theme.of(context).iconTheme.color),
                      title: Text(appLocalization.translate('lbl_camera')!),
                      onTap: () {
                        imgFromCamera();
                        finish(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          });
    }

    Widget profileImage = ClipRRect(
      borderRadius: radius(100),
      child: imageFile == null
          ? avatar.isEmpty
              ? Image.asset(User_Profile, width: 100, height: 100, fit: BoxFit.cover)
              : commonCacheImageWidget(avatar, width: 100, height: 100, fit: BoxFit.cover)
          : Image.file(imageFile!, width: 100, height: 100, fit: BoxFit.cover),
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: mTop(context, appLocalization.translate('lbl_edit_profile'), showBack: true) as PreferredSizeWidget?,
        body: BodyCornerWidget(
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: _controller,
                child: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      16.height,
                      Container(
                        margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              profileImage,
                              15.height,
                              Container(
                                height: 35,
                                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Theme.of(context).textTheme.subtitle2!.color!, width: 1), color: Theme.of(context).scaffoldBackgroundColor),
                                child: IconButton(
                                  icon: Icon(Icons.camera_alt, size: 20, color: Theme.of(context).textTheme.subtitle2!.color),
                                  onPressed: (() {
                                    showPicker(context);
                                  }),
                                ),
                              ).visible(!getBoolAsync(IS_SOCIAL_LOGIN))
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(appLocalization.translate("lbl_add_personal_detail")!, style: boldTextStyle(size: textSizeLargeMedium)),
                            16.height,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SimpleEditText(
                                    mController: txtFirstName,
                                    hintText: appLocalization.translate('hint_first_name'),
                                    validator: (String? v) {
                                      if (v!.trim().isEmpty) return appLocalization.translate('hint_first_name')! + (' ') + appLocalization.translate('error_field_required')!;
                                    },
                                  ),
                                ),
                                16.width,
                                Expanded(
                                  child: SimpleEditText(
                                    mController: txtLastName,
                                    hintText: appLocalization.translate('hint_last_name'),
                                    validator: (String? v) {
                                      if (v!.trim().isEmpty) return appLocalization.translate('hint_last_name')! + (' ') + appLocalization.translate('error_field_required')!;
                                    },
                                  ),
                                )
                              ],
                            ),
                            SimpleEditText(
                              mController: txtEmail,
                              hintText: appLocalization.translate('lbl_email'),
                              validator: (String? v) {
                                if (v!.trim().isEmpty) return appLocalization.translate('lbl_email')! + (' ') + appLocalization.translate('error_field_required')!;
                                if (!v.trim().validateEmail()) return appLocalization.translate('error_wrong_email');
                              },
                            )
                          ],
                        ).paddingOnly(left: 8, top: 16, right: 8, bottom: 16),
                      ),
                      Divider(thickness: 6, color: Theme.of(context).textTheme.headline4!.color),
                      Container(
                        margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appLocalization.translate("lbl_add_billing_address")!,
                              style: boldTextStyle(size: textSizeLargeMedium),
                            ),
                            16.height,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SimpleEditText(
                                    mController: txtBillingFirstName,
                                    hintText: appLocalization.translate('hint_first_name'),
                                    validator: (String? v) {
                                      if (v!.trim().isEmpty) return appLocalization.translate('hint_first_name')! + (' ') + appLocalization.translate('error_field_required')!;
                                      if (!v.trim().isAlpha()) return appLocalization.translate('error_only_alphabet');
                                    },
                                  ),
                                ),
                                16.width,
                                Expanded(
                                  child: SimpleEditText(
                                    mController: txtBillingLastName,
                                    hintText: appLocalization.translate('hint_last_name'),
                                    validator: (String? v) {
                                      if (v!.trim().isEmpty) return appLocalization.translate('hint_last_name')! + (' ') + appLocalization.translate('error_field_required')!;
                                      if (!v.trim().isAlpha()) return appLocalization.translate('error_only_alphabet');
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SimpleEditText(
                              mController: txtBillingCompanyName,
                              hintText: appLocalization.translate('hint_company'),
                              validator: (String? v) {
                                if (v!.trim().isEmpty) return appLocalization.translate('hint_company')! + (' ') + appLocalization.translate('error_field_required')!;
                              },
                            ),
                            SimpleEditText(
                              mController: txtBillingAddress1,
                              hintText: appLocalization.translate('hint_add1'),
                              validator: (String? v) {
                                if (v!.trim().isEmpty) return appLocalization.translate('hint_add1')! + (' ') + appLocalization.translate('error_field_required')!;
                              },
                            ),
                            SimpleEditText(
                              mController: txtBillingAddress2,
                              hintText: appLocalization.translate('hint_add2'),
                              validator: (String? v) {
                                if (v!.trim().isEmpty) return appLocalization.translate('hint_add2')! + (' ') + appLocalization.translate('error_field_required')!;
                              },
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SimpleEditText(
                                    mController: txtBillingCity,
                                    hintText: appLocalization.translate('hint_city'),
                                    validator: (String? v) {
                                      if (v!.trim().isEmpty) return appLocalization.translate('hint_city')! + (' ') + appLocalization.translate('error_field_required')!;
                                    },
                                  ),
                                ),
                                16.width,
                                Expanded(
                                  child: SimpleEditText(
                                    mController: txtBillingPinCode,
                                    keyboardType: TextInputType.number,
                                    hintText: appLocalization.translate('hint_pin_code'),
                                    validator: (String? v) {
                                      if (v!.trim().isEmpty) return appLocalization.translate('hint_pin_code')! + (' ') + appLocalization.translate('error_field_required')!;
                                      if (!v.trim().isDigit()) return appLocalization.translate('error_only_alphabet');
                                    },
                                  ),
                                )
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      SimpleEditText(),
                                      Theme(
                                        data: Theme.of(context).copyWith(canvasColor: Theme.of(context).cardTheme.color),
                                        child: DropdownButton(
                                          value: selectedBillingCountry,
                                          isExpanded: true,
                                          underline: SizedBox(),
                                          onChanged: (dynamic value) {
                                            setState(() {
                                              selectedBillingCountry = value;
                                              billingStateList.clear();
                                              billingStateList.addAll(selectedBillingCountry!.states!);
                                              selectedBillingState = selectedBillingCountry!.states!.isNotEmpty ? billingStateList[0] : null;
                                              if (isCheckBoxSelected) {
                                                selectedShippingCountry = selectedBillingCountry;
                                                shippingStateList.clear();
                                                shippingStateList.addAll(selectedShippingCountry!.states!);
                                                selectedShippingState = selectedShippingCountry!.states!.isNotEmpty ? selectedBillingState : null;
                                              }
                                            });
                                          },
                                          items: billingCountryList.map((value) {
                                            return DropdownMenuItem(
                                              value: value,
                                              child: FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Text(
                                                  value.name != null && value.name.toString().isNotEmpty ? value.name : "NA",
                                                  style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1!.color),
                                                ).paddingOnly(left: 16, right: 16, top: 8, bottom: 8),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                16.width,
                                Expanded(
                                  child: Stack(
                                    children: [
                                      SimpleEditText(),
                                      selectedBillingState != null
                                          ? Theme(
                                              data: Theme.of(context).copyWith(canvasColor: Theme.of(context).cardTheme.color),
                                              child: DropdownButton(
                                                value: selectedBillingState,
                                                isExpanded: true,
                                                underline: SizedBox(),
                                                onChanged: (dynamic value) {
                                                  setState(() {
                                                    selectedBillingState = value;
                                                    if (isCheckBoxSelected) {
                                                      selectedShippingState = selectedBillingState;
                                                    }
                                                  });
                                                },
                                                items: billingStateList.map((value) {
                                                  return DropdownMenuItem(
                                                    value: value,
                                                    child: FittedBox(
                                                      fit: BoxFit.fitWidth,
                                                      child: Text(
                                                        value.name != null && value.name.toString().isNotEmpty ? value.name : "NA",
                                                        style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1!.color),
                                                      ).paddingOnly(left: 16, right: 16, top: 8, bottom: 8),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            )
                                          : Text(
                                              "NA",
                                              style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1!.color),
                                            ).paddingOnly(top: 12, bottom: 12).center(),
                                    ],
                                  ),
                                ),
                              ],
                            ).visible(billingCountryList.isNotEmpty),
                            SimpleEditText(
                              mController: txtBillingMobile,
                              keyboardType: TextInputType.number,
                              hintText: appLocalization.translate('hint_mobile_no'),
                              validator: (String? v) {
                                if (v!.trim().isEmpty) return appLocalization.translate('hint_mobile_no')! + (' ') + appLocalization.translate('error_field_required')!;
                              },
                            ),
                            SimpleEditText(
                              mController: txtBillingEmail,
                              hintText: appLocalization.translate('lbl_email'),
                              validator: (String? v) {
                                if (v!.trim().isEmpty) return appLocalization.translate('lbl_email')! + (' ') + appLocalization.translate('error_field_required')!;
                                if (!v.trim().validateEmail()) return appLocalization.translate('error_wrong_email');
                              },
                            ),
                          ],
                        ).paddingOnly(left: 8, top: 16, right: 8, bottom: 16),
                      ),
                      Divider(thickness: 6, color: Theme.of(context).textTheme.headline4!.color),
                      Container(
                        margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(appLocalization.translate("lbl_add_shipping_detail")!, style: boldTextStyle(size: textSizeLargeMedium)).expand(),
                                Row(
                                  children: [
                                    Text(appLocalization.translate('lbl_same')!, style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle2!.color, size: textSizeMedium)),
                                    Icon(isCheckBoxSelected == true ? Icons.check_box : Icons.check_box_outline_blank, color: isCheckBoxSelected == true ? Theme.of(context).iconTheme.color : greyColor, size: 30).onTap(() {
                                      isCheckBoxSelected = !isCheckBoxSelected;
                                      fillShipping();
                                      setState(() {});
                                    })
                                  ],
                                )
                              ],
                            ),
                            16.height,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SimpleEditText(
                                    mController: txtShippingFirstName,
                                    hintText: appLocalization.translate('hint_first_name'),
                                    validator: (String? v) {
                                      if (v!.trim().isEmpty) return appLocalization.translate('hint_first_name')! + (' ') + appLocalization.translate('error_field_required')!;
                                      if (!v.trim().isAlpha()) return appLocalization.translate('error_only_alphabet');
                                    },
                                  ),
                                ),
                                16.width,
                                Expanded(
                                  child: SimpleEditText(
                                    mController: txtShippingLastName,
                                    hintText: appLocalization.translate('hint_last_name'),
                                    validator: (String? v) {
                                      if (v!.trim().isEmpty) return appLocalization.translate('hint_last_name')! + (' ') + appLocalization.translate('error_field_required')!;
                                      if (!v.trim().isAlpha()) return appLocalization.translate('error_only_alphabet');
                                    },
                                  ),
                                )
                              ],
                            ),
                            SimpleEditText(
                              mController: txtShippingCompanyName,
                              hintText: appLocalization.translate('hint_company'),
                              validator: (String? v) {
                                if (v!.trim().isEmpty) return appLocalization.translate('hint_company')! + (' ') + appLocalization.translate('error_field_required')!;
                              },
                            ),
                            SimpleEditText(
                              mController: txtShippingAddress1,
                              hintText: appLocalization.translate('hint_add1'),
                              validator: (String? v) {
                                if (v!.trim().isEmpty) return appLocalization.translate('hint_add1')! + (' ') + appLocalization.translate('error_field_required')!;
                              },
                            ),
                            SimpleEditText(
                              mController: txtShippingAddress2,
                              hintText: appLocalization.translate('hint_add2'),
                              validator: (String? v) {
                                if (v!.trim().isEmpty) return appLocalization.translate('hint_add2')! + (' ') + appLocalization.translate('error_field_required')!;
                              },
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SimpleEditText(
                                    mController: txtShippingCity,
                                    hintText: appLocalization.translate('hint_city'),
                                    validator: (String? v) {
                                      if (v!.trim().isEmpty) return appLocalization.translate('hint_city')! + (' ') + appLocalization.translate('error_field_required')!;
                                    },
                                  ),
                                ),
                                16.width,
                                Expanded(
                                  child: SimpleEditText(
                                    mController: txtShippingPinCode,
                                    hintText: appLocalization.translate('hint_pin_code'),
                                    validator: (String? v) {
                                      if (v!.trim().isEmpty) return appLocalization.translate('hint_pin_code')! + (' ') + appLocalization.translate('error_field_required')!;
                                      if (!v.trim().isDigit()) return appLocalization.translate('error_only_alphabet');
                                    },
                                  ),
                                )
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Stack(
                                  children: [
                                    SimpleEditText(),
                                    Theme(
                                      data: Theme.of(context).copyWith(canvasColor: Theme.of(context).cardTheme.color),
                                      child: DropdownButton(
                                        value: selectedShippingCountry,
                                        isExpanded: true,
                                        underline: SizedBox(),
                                        onChanged: (dynamic value) {
                                          setState(() {
                                            selectedShippingCountry = value;
                                            shippingStateList.clear();
                                            shippingStateList.addAll(selectedShippingCountry!.states!);
                                            selectedShippingState = selectedShippingCountry!.states!.isNotEmpty ? shippingStateList[0] : null;
                                          });
                                        },
                                        items: billingCountryList.map((value) {
                                          return DropdownMenuItem(
                                            value: value,
                                            child: FittedBox(
                                              fit: BoxFit.fitWidth,
                                              child: Text(
                                                value.name != null && value.name.toString().isNotEmpty ? value.name : "NA",
                                                style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1!.color),
                                              ).paddingOnly(left: 16, right: 16, top: 8, bottom: 8),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                )),
                                16.width,
                                Expanded(
                                  child: Stack(
                                    children: [
                                      SimpleEditText(),
                                      selectedShippingState != null
                                          ? Theme(
                                              data: Theme.of(context).copyWith(canvasColor: Theme.of(context).cardTheme.color),
                                              child: DropdownButton(
                                                value: selectedShippingState,
                                                isExpanded: true,
                                                underline: SizedBox(),
                                                onChanged: (dynamic value) {
                                                  setState(() {
                                                    selectedShippingState = value;
                                                  });
                                                },
                                                items: shippingStateList.map((value) {
                                                  return DropdownMenuItem(
                                                    value: value,
                                                    child: FittedBox(
                                                      fit: BoxFit.fitWidth,
                                                      child: Text(
                                                        value.name != null && value.name.toString().isNotEmpty ? value.name : "NA",
                                                        textAlign: TextAlign.center,
                                                        style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1!.color),
                                                      ).paddingOnly(left: 16, right: 16, top: 8, bottom: 8),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            )
                                          : Text(
                                              "NA",
                                              style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1!.color),
                                            ).paddingOnly(top: 12, bottom: 12).center(),
                                    ],
                                  ),
                                ),
                              ],
                            ).visible(billingCountryList.isNotEmpty),
                          ],
                        ).paddingOnly(left: 8, top: 16, right: 8),
                      ),
                    ],
                  ),
                ),
              ),
              mProgress().visible(mIsLoading).center(),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          color: Colors.transparent,
          child: AppButton(
            width: context.width(),
            textStyle: primaryTextStyle(color: white),
            text: appLocalization.translate("lbl_save"),
            color: primaryColor,
            onTap: () {
              saveUser();
            },
          ).paddingAll(16),
        ),
      ),
    );
  }
}
