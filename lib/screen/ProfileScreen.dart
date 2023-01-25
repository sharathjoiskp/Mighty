import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mightystore/app_localizations.dart';
import 'package:mightystore/component/ThemeSelectionDialog.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/models/LanguageModel.dart';
import 'package:mightystore/screen/AboutUsScreen.dart';
import 'package:mightystore/screen/BlogListScreen.dart';
import 'package:mightystore/screen/ChangePasswordScreen.dart';
import 'package:mightystore/screen/ChooseDemo.dart';
import 'package:mightystore/screen/DashBoardScreen.dart';
import 'package:mightystore/screen/EditProfileScreen.dart';
import 'package:mightystore/screen/OrderListScreen.dart';
import 'package:mightystore/screen/SignInScreen.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/common.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:mightystore/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:mightystore/screen/ChooseDashboardPageVariant.dart';
import 'AppBarWidget.dart';
import 'ChooseProductDetailVariant.dart';

class ProfileScreen extends StatefulWidget {
  static String tag = '/ProfileScreen';

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  String mProfileImage = '';
  String userName = '';
  String userEmail = '';

  bool isChange = false;
  bool mIsLoggedIn = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setState(() {
      mIsLoggedIn = getBoolAsync(IS_LOGGED_IN);
      userName = mIsLoggedIn ? '${getStringAsync(FIRST_NAME) + ' ' + getStringAsync(LAST_NAME)}' : '';
      userEmail = mIsLoggedIn ? getStringAsync(USER_EMAIL) : '';
      if (getStringAsync(PROFILE_IMAGE).isNotEmpty) {
        mProfileImage = getStringAsync(PROFILE_IMAGE);
        print("PROFILE_IMAGE");
      } else {
        print("PROFILE_IMAGE3");
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);

    Widget mSideMenu(var text, var icon, var tag) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [Icon(icon, color: Theme.of(context).textTheme.subtitle2!.color), 12.width, Text(text, style: primaryTextStyle())],
          ),
          Icon(Icons.chevron_right)
        ],
      ).paddingOnly(left: 16, right: 16, top: 6, bottom: 6).onTap(() {
        launchNewScreen(context, tag);
      });
    }

    Widget mOption(var text, var icon) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).textTheme.subtitle2!.color),
              12.width,
              Text(text, style: primaryTextStyle()).expand(),
            ],
          ).expand(),
          Icon(Icons.chevron_right, color: Theme.of(context).textTheme.subtitle2!.color)
        ],
      ).paddingOnly(left: 16, right: 16, top: 6, bottom: 6);
    }

    return Observer(
      builder: (_) => SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: mTop(context, appLocalization!.translate('title_account')) as PreferredSizeWidget?,
          body: BodyCornerWidget(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      mProfileImage.isNotEmpty
                          ? CircleAvatar(backgroundColor: context.cardColor, backgroundImage: NetworkImage(mProfileImage.validate()), radius: 30)
                          : CircleAvatar(backgroundImage: Image.asset(User_Profile).image, radius: 30),
                      8.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName, style: boldTextStyle()).paddingOnly(top: 2).visible(mIsLoggedIn),
                          Text(userEmail, style: boldTextStyle(color: Theme.of(context).textTheme.subtitle1!.color)).paddingOnly(top: 2).visible(mIsLoggedIn),
                        ],
                      ).paddingOnly(left: spacing_control.toDouble(), right: spacing_control.toDouble(), bottom: spacing_standard.toDouble())
                    ],
                  ).paddingOnly(left: spacing_control.toDouble()).paddingOnly(left: spacing_standard.toDouble(), right: spacing_standard.toDouble()).visible(mIsLoggedIn).onTap(() async {
                    bool? isLoad = await EditProfileScreen().launch(context);

                    if (isLoad != null) {
                      mProfileImage = getStringAsync(PROFILE_IMAGE);
                      userName = mIsLoggedIn ? '${getStringAsync(FIRST_NAME) + ' ' + getStringAsync(LAST_NAME)}' : '';
                      userEmail = mIsLoggedIn ? getStringAsync(USER_EMAIL) : '';
                      log("isLoad" + isLoad.toString());
                    } else {
                      mProfileImage = getStringAsync(PROFILE_IMAGE);
                      userName = mIsLoggedIn ? '${getStringAsync(FIRST_NAME) + ' ' + getStringAsync(LAST_NAME)}' : '';
                      userEmail = mIsLoggedIn ? getStringAsync(USER_EMAIL) : '';
                    }
                    setState(() {});
                  }),
                  Divider(height: 4, thickness: 4, color: Theme.of(context).textTheme.headline4!.color).paddingOnly(top: 16, bottom: 8).visible(mIsLoggedIn),
                  mOption(appLocalization.translate('lbl_guest_user'), Feather.user).onTap(() async {
                    await setValue(FIRST_NAME, "Guest");
                    await setValue(LAST_NAME, "");
                    await setValue(USER_EMAIL, "Guest@gmail.com");
                    await setValue(USERNAME, "Guest");
                    await setValue(USER_DISPLAY_NAME, "Guest");
                    await setValue(IS_LOGGED_IN, true);
                    await setValue(IS_GUEST_USER, true);
                    await setValue(BILLING, "");
                    await setValue(SHIPPING, "");
                    DashBoardScreen().launch(context, isNewTask: true);
                  }).visible(!mIsLoggedIn),
                  Divider().paddingOnly(left: 16, right: 16).visible(!mIsLoggedIn),
                  mSideMenu(appLocalization.translate('lbl_orders'), MaterialCommunityIcons.file_multiple_outline, OrderList.tag).visible(mIsLoggedIn && !getBoolAsync(IS_GUEST_USER)),
                  Divider().paddingOnly(left: 16, right: 16).visible(mIsLoggedIn && !getBoolAsync(IS_SOCIAL_LOGIN) && !getBoolAsync(IS_GUEST_USER)),
                  mSideMenu(appLocalization.translate('lbl_change_pwd'), MaterialCommunityIcons.lock_outline, ChangePasswordScreen.tag)
                      .visible(mIsLoggedIn && !getBoolAsync(IS_SOCIAL_LOGIN) && !getBoolAsync(IS_GUEST_USER)),
                  Divider().paddingOnly(left: 16, right: 16).visible(mIsLoggedIn && !getBoolAsync(IS_GUEST_USER)),
                  mSideMenu(appLocalization.translate('lbl_blog'), FontAwesome.list_alt, BlogListScreen.tag).visible(enableBlog == true),
                  Divider().paddingOnly(left: 16, right: 16).visible(enableBlog == true),
                  mSideMenu(appLocalization.translate('lbl_about'), MaterialCommunityIcons.information_outline, AboutUsScreen.tag),
                  Divider().paddingOnly(left: 16, right: 16),
                  mOption(appLocalization.translate('choose_dashboard_page_variant'), Icons.dashboard).onTap(() {
                    ChooseDashboardPageVariant().launch(context);
                  }).visible(enableDashboardVariant == false),
                  Divider().paddingOnly(left: 16, right: 16).visible(enableDashboardVariant == false),
                  mOption(appLocalization.translate('choose_product_detail_page_variant'), Icons.mobile_friendly).onTap(() {
                    ChooseProductDetailVariant().launch(context);
                  }).visible(enableDashboardVariant == false),
                  Divider().paddingOnly(left: 16, right: 16).visible(enableDashboardVariant == false),
                  mOption(appLocalization.translate('lbl_terms_conditions'), Icons.assignment_outlined).onTap(() {
                    redirectUrl(getStringAsync(TERMS_AND_CONDITIONS).isEmptyOrNull ? TERMS_CONDITION_URL : getStringAsync(TERMS_AND_CONDITIONS));
                  }),
                  Divider().paddingOnly(left: 16, right: 16),
                  mOption(appLocalization.translate('llb_privacy_policy'), Icons.privacy_tip_outlined).onTap(() {
                    redirectUrl(getStringAsync(PRIVACY_POLICY).isEmptyOrNull ? PRIVACY_POLICY_URL : getStringAsync(PRIVACY_POLICY));
                  }),
                  Divider().paddingOnly(left: 16, right: 16),
                  Container(
                    padding: EdgeInsets.only(left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble(), top: 6, bottom: 6),
                    child: Row(
                      children: [
                        Icon(MaterialCommunityIcons.theme_light_dark, color: Theme.of(context).textTheme.subtitle2!.color),
                        12.width,
                        Text(appLocalization.translate('lbl_select_theme')!, style: primaryTextStyle())
                      ],
                    ),
                  ).onTap(() {
                    setState(() {
                      showInDialog(
                        context,
                        child: ThemeSelectionDialog(),
                        contentPadding: EdgeInsets.zero,
                        shape: dialogShape(),
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        title: Text(appLocalization.translate('lbl_select_theme')!, style: boldTextStyle(size: 20)),
                      );
                    });
                  }),
                  Divider().paddingOnly(left: 16, right: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Ionicons.language_sharp, color: Theme.of(context).textTheme.subtitle2!.color),
                          12.width,
                          Text(appLocalization.translate('lbl_select_language')!, style: primaryTextStyle())
                        ],
                      ),
                      DropdownButton(
                        isDense: true,
                        items: languages.map((e) => DropdownMenuItem<Language>(child: Text(e.name, style: primaryTextStyle(size: 14)), value: e)).toList(),
                        dropdownColor: appStore.isDarkModeOn ? white : Theme.of(context).scaffoldBackgroundColor,
                        value: language,
                        underline: SizedBox(),
                        onChanged: (Language? v) async {
                          hideKeyboard(context);
                          appStore.setLanguage(v!.languageCode);
                        },
                      ),
                    ],
                  ).paddingOnly(left: 16, right: 16, top: 6, bottom: 6),
                  Divider().paddingOnly(left: 16, right: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(appStore.isNotificationOn ? Feather.bell : Feather.bell_off, color: Theme.of(context).textTheme.subtitle2!.color),
                          12.width,
                          Text(
                                  '${appStore.isNotificationOn ? appLocalization.translate('disable') : appLocalization.translate('enable')} ${appLocalization.translate(
                                    'push_notification',
                                  )}',
                                  style: primaryTextStyle())
                              .expand()
                        ],
                      ).expand(flex: 7),
                      Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          activeColor: primaryColor,
                          value: appStore.isNotificationOn,
                          onChanged: (v) {
                            appStore.setNotification(v);
                          },
                        ).withHeight(10),
                      ).expand()
                    ],
                  ).paddingOnly(left: 16, right: 16, top: 6, bottom: 6).onTap(() {
                    appStore.setNotification(!getBoolAsync(IS_NOTIFICATION_ON, defaultValue: true));
                  }),
                  Divider().paddingOnly(left: 16, right: 16),
                  Container(
                    padding: EdgeInsets.only(left: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble(), top: 6, bottom: 6),
                    child: Row(
                      children: [
                        Image.asset(ic_login, height: 20, width: 20, color: Theme.of(context).textTheme.subtitle2!.color),
                        12.width,
                        Text(appLocalization.translate('btn_sign_out')!, style: primaryTextStyle())
                      ],
                    ),
                  ).onTap(() async {
                    await logout(context);
                  }).visible(mIsLoggedIn),
                  Divider().paddingOnly(left: 16, right: 16).visible(mIsLoggedIn && enableMultiDemo == true),
                  mSideMenu(appLocalization.translate('lbl_sign_in'), MaterialCommunityIcons.login, SignInScreen.tag).visible(!mIsLoggedIn),
                  Divider().paddingOnly(left: 16, right: 16).visible(!mIsLoggedIn && enableMultiDemo == true),
                  mOption(appLocalization.translate('lbl_multiple_demo'), Icons.check_circle_outline_outlined).onTap(() {
                    ChooseDemo().launch(context);
                  }).visible(enableMultiDemo == true),
                  16.height,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
