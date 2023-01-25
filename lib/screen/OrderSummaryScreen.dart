import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
import 'package:mightystore/component/PaymentAcceptComponent.dart';
import 'package:mightystore/main.dart';
import 'package:mightystore/models/CartModel.dart';
import 'package:mightystore/models/Coupon_lines.dart';
import 'package:mightystore/models/CreateOrderRequestModel.dart';
import 'package:mightystore/models/CustomerResponse.dart';
import 'package:mightystore/models/OrderModel.dart';
import 'package:mightystore/models/ShippingMethodResponse.dart';
import 'package:mightystore/network/rest_apis.dart';
import 'package:mightystore/screen/AppBarWidget.dart';
import 'package:mightystore/screen/PlaceOrderScreen.dart';
import 'package:mightystore/utils/app_Widget.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:mightystore/utils/shared_pref.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../app_localizations.dart';
import 'DashBoardScreen.dart';
import 'WebViewPaymentScreen.dart';

class OrderSummaryScreen extends StatefulWidget {
  static String tag = '/OrderSummaryScreen';

  final List<CartModel>? mCartProduct;
  final mCouponData;
  final mPrice;
  final bool isNativePayment = false;
  final ShippingLines? shippingLines;
  final Method? method;
  final double? subtotal;
  final double? mRPDiscount;
  final double? discount;

  OrderSummaryScreen({Key? key, this.mCartProduct, this.mCouponData, this.mPrice, this.shippingLines, this.method, this.subtotal, this.mRPDiscount, this.discount}) : super(key: key);

  @override
  OrderSummaryScreenState createState() => OrderSummaryScreenState();
}

class OrderSummaryScreenState extends State<OrderSummaryScreen> {
  static const platform = const MethodChannel("razorpay_flutter");

  var mPaymentList = ["Stripe Payment", "RazorPay", "Cash On Delivery"];
  var mOrderModel = OrderResponse();
  late Razorpay _razorPay;
  Method? method;
  NumberFormat nf = NumberFormat('##.00');

  String? mShippingFirstName, mShippingLastName, mShippingCompany, mShippingAddress, mShippingAddress2, mShippingCity, mShippingPostcode, mShippingCountry, mShippingState;
  String? mBillingFirstName, mBillingLastName, mBillingAddress, mBillingAddress2, mBillingCompany, mBillingCity, mBillingPostcode, mBillingCountry, mBillingState, mBillingPhone, mBillingEmail;

  bool isLoading = false;
  bool isNativePayment = false;
  bool? selectedCashDelivery;

  var mUserId, mCurrency;
  var mBilling, mShipping;
  var id;
  var isEnableCoupon;

  int? paymentIndex;
  int? _currentTimeValue = 1;

  @override
  void initState() {
    super.initState();
    _razorPay = Razorpay();
    _razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    init();
    initStripe();
  }

  initStripe() async {
    Stripe.publishableKey = "pk_test_51GrhA2Bz1ljKAgF98fI6WfB2YUn4CewOB0DNQC1pSeXspUc1LlUYs3ou19oPF0ATcqa52FXTYmv6v0mkvPZb9BSD00SUpBj9tI";
  }

  init() async {
    selectedCashDelivery = true;

    if (getStringAsync(PAYMENTMETHOD) == PAYMENT_METHOD_NATIVE) {
      isNativePayment = true;
    } else {
      isNativePayment = false;
    }
    mShipping = jsonDecode(getStringAsync(SHIPPING)) ?? "";
    if (mShipping != null) {
      mShippingFirstName = mShipping['first_name'];
      mShippingLastName = mShipping['last_name'];
      mShippingCompany = mShipping['company'];
      mShippingAddress = mShipping['address_1'];
      mShippingAddress2 = mShipping['address_2'];
      mShippingCity = mShipping['city'];
      mShippingPostcode = mShipping['postcode'];
      mShippingCountry = mShipping['country'];
      mShippingState = mShipping['state'];
    }
    mBilling = jsonDecode(getStringAsync(BILLING));

    if (mBilling != null) {
      mBillingFirstName = mBilling['first_name'];
      mBillingLastName = mBilling['last_name'];
      mBillingCompany = mBilling['company'];
      mBillingAddress = mBilling['address_1'];
      mBillingAddress2 = mBilling['address_2'];
      mBillingCity = mBilling['city'];
      mBillingPostcode = mBilling['postcode'];
      mBillingCountry = mBilling['country'];
      mBillingState = mBilling['state'];
      mBillingEmail = mBilling['email'];
      mBillingPhone = mBilling['phone'];
    }

    mUserId = getIntAsync(USER_ID) != null ? getIntAsync(USER_ID) : '';
    mCurrency = getStringAsync(DEFAULT_CURRENCY);
    setState(() {});
  }

  void createNativeOrder(String mPaymethod) async {
    hideKeyboard(context);

    var mBilling = Billing();
    mBilling.firstName = mBillingFirstName;
    mBilling.lastName = mBillingLastName;
    mBilling.company = mBillingCompany;
    mBilling.address1 = mBillingAddress;
    mBilling.address2 = mBillingAddress2;
    mBilling.city = mBillingCity;
    mBilling.postcode = mBillingPostcode;
    mBilling.country = mBillingCountry;
    mBilling.state = mBillingState;
    mBilling.email = mBillingEmail;
    mBilling.phone = mBillingPhone;

    var mShipping = Shipping();
    mShipping.firstName = mShippingFirstName;
    mShipping.lastName = mShippingLastName;
    mShipping.company = mShippingCompany;
    mShipping.address1 = mShippingAddress;
    mShipping.address2 = mShippingPostcode;
    mShipping.city = mShippingCity;
    mShipping.state = mShippingState;
    mShipping.postcode = mShippingPostcode;
    mShipping.country = mShippingCountry;

    List<LineItemsRequest> lineItems = [];
    List<ShippingLines?> shipping = [];
    widget.mCartProduct!.forEach((item) {
      var lineItem = LineItemsRequest();
      lineItem.productId = item.proId;
      lineItem.quantity = item.quantity;
      lineItem.variationId = item.proId;
      lineItems.add(lineItem);
    });

    var couponCode = widget.mCouponData;
    List<CouponLines> mCouponItems = [];
    if (couponCode.isNotEmpty) {
      var mCoupon = CouponLines();
      mCoupon.code = couponCode;
      mCouponItems.clear();
      mCouponItems.add(mCoupon);
    }

    if (widget.shippingLines != null) {
      shipping.add(widget.shippingLines);
    }

    var request = {
      'billing': mBilling,
      'shipping': mShipping,
      'line_items': lineItems,
      'payment_method': mPaymethod,
      'transaction_id': "",
      'customer_id': mUserId.toString(),
      'coupon_lines': couponCode.isNotEmpty ? mCouponItems : '',
      'status': "pending",
      'set_paid': false,
      'shipping_lines': shipping
    };
    setState(() {
      isLoading = true;
    });
    createOrderApi(request).then((response) async {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlaceOrderScreen(
            mOrderID: response['id'],
            total: widget.mPrice,
            transactionId: response['transaction_id'],
            orderKey: response['order_key'],
            paymentMethod: response['payment_method'],
            dateCreated: response['date_created'],
          ),
        ),
      );
      finish(context);
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      toast(error.toString());
    });
  }

  Future createWebViewOrder() async {
    if (!accessAllowed) {
      return;
    }

    var request = CreateOrderRequestModel();
    if (widget.shippingLines != null) {
      List<ShippingLines?> shippingLines = [];
      shippingLines.add(widget.shippingLines);
      request.shippingLines = shippingLines;
    }
    List<LineItemsRequest> lineItems = [];
    widget.mCartProduct!.forEach((item) {
      var lineItem = LineItemsRequest();
      lineItem.productId = item.proId;
      lineItem.quantity = item.quantity;
      lineItem.variationId = item.proId;
      lineItems.add(lineItem);
    });

    var shippingItem = Shipping();
    shippingItem.firstName = mShippingFirstName;
    shippingItem.lastName = mShippingLastName;
    shippingItem.address1 = mShippingAddress;
    shippingItem.company = mBillingCompany;
    shippingItem.address2 = mShippingAddress2;
    shippingItem.city = mShippingCity;
    shippingItem.state = mShippingState;
    shippingItem.postcode = mShippingPostcode;
    shippingItem.country = mShippingCountry;

    var mBilling = Billing();
    mBilling.firstName = mBillingFirstName;
    mBilling.lastName = mBillingLastName;
    mBilling.company = mBillingCompany;
    mBilling.address1 = mBillingAddress;
    mBilling.address2 = mBillingAddress2;
    mBilling.city = mBillingCity;
    mBilling.postcode = mBillingPostcode;
    mBilling.country = mShippingCountry;
    mBilling.state = mShippingState;
    mBilling.email = mBillingEmail;
    mBilling.phone = mBillingPhone;

    request.paymentMethod = "cod";
    request.transactionId = "";
    request.customerId = getIntAsync(USER_ID);
    request.status = "pending";
    request.setPaid = false;

    request.lineItems = lineItems;
    request.shipping = shippingItem;
    request.billing = mBilling;
    createOrder(request);
  }

  void createOrder(CreateOrderRequestModel mCreateOrderRequestModel) async {
    setState(() {
      isLoading = true;
    });
    await createOrderApi(mCreateOrderRequestModel.toJson()).then((response) {
      if (!mounted) return;
      processPaymentApi(response['id']);
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      toast(error.toString());
    });
  }

  processPaymentApi(var mOrderId) async {
    log(mOrderId);
    var request = {"order_id": mOrderId};
    getCheckOutUrl(request).then((res) async {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      bool isPaymentDone = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebViewPaymentScreen(checkoutUrl: res['checkout_url']),
            ),
          ) ??
          false;
      if (isPaymentDone) {
        setState(() {
          isLoading = true;
        });
        if (!await isGuestUser()) {
          clearCartItems().then((response) {
            if (!mounted) return;
            setState(() {
              isLoading = false;
            });
            appStore.setCount(0);
            launchNewScreenWithNewTask(context, DashBoardScreen.tag);
          }).catchError((error) {
            setState(() {
              isLoading = false;
            });
            toast(error.toString());
          });
        } else {
          appStore.setCount(0);
          removeKey(CART_DATA);
          launchNewScreenWithNewTask(context, DashBoardScreen.tag);
        }
      } else {
        deleteOrder(mOrderId).then((value) => {log(value)}).catchError((error) {});
        appStore.setCount(0);
      }
    }).catchError((error) {});
  }

  void onOrderNowClick() async {
    createNativeOrder("Cash On Delivery");
  }

  @override
  void dispose() {
    super.dispose();
    _razorPay.clear();
  }

  void openCheckout() async {
    var mAmount = double.parse(widget.mPrice) * 100.00;
    var options = {
      'key': razorKey,
      'amount': mAmount,
      'name': 'Mighty Store',
      'theme.color': '#4358DD',
      'description': 'Woocommerce Store',
      'image': 'https://firebasestorage.googleapis.com/v0/b/mytestApp.appspot.com/o/images%2FpZm8daajsIS4LvqBYTiWiuLIgmE2?alt=media&token=3kuli4cd-dc45-7845-b87d-5c4acc7da3c2',
      'prefill': {'contact': mBillingPhone, 'email': mBillingEmail},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorPay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Fluttertoast.showToast(msg: "SUCCESS: " + response.paymentId!);
    if (!await isGuestUser()) {
      createNativeOrder("RazorPay");
      clearCartItems().then((response) {
        if (!mounted) return;
        appStore.setCount(0);
        launchNewScreenWithNewTask(context, DashBoardScreen.tag);
        setState(() {});
      }).catchError((error) {
        isLoading = false;
        setState(() {});
        toast(error.toString());
      });
    } else {
      appStore.setCount(0);
      removeKey(CART_DATA);
      launchNewScreenWithNewTask(context, DashBoardScreen.tag);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "ERROR: " + response.code.toString() + " - " + response.message!);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "EXTERNAL_WALLET: " + response.walletName!);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: mTop(context, appLocalization.translate('lbl_order_summary'), showBack: true) as PreferredSizeWidget?,
        body: BodyCornerWidget(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    16.height,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(appLocalization.translate("lbl_shipping_address")!, style: boldTextStyle()).visible(mShippingFirstName != null),
                        spacing_control.height,
                        Text('$mShippingFirstName $mShippingLastName\n$mShippingAddress\n$mShippingCity\n$mShippingState\n$mShippingCountry\n$mShippingPostcode',
                                style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle2!.color))
                            .visible(mShippingAddress != null),
                      ],
                    ).paddingOnly(right: 16, left: 16, bottom: 16),
                    Divider(thickness: 6, color: Theme.of(context).textTheme.headline4!.color).visible(isNativePayment == true),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(appLocalization.translate('lbl_payment_methods')!, style: boldTextStyle()).paddingLeft(16),
                        spacing_standard.height,
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Theme(
                              data: Theme.of(context).copyWith(unselectedWidgetColor: Theme.of(context).iconTheme.color),
                              child: RadioListTile(
                                dense: true,
                                activeColor: primaryColor,
                                value: index,
                                groupValue: _currentTimeValue,
                                onChanged: (int? ind) {
                                  setState(() {
                                    _currentTimeValue = ind;
                                  });
                                },
                                title: Text(
                                  mPaymentList[index],
                                  style: primaryTextStyle(),
                                ),
                              ),
                            );
                          },
                          itemCount: mPaymentList.length,
                        ),
                        spacing_standard_new.height,
                      ],
                    ).paddingOnly(top: 16, bottom: 16).visible(isNativePayment == true),
                    Divider(thickness: 6, color: Theme.of(context).textTheme.headline4!.color),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(appLocalization.translate("lbl_price_detail")!, style: boldTextStyle()),
                        8.height,
                        Divider(),
                        8.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(appLocalization.translate("lbl_total_mrp")!, style: secondaryTextStyle(size: textSizeMedium)),
                            PriceWidget(price: nf.format(widget.subtotal.validate()), color: Theme.of(context).textTheme.subtitle1!.color, size: 16)
                          ],
                        ),
                        spacing_control.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(appLocalization.translate("lbl_discount_on_mrp")!, style: secondaryTextStyle(size: textSizeMedium)),
                            Row(
                              children: [
                                Text("-", style: primaryTextStyle(color: primaryColor)),
                                PriceWidget(price: widget.mRPDiscount!.toStringAsFixed(2), color: primaryColor, size: 16),
                              ],
                            )
                          ],
                        ).paddingBottom(4).visible(widget.mRPDiscount != 0.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(appLocalization.translate('lbl_coupon_discount')!, style: secondaryTextStyle(size: textSizeMedium)),
                            Row(
                              children: [
                                Text("-", style: primaryTextStyle(color: primaryColor)),
                                PriceWidget(
                                  price: widget.discount.validate(),
                                  size: textSizeMedium.toDouble(),
                                  color: Theme.of(context).textTheme.subtitle1!.color,
                                ),
                              ],
                            ),
                          ],
                        ).paddingBottom(4).visible(widget.discount != 0.0 && isEnableCoupon == true),
                        widget.method != null
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(appLocalization.translate("lbl_Shipping")!, style: secondaryTextStyle(size: textSizeMedium)),
                                  widget.method != null && widget.method!.cost != null && widget.method!.cost.isNotEmpty
                                      ? PriceWidget(price: widget.method!.cost.toString().validate(), color: Theme.of(context).textTheme.subtitle1!.color, size: 16)
                                      : Text(appLocalization.translate('lbl_free')!, style: boldTextStyle(color: Colors.green))
                                ],
                              )
                            : SizedBox(),
                        spacing_control.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(appLocalization.translate('lbl_total_amount')!, style: boldTextStyle()),
                            PriceWidget(
                              price: widget.mPrice,
                              size: textSizeMedium.toDouble(),
                              color: Theme.of(context).textTheme.subtitle2!.color,
                            ),
                          ],
                        ),
                      ],
                    ).paddingAll(spacing_standard_new.toDouble()),
                  ],
                ),
              ),
              mProgress().center().visible(isLoading),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: <BoxShadow>[
              BoxShadow(color: Theme.of(context).hoverColor.withOpacity(0.8), blurRadius: 15.0, offset: Offset(0.0, 0.75)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PriceWidget(
                price: widget.mPrice,
                size: textSizeMedium.toDouble(),
                color: Theme.of(context).textTheme.subtitle2!.color,
              ).expand(),
              spacing_standard_new.height,
              AppButton(
                text: appLocalization.translate('lbl_continue'),
                textStyle: primaryTextStyle(color: white),
                color: primaryColor,
                onTap: () {
                  if (isLoading) {
                    return;
                  }
                  if (isNativePayment == false) {
                    createWebViewOrder();
                  } else {
                    if (_currentTimeValue == 0) {
                      _stripePayment(context);
                      /*showDialog(
                          context: context,
                          builder: (context) {
                            return PaymentAcceptComponent(
                              onCall: () async {
                                isLoading = true;
                                _stripePayment(context);
                              },
                            );
                          });*/
                    }

                    if (_currentTimeValue == 1) openCheckout();
                    if (_currentTimeValue == 2) _cod();
                  }
                },
              ).expand(),
            ],
          ).paddingOnly(top: spacing_standard_new.toDouble(), left: spacing_standard_new.toDouble(), bottom: spacing_standard_new.toDouble(), right: spacing_standard_new.toDouble()),
        ),
      ),
    );
  }

  void _stripePayment(BuildContext context) async {
    var mAmount = double.parse(widget.mPrice) * 100;
    var request = {
      'apiKey': stripPaymentKey,
      'amount': mAmount,
      'currency': "INR",
      'description': "556",
    };

    getStripeClientSecret(request).then(
      (res) async {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: res['client_secret'].toString(),
            style: ThemeMode.system,
            applePay: true,
            googlePay: true,
            testEnv: true,
            merchantCountryCode: 'IN',
            merchantDisplayName: 'Flutter Stripe Store Demo',
            customerId: '1',
            customerEphemeralKeySecret: res['client_secret'].toString(),
            setupIntentClientSecret: res['client_secret'].toString(),
          ),
        );

        await Stripe.instance.presentPaymentSheet(parameters: PresentPaymentSheetParameters(clientSecret: res['client_secret'].toString(), confirmPayment: true)).then(
          (value) async {
            createNativeOrder('Stripe Payment');
          },
        ).catchError((e) {
          toast("Payment Failed");
          log("presentPaymentSheet ${e.toString()}");
        });
      },
    ).catchError((e) {
      log("SetupPaymentSheetParameters ${e.toString()}");
    });
  }

  void _cod() {
    onOrderNowClick();
  }
}
