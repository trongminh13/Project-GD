import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/theme/theme_manager.dart';
import 'package:ashadeep/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initializeApp skipped/error: $e');
    }
  }
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('.env load skipped/error: $e');
  }
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeManager(),
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, _) {
          return MaterialApp(
            title: 'Cổng Thông Tin Giáo Dục Đại Việt',
            debugShowCheckedModeBanner: false,
            themeMode: themeManager.mode,
            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: AppColors.lightPrimary,
              scaffoldBackgroundColor: AppColors.lightBackground,
              fontFamily: 'Roboto',
              colorScheme: const ColorScheme.light(
                primary: AppColors.lightPrimary,
                secondary: AppColors.lightSecondary,
                surface: AppColors.lightSurface,
                error: AppColors.error,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.lightSurface,
                foregroundColor: AppColors.lightTextPrimary,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
              ),
              cardTheme: CardThemeData(
                color: AppColors.lightSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.lightBorder),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AppColors.lightSurfaceAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.lightBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.lightBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
                ),
              ),
              dividerTheme: const DividerThemeData(
                color: AppColors.lightDivider,
                thickness: 1,
              ),
              pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: const ZoomPageTransitionsBuilder(),
                  TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
                  TargetPlatform.windows: const ZoomPageTransitionsBuilder(),
                  TargetPlatform.macOS: const ZoomPageTransitionsBuilder(),
                },
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: AppColors.darkPrimary,
              scaffoldBackgroundColor: AppColors.darkBackground,
              fontFamily: 'Roboto',
              colorScheme: const ColorScheme.dark(
                primary: AppColors.darkPrimary,
                secondary: AppColors.darkSecondary,
                surface: AppColors.darkSurface,
                error: AppColors.error,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.darkBackground,
                foregroundColor: AppColors.darkTextPrimary,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
              ),
              cardTheme: CardThemeData(
                color: AppColors.darkSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.darkBorder),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AppColors.darkSurfaceAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.darkBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.darkBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
                ),
              ),
              dividerTheme: const DividerThemeData(
                color: AppColors.darkDivider,
                thickness: 1,
              ),
              pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: const ZoomPageTransitionsBuilder(),
                  TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
                  TargetPlatform.windows: const ZoomPageTransitionsBuilder(),
                  TargetPlatform.macOS: const ZoomPageTransitionsBuilder(),
                },
              ),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
