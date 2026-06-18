import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart'; 

import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/main_screen.dart'; 
import 'screens/vendor_main_screen.dart'; // <-- IMPORT FILE BARU VENDOR
import 'screens/category_screen.dart';
import 'screens/vendor_detail_screen.dart'; 
import 'utils/colors.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // ---> TAMBAHKAN BARIS INI UNTUK MENYALAKAN FORMAT TANGGAL INDONESIA <---
  await initializeDateFormatting('id_ID', null); 

  runApp(const MyApp()); // (Atau nama class utama Anda)
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vowly',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        primaryColor: AppColors.primaryPink,
        scaffoldBackgroundColor: AppColors.backgroundWhite,
      ),
      initialRoute: '/', 
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(), 
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/role_selection': (context) => const RoleSelectionScreen(),
        '/main': (context) => const MainScreen(), 
        '/vendor_main': (context) => const VendorMainScreen(), // <-- ROUTE BARU VENDOR
        '/categories': (context) => const CategoryScreen(),
        '/vendor_detail': (context) => const VendorDetailScreen(), 
      },
    );
  }
}