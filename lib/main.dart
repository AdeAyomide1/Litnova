import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'shared/providers/app_settings_provider.dart';
import 'data/services/bookmark_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Initialize all boxes
  await AppSettingsProvider().init();
  await BookmarkService.init();

  runApp(
    const ProviderScope(
      child: LitNovaApp(),
    ),
  );
}
