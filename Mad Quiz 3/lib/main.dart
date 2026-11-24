import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/audio_service.dart';
import 'providers/settings_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/game_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for optimal mobile gaming experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI bar styles to transparent overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F172A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final storageService = StorageService();
  await storageService.init();

  final audioService = AudioService();
  await audioService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<AudioService>.value(value: audioService),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(storageService, audioService),
        ),
        ChangeNotifierProvider(
          create: (_) => ProgressProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => GameProvider(audioService),
        ),
      ],
      child: const ColorFlowApp(),
    ),
  );
}

class ColorFlowApp extends StatelessWidget {
  const ColorFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Flow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9D4EDD),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
