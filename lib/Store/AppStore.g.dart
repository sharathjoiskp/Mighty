// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppStore.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AppStore on AppStoreBase, Store {
  final _$isLoggedInAtom = Atom(name: 'AppStoreBase.isLoggedIn');

  @override
  bool get isLoggedIn {
    _$isLoggedInAtom.reportRead();
    return super.isLoggedIn;
  }

  @override
  set isLoggedIn(bool value) {
    _$isLoggedInAtom.reportWrite(value, super.isLoggedIn, () {
      super.isLoggedIn = value;
    });
  }

  final _$isGuestUserLoggedInAtom =
  Atom(name: 'AppStoreBase.isGuestUserLoggedIn');

  @override
  bool get isGuestUserLoggedIn {
    _$isGuestUserLoggedInAtom.reportRead();
    return super.isGuestUserLoggedIn;
  }

  @override
  set isGuestUserLoggedIn(bool value) {
    _$isGuestUserLoggedInAtom.reportWrite(value, super.isGuestUserLoggedIn, () {
      super.isGuestUserLoggedIn = value;
    });
  }

  final _$isDarkModeOnAtom = Atom(name: 'AppStoreBase.isDarkModeOn');

  @override
  bool get isDarkModeOn {
    _$isDarkModeOnAtom.reportRead();
    return super.isDarkModeOn;
  }

  @override
  set isDarkModeOn(bool value) {
    _$isDarkModeOnAtom.reportWrite(value, super.isDarkModeOn, () {
      super.isDarkModeOn = value;
    });
  }

  final _$countAtom = Atom(name: 'AppStoreBase.count');

  @override
  int? get count {
    _$countAtom.reportRead();
    return super.count;
  }

  @override
  set count(int? value) {
    _$countAtom.reportWrite(value, super.count, () {
      super.count = value;
    });
  }

  final _$mIsUserExistInReviewAtom =
  Atom(name: 'AppStoreBase.mIsUserExistInReview');

  @override
  bool get mIsUserExistInReview {
    _$mIsUserExistInReviewAtom.reportRead();
    return super.mIsUserExistInReview;
  }

  @override
  set mIsUserExistInReview(bool value) {
    _$mIsUserExistInReviewAtom.reportWrite(value, super.mIsUserExistInReview,
            () {
          super.mIsUserExistInReview = value;
        });
  }

  final _$isNotificationOnAtom = Atom(name: 'AppStoreBase.isNotificationOn');

  @override
  bool get isNotificationOn {
    _$isNotificationOnAtom.reportRead();
    return super.isNotificationOn;
  }

  @override
  set isNotificationOn(bool value) {
    _$isNotificationOnAtom.reportWrite(value, super.isNotificationOn, () {
      super.isNotificationOn = value;
    });
  }

  final _$isDarkModeAtom = Atom(name: 'AppStoreBase.isDarkMode');

  @override
  bool? get isDarkMode {
    _$isDarkModeAtom.reportRead();
    return super.isDarkMode;
  }

  @override
  set isDarkMode(bool? value) {
    _$isDarkModeAtom.reportWrite(value, super.isDarkMode, () {
      super.isDarkMode = value;
    });
  }

  final _$mIsInWishListAtom = Atom(name: 'AppStoreBase.mIsInWishList');

  @override
  bool get mIsInWishList {
    _$mIsInWishListAtom.reportRead();
    return super.mIsInWishList;
  }

  @override
  set mIsInWishList(bool value) {
    _$mIsInWishListAtom.reportWrite(value, super.mIsInWishList, () {
      super.mIsInWishList = value;
    });
  }

  final _$mIsInCartListAtom = Atom(name: 'AppStoreBase.mIsInCartList');

  @override
  bool get mIsInCartList {
    _$mIsInCartListAtom.reportRead();
    return super.mIsInCartList;
  }

  @override
  set mIsInCartList(bool value) {
    _$mIsInCartListAtom.reportWrite(value, super.mIsInCartList, () {
      super.mIsInCartList = value;
    });
  }

  final _$selectedLanguageCodeAtom =
  Atom(name: 'AppStoreBase.selectedLanguageCode');

  @override
  String get selectedLanguageCode {
    _$selectedLanguageCodeAtom.reportRead();
    return super.selectedLanguageCode;
  }

  @override
  set selectedLanguageCode(String value) {
    _$selectedLanguageCodeAtom.reportWrite(value, super.selectedLanguageCode,
            () {
          super.selectedLanguageCode = value;
        });
  }

  final _$mWishListAtom = Atom(name: 'AppStoreBase.mWishList');

  @override
  List<WishListResponse> get mWishList {
    _$mWishListAtom.reportRead();
    return super.mWishList;
  }

  @override
  set mWishList(List<WishListResponse> value) {
    _$mWishListAtom.reportWrite(value, super.mWishList, () {
      super.mWishList = value;
    });
  }

  final _$mCartListAtom = Atom(name: 'AppStoreBase.mCartList');

  @override
  List<CartModel> get mCartList {
    _$mCartListAtom.reportRead();
    return super.mCartList;
  }

  @override
  set mCartList(List<CartModel> value) {
    _$mCartListAtom.reportWrite(value, super.mCartList, () {
      super.mCartList = value;
    });
  }

  final _$isWishlistAtom = Atom(name: 'AppStoreBase.isWishlist');

  @override
  bool get isWishlist {
    _$isWishlistAtom.reportRead();
    return super.isWishlist;
  }

  @override
  set isWishlist(bool value) {
    _$isWishlistAtom.reportWrite(value, super.isWishlist, () {
      super.isWishlist = value;
    });
  }

  final _$toggleDarkModeAsyncAction =
  AsyncAction('AppStoreBase.toggleDarkMode');

  @override
  Future<void> toggleDarkMode({bool? value}) {
    return _$toggleDarkModeAsyncAction
        .run(() => super.toggleDarkMode(value: value));
  }

  final _$setDarkModeAsyncAction = AsyncAction('AppStoreBase.setDarkMode');

  @override
  Future<void> setDarkMode({bool? aIsDarkMode}) {
    return _$setDarkModeAsyncAction
        .run(() => super.setDarkMode(aIsDarkMode: aIsDarkMode));
  }

  final _$setLanguageAsyncAction = AsyncAction('AppStoreBase.setLanguage');

  @override
  Future<void> setLanguage(String aSelectedLanguageCode) {
    return _$setLanguageAsyncAction
        .run(() => super.setLanguage(aSelectedLanguageCode));
  }

  final _$AppStoreBaseActionController = ActionController(name: 'AppStoreBase');

  @override
  void setWishList(List<WishListResponse> val) {
    final _$actionInfo = _$AppStoreBaseActionController.startAction(
        name: 'AppStoreBase.setWishList');
    try {
      return super.setWishList(val);
    } finally {
      _$AppStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addToMyWishList(WishListResponse val) {
    final _$actionInfo = _$AppStoreBaseActionController.startAction(
        name: 'AppStoreBase.addToMyWishList');
    try {
      return super.addToMyWishList(val);
    } finally {
      _$AppStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeFromMyWishList(WishListResponse val) {
    final _$actionInfo = _$AppStoreBaseActionController.startAction(
        name: 'AppStoreBase.removeFromMyWishList');
    try {
      return super.removeFromMyWishList(val);
    } finally {
      _$AppStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCartList(List<CartModel> val) {
    final _$actionInfo = _$AppStoreBaseActionController.startAction(
        name: 'AppStoreBase.setCartList');
    try {
      return super.setCartList(val);
    } finally {
      _$AppStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addToCartList(CartModel val) {
    final _$actionInfo = _$AppStoreBaseActionController.startAction(
        name: 'AppStoreBase.addToCartList');
    try {
      return super.addToCartList(val);
    } finally {
      _$AppStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeFromCartList(CartModel val) {
    final _$actionInfo = _$AppStoreBaseActionController.startAction(
        name: 'AppStoreBase.removeFromCartList');
    try {
      return super.removeFromCartList(val);
    } finally {
      _$AppStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLoggedIn(bool val) {
    final _$actionInfo = _$AppStoreBaseActionController.startAction(
        name: 'AppStoreBase.setLoggedIn');
    try {
      return super.setLoggedIn(val);
    } finally {
      _$AppStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setGuestUserLoggedIn(bool val) {
    final _$actionInfo = _$AppStoreBaseActionController.startAction(
        name: 'AppStoreBase.setGuestUserLoggedIn');
    try {
      return super.setGuestUserLoggedIn(val);
    } finally {
      _$AppStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void increment() {
    final _$actionInfo = _$AppStoreBaseActionController.startAction(
        name: 'AppStoreBase.increment');
    try {
      return super.increment();
    } finally {
      _$AppStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void decrement() {
    final _$actionInfo = _$AppStoreBaseActionController.startAction(
        name: 'AppStoreBase.decrement');
    try {
      return super.decrement();
    } finally {
      _$AppStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCount(int? aCount) {
    final _$actionInfo = _$AppStoreBaseActionController.startAction(
        name: 'AppStoreBase.setCount');
    try {
      return super.setCount(aCount);
    } finally {
      _$AppStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNotification(bool val) {
    final _$actionInfo = _$AppStoreBaseActionController.startAction(
        name: 'AppStoreBase.setNotification');
    try {
      return super.setNotification(val);
    } finally {
      _$AppStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoggedIn: ${isLoggedIn},
isGuestUserLoggedIn: ${isGuestUserLoggedIn},
isDarkModeOn: ${isDarkModeOn},
count: ${count},
mIsUserExistInReview: ${mIsUserExistInReview},
isNotificationOn: ${isNotificationOn},
isDarkMode: ${isDarkMode},
mIsInWishList: ${mIsInWishList},
mIsInCartList: ${mIsInCartList},
selectedLanguageCode: ${selectedLanguageCode},
mWishList: ${mWishList},
mCartList: ${mCartList},
isWishlist: ${isWishlist}
    ''';
  }
}
