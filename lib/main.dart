import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playku/app/data/services/queue_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:playku/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AudioService.playBackgroundMusic();
  await Supabase.initialize(
    url: 'https://lvqfhlohgdaqudfuivqb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx2cWZobG9oZ2RhcXVkZnVpdnFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxMTEwNDksImV4cCI6MjA1OTY4NzA0OX0.HezOkrAcGdyfdhRl53Ad-RTRAk5YlLiUz1UvJ7ltW1Y',
  );

  // cek koneksi saat pertama kali dijalankan
  final connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult != ConnectivityResult.none) {
    debugPrint('Terhubung ke internet (saat startup)');
    await QueueService.processQueue();
  }

  // mengecek perubahan koneksi 
  Connectivity()
      .onConnectivityChanged
      .listen((ConnectivityResult result) async {
    if (result != ConnectivityResult.none) {
      debugPrint('Terhubung ke internet (perubahan koneksi)');
      await QueueService.processQueue();
      try {
        final homeController = Get.find<HomeController>();
        homeController.reloadHome();
      } catch (e) {
        debugPrint('HomeController belum tersedia: $e');
      }
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PlayKu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      defaultTransition: Transition.circularReveal,
      // transitionDuration: Duration(milliseconds: 300),
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,
    );
  }
}
