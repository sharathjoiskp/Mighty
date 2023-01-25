import 'dart:convert';

import 'package:http/http.dart';
import 'package:mightystore/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

bool isSuccessful(int code) {
  return code >= 200 && code <= 206;
}

Future handleResponse(Response response) async {
  if (!await isNetworkAvailable()) {
    throw 'You are not connected to Internet';
  }
  String body = response.body;
  if (isSuccessful(response.statusCode)) {
    return jsonDecode(body);
  } else {
    var string = await (isJsonValid(body) as Future<String>);
    if (string.isNotEmpty) {
      throw string;
    } else {
      throw 'Please try again later.';
    }
  }
}


openSignInScreen() async {
  toastLong("Your token has been Expired. Please login again.");
  await removeKey(TOKEN);
  await removeKey(USERNAME);
  await removeKey(FIRST_NAME);
  await removeKey(LAST_NAME);
  await removeKey(USER_DISPLAY_NAME);
  await removeKey(USER_ID);
  await removeKey(USER_EMAIL);
  await removeKey(USER_ROLE);
  await removeKey(AVATAR);
  await removeKey(PROFILE_IMAGE);
  await setValue(IS_GUEST_USER, false);
  await setValue(IS_LOGGED_IN, false);
  await setValue(IS_SOCIAL_LOGIN, false);
  appStore.setCount(0);
}

extension json on Map {
  toJson() {
    return jsonEncode(this);
  }
}

Future<String?> isJsonValid(json) async {
  try {
    var f = jsonDecode(json) as Map<String, dynamic>;
    return f[msg];
  } catch (e) {
    log(e.toString());
    return "";
  }
}
