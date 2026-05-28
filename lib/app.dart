import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'shared/providers/app_settings_provider.dart';

class LitNovaApp extends ConsumerWidget {
  const LitNovaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return AnimatedBuilder(
      animation: AppSettingsProvider(),
      builder: (context, _) {
        final settings = AppSettingsProvider();
        return MaterialApp.router(
          title: 'LitNOVA',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(settings),
          routerConfig: router,
        );
      },
    );
  }

  ThemeData _buildTheme(AppSettingsProvider settings) {
    final accent = settings.currentAccentColor;
    final bg = settings.bgColor;
    final surface = settings.surfaceColor;
    final text = settings.textColor;

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: accent,
        surface: surface,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bg,
        selectedItemColor: accent,
        unselectedItemColor: settings.textFaintColor,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return settings.textFaintColor;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accent.withValues(alpha: 0.3);
          }
          return settings.textGhostColor;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        thumbColor: accent,
        inactiveTrackColor: settings.textGhostColor,
        overlayColor: accent.withValues(alpha: 0.2),
      ),
      dividerColor: settings.borderColor,
      cardColor: surface,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: text),
        bodyMedium: TextStyle(color: text),
        titleLarge: TextStyle(color: text),
      ),
      iconTheme: IconThemeData(color: settings.textMutedColor),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
      ), dialogTheme: DialogThemeData(backgroundColor: surface),
    );
  }
}
