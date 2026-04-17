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

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAQY1SQeZwn5Z5EPgryh4j_M_SKadyoRBo',
        appId: '1:760074919513:ios:97ce25cb9e800d450cdb48',
        messagingSenderId: '760074919513',
        projectId: 'bringit-5fc69',
        storageBucket: 'bringit-5fc69.firebasestorage.app',
      ),
    );
    await NotificationService().initialize();
  } catch (_) {
    // Firebase not configured for this iOS app — push notifications unavailable
  }

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
