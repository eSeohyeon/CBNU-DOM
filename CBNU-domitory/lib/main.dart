import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_gate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/bottom_navigation_tab.dart';
import 'package:untitled/start/start_page.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:untitled/laundry/notification_service.dart';

final NotificationService notificationService = NotificationService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FlutterDownloader.initialize(
    debug: true,
    ignoreSsl: true
  );
  tz.initializeTimeZones();
  await notificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child){
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Firebase Auth',
          theme: ThemeData(
            primarySwatch: Colors.blue
          ),
            home: AuthGate()
        );
      }
    );
  }
}
