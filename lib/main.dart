import 'dart:async';
import 'package:augmento/preload.dart';
import 'package:augmento/utils/config/app_config.dart';
import 'package:augmento/utils/routes/route_methods.dart';
import 'package:augmento/utils/routes/route_name.dart';
import 'package:augmento/utils/theme/light.dart';
import 'package:augmento/views/no_internet.dart';
import 'package:augmento/views/restart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  await GetStorage.init();
  GestureBinding.instance.resamplingEnabled = true;
  await initializeDateFormatting('en', null);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Color(0xFF2B6777), statusBarIconBrightness: Brightness.light));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await preload();
  runApp(const RestartApp(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: (BuildContext context, widget) {
        return OfflineBuilder(
          connectivityBuilder: (BuildContext context, List<ConnectivityResult> connectivity, Widget child) {
            if (connectivity.contains(ConnectivityResult.none)) {
              return const NoInternet();
            } else {
              return child;
            }
          },
          builder: (BuildContext context) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: widget!,
            );
          },
        );
      },
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeConfig.getThemeByIndex(context),
      themeMode: ThemeMode.system,
      getPages: AppRouteMethods.pages,
      initialRoute: AppRouteNames.splash,
    );
  }
}
