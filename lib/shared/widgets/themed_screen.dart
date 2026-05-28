import 'package:flutter/material.dart';
import '../providers/app_settings_provider.dart';

class ThemedScreen extends StatelessWidget {
  final Widget child;
  final bool useSafeArea;

  const ThemedScreen({
    super.key,
    required this.child,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettingsProvider(),
      builder: (context, _) {
        final settings = AppSettingsProvider();
        return Scaffold(
          backgroundColor: settings.bgColor,
          body: useSafeArea ? SafeArea(child: child) : child,
        );
      },
    );
  }
}
