import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/library_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DocuVersePdfApp());
}

class DocuVersePdfApp extends StatelessWidget {
  const DocuVersePdfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          const primarySeedColor = Color(0xFF1E88E5); // Deep Indigo/Blue

          return MaterialApp(
            title: 'DocuVerse PDF - PDFly',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            
            // Premium Light Theme
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: primarySeedColor,
                brightness: Brightness.light,
              ),
              appBarTheme: const AppBarTheme(
                centerTitle: false,
                elevation: 0,
                scrolledUnderElevation: 1,
              ),
              cardTheme: CardThemeData(
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Premium Dark Theme
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: primarySeedColor,
                brightness: Brightness.dark,
              ),
              appBarTheme: const AppBarTheme(
                centerTitle: false,
                elevation: 0,
                scrolledUnderElevation: 1,
              ),
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}
