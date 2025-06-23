import 'package:attendance/utils/app_color.dart';
import 'package:attendance/utils/app_constant.dart';
import 'package:attendance/utils/prefer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:attendance/views/widgets/splash_screen.dart';

GetStorage? getStorage;
var logger = Logger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  getStorage = GetStorage();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Remove splash screen after initialization
  }

  @override
  Widget build(BuildContext context) {
    String languageCode = Prefs.getString(AppConstant.languageCode) == ''
        ? 'en'
        : Prefs.getString(AppConstant.languageCode);
    String countryCode =
        Prefs.getString(AppConstant.languageCode) == 'ar' ? 'AR' : 'US';
    Locale locale = Locale(languageCode, countryCode);

    // getToken() async {
    //   await dotenv.load(fileName: "asset/.env");
    //   String isDemoMode = dotenv.get(AppConstant.isDemoMode);
    //   Prefs.setBool(AppConstant.isDemoMode, bool.parse(isDemoMode));
    //   String accessToken = Prefs.getToken();
    //   return accessToken;
    // }

    return ScreenUtilInit(
      designSize: const Size(360, 690), // Set your design size here
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Nassar Attend',
          theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primaryColor),
              fontFamily: "Outfit",
              useMaterial3: true,
              dialogTheme: DialogThemeData(backgroundColor: AppColor.cWhite)),
          home: const SplashScreen(),
        );
      },
    );
  }
}
