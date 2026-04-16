import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Firebase — replace appId with the Android/iOS app ID from Firebase console
  // for this app (Project Settings → Your apps → User App)
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAG1_4lKUOhSGPdpBNsG_eCf2FAdEDMzZA',
      appId: '1:760074919513:android:REPLACE_WITH_USER_ANDROID_APP_ID',
      messagingSenderId: '760074919513',
      projectId: 'bringit-5fc69',
      storageBucket: 'bringit-5fc69.firebasestorage.app',
    ),
  );
  await NotificationService().initialize();

  runApp(const BringItApp());
}

class BringItApp extends StatelessWidget {
  const BringItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BringIt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
    );
  }
}
