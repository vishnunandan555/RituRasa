import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riturasa/core/theme/riturasa_theme.dart';
import 'package:riturasa/presentation/navigation/screens/main_shell_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: RituRasaApp()));
}

/// Root Application widget for RituRasa.
/// Configures centralized Theme Engine extensions so all child screens
/// inherit design tokens automatically without ad-hoc styling.
class RituRasaApp extends StatelessWidget {
  const RituRasaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RituRasa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFA2C56),
          brightness: Brightness.light,
        ),
        extensions: [
          RituRasaThemeExtension.light(),
        ],
      ),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final clampedScaler = mediaQuery.textScaler.clamp(
          minScaleFactor: 0.85,
          maxScaleFactor: 1.15,
        );
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: clampedScaler),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const MainShellScreen(),
    );
  }
}
