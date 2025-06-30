import 'package:attendance/utils/app_color.dart';
import 'package:attendance/views/widgets/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

GetStorage? getStorage;

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
    // String languageCode = Prefs.getString(AppConstant.languageCode) == ''
    //     ? 'en'
    //     : Prefs.getString(AppConstant.languageCode);
    // String countryCode =
    //     Prefs.getString(AppConstant.languageCode) == 'ar' ? 'AR' : 'US';
    // Locale locale = Locale(languageCode, countryCode);

    return ScreenUtilInit(
      designSize: const Size(360, 690), // Set your design size here
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Nassar Attend',
          theme: ThemeData(
              colorScheme:
                  ColorScheme.fromSeed(seedColor: AppColor.primaryColor),
              fontFamily: "Outfit",
              useMaterial3: true,
              dialogTheme: DialogThemeData(backgroundColor: AppColor.cWhite)),
          home: const SplashScreen(),
        );
      },
    );
  }
}
