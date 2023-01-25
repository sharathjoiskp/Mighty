import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mightystore/AppTheme.dart';
import 'package:mightystore/Store/AppStore.dart';
import 'package:mightystore/app_localizations.dart';
import 'package:mightystore/models/BuilderResponse.dart';
import 'package:mightystore/models/LanguageModel.dart';
import 'package:mightystore/screen/AboutUsScreen.dart';
import 'package:mightystore/screen/BlogListScreen.dart';
import 'package:mightystore/screen/CategoriesScreen.dart';
import 'package:mightystore/screen/ChangePasswordScreen.dart';
import 'package:mightystore/screen/DashBoardScreen.dart';
import 'package:mightystore/screen/EditProfileScreen.dart';
import 'package:mightystore/screen/HomeScreen/HomeScreen.dart';
import 'package:mightystore/screen/MyCartScreen.dart';
import 'package:mightystore/screen/OrderListScreen.dart';
import 'package:mightystore/screen/PlaceOrderScreen.dart';
import 'package:mightystore/screen/SignInScreen.dart';
import 'package:mightystore/screen/SignUpScreen.dart';
import 'package:mightystore/screen/SplashScreen.dart';
import 'package:mightystore/screen/VendorListScreen.dart';
import 'package:mightystore/screen/WishListScreen.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

BuilderResponse builderResponse = BuilderResponse();
OneSignal oneSignal = OneSignal();
Color? primaryColor;
Color? colorAccent;
Color? textPrimaryColour;
Color? textSecondaryColour;
Color? backgroundColor;
String? baseUrl;
// ignore: non_constant_identifier_names
String? ConsumerKey;
// ignore: non_constant_identifier_names
String? ConsumerSecret;
AppStore appStore = AppStore();
Language? language;
List<Language> languages = Language.getLanguages();

Future<String> loadBuilderData() async {
  return await rootBundle.loadString('assets/builder.json');
}

Future<BuilderResponse> loadContent() async {
  String jsonString = await loadBuilderData();
  final jsonResponse = json.decode(jsonString);
  return BuilderResponse.fromJson(jsonResponse);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = stripPaymentPublishKey;
  if (isIos) {
    Stripe.merchantIdentifier = "YOUR_App_Identifier";
    await Stripe.instance.applySettings();
  }
  if (isMobile) {
    await oneSignal.setAppId(mOneSignalAPPKey);

    OneSignal.shared.setNotificationWillShowInForegroundHandler((OSNotificationReceivedEvent? event) {
      return event?.complete(event.notification);
    });

    oneSignal.disablePush(false);
    oneSignal.consentGranted(true);
    oneSignal.requiresUserPrivacyConsent();

    await Firebase.initializeApp();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }
  await initialize();

  appStore.setCount(getIntAsync(CARTCOUNT, defaultValue: 0));
  appStore.setNotification(getBoolAsync(IS_NOTIFICATION_ON, defaultValue: true));

  builderResponse = await loadContent();

  await setValue(PRIMARY_COLOR, builderResponse.appsetup!.primaryColor);
  await setValue(SECONDARY_COLOR, builderResponse.appsetup!.secondaryColor);
  await setValue(TEXT_PRIMARY_COLOR, builderResponse.appsetup!.textPrimaryColor);
  await setValue(TEXT_SECONDARY_COLOR, builderResponse.appsetup!.textSecondaryColor);
  await setValue(BACKGROUND_COLOR, builderResponse.appsetup!.backgroundColor);
  await setValue(APP_URL, builderResponse.appsetup!.appUrl);
  await setValue(CONSUMER_KEY, builderResponse.appsetup!.consumerKey);
  await setValue(CONSUMER_SECRET, builderResponse.appsetup!.consumerSecret);

  primaryColor = getColorFromHex(getStringAsync(PRIMARY_COLOR), defaultColor: Color(0xFF4358DD));
  colorAccent = getColorFromHex(getStringAsync(SECONDARY_COLOR), defaultColor: Color(0xFF2635DF));
  textPrimaryColour = getColorFromHex(getStringAsync(TEXT_PRIMARY_COLOR), defaultColor: Color(0xFF212121));
  textSecondaryColour = getColorFromHex(getStringAsync(TEXT_SECONDARY_COLOR), defaultColor: Color(0xFF757575));
  backgroundColor = getColorFromHex(getStringAsync(BACKGROUND_COLOR), defaultColor: Color(0xFFf3f5f9));
  baseUrl = getStringAsync(APP_URL);
  ConsumerKey = getStringAsync(CONSUMER_KEY);
  ConsumerSecret = getStringAsync(CONSUMER_SECRET);

  appStore.setLanguage(getStringAsync(LANGUAGE, defaultValue: defaultLanguage));

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp();

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appStore.isDarkMode! ? ThemeMode.dark : ThemeMode.light,
          supportedLocales: Language.languagesLocale(),
          localizationsDelegates: [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
          localeResolutionCallback: (locale, supportedLocales) => locale,
          locale: Locale(appStore.selectedLanguageCode),
          home: SplashScreen(),
          routes: <String, WidgetBuilder>{
            SignInScreen.tag: (BuildContext context) => SignInScreen(),
            AboutUsScreen.tag: (BuildContext context) => AboutUsScreen(),
            ChangePasswordScreen.tag: (BuildContext context) => ChangePasswordScreen(),
            HomeScreen.tag: (BuildContext context) => HomeScreen(),
            DashBoardScreen.tag: (BuildContext context) => DashBoardScreen(),
            EditProfileScreen.tag: (BuildContext context) => EditProfileScreen(),
            MyCartScreen.tag: (BuildContext context) => MyCartScreen(),
            OrderList.tag: (BuildContext context) => OrderList(),
            SignUpScreen.tag: (BuildContext context) => SignUpScreen(),
            WishListScreen.tag: (BuildContext context) => WishListScreen(),
            CategoriesScreen.tag: (BuildContext context) => CategoriesScreen(),
            PlaceOrderScreen.tag: (BuildContext context) => PlaceOrderScreen(),
            VendorListScreen.tag: (BuildContext context) => VendorListScreen(),
            BlogListScreen.tag: (BuildContext context) => BlogListScreen(),
          },
          builder: scrollBehaviour(),
        );
      },
    );
  }
}

class SBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
