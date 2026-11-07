import 'package:flutter/material.dart';
import 'package:on_the_best_estoque/utils/main_navigator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://rrmohnvpsfxzcflxfohf.supabase.co',
    publishableKey: 'sb_publishable_OTn9yw64zzGRgplhzcyuyA_Dv356ExV',
  );

  runApp(const OnTheBestApp());
}

class OnTheBestApp extends StatelessWidget {
  const OnTheBestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFFFCC00),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1A1A1A),
          selectedItemColor: Color(0xFFFFCC00),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      initialRoute: '/',
      routes: {'/': (context) => const MainNavigator()},
    );
  }
}
