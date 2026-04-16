import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/main_menu_screen.dart';
import 'services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait-only for the best story experience
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar with light icons
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF050510),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await AudioService.instance.init();

  runApp(const ProviderScope(child: WahamApp()));
}

class WahamApp extends StatelessWidget {
  const WahamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'وهم',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050510),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7C3AED),
          secondary: Color(0xFFF59E0B),
          surface: Color(0xFF0C0C20),
        ),
        // Use system Arabic-capable font
        fontFamily: 'sans-serif',
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}
