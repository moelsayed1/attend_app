import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_constant.dart';
import '../../utils/prefer.dart';
import '../../views/pages/login_screen.dart';

class TokenInterceptor extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Token validation enabled
    final token = Prefs.getToken();
    if (token.isEmpty) {
      return const RouteSettings(name: '/login');
    }
    return null;
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    return page;
  } 
}