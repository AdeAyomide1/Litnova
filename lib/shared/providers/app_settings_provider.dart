import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppSettingsProvider extends ChangeNotifier {
  static final AppSettingsProvider _instance = AppSettingsProvider._internal();
  factory AppSettingsProvider() => _instance;
  AppSettingsProvider._internal();

  late Box _box;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _box = await Hive.openBox('app_settings');
    _initialized = true;
  }

  // ─── Home Layout ───────────────────────────────────────────────
  String get homeLayout =>
      _box.get('home_layout', defaultValue: 'list');
  set homeLayout(String v) {
    _box.put('home_layout', v);
    notifyListeners();
  }

  bool get showTrending =>
      _box.get('show_trending', defaultValue: true);
  set showTrending(bool v) {
    _box.put('show_trending', v);
    notifyListeners();
  }

  bool get showContinueReading =>
      _box.get('show_continue_reading', defaultValue: true);
  set showContinueReading(bool v) {
    _box.put('show_continue_reading', v);
    notifyListeners();
  }

  bool get showFeatured =>
      _box.get('show_featured', defaultValue: true);
  set showFeatured(bool v) {
    _box.put('show_featured', v);
    notifyListeners();
  }

  // ─── Theme ─────────────────────────────────────────────────────
  String get accentColor =>
      _box.get('accent_color', defaultValue: 'amber');
  set accentColor(String v) {
    _box.put('accent_color', v);
    notifyListeners();
  }

  String get appTheme =>
      _box.get('app_theme', defaultValue: 'dark');
  set appTheme(String v) {
    _box.put('app_theme', v);
    notifyListeners();
  }

  // ─── Reader ────────────────────────────────────────────────────
  double get fontSize =>
      _box.get('font_size', defaultValue: 16.0);
  set fontSize(double v) {
    _box.put('font_size', v);
    notifyListeners();
  }

  String get readerFont =>
      _box.get('reader_font', defaultValue: 'Lora');
  set readerFont(String v) {
    _box.put('reader_font', v);
    notifyListeners();
  }

  double get lineSpacing =>
      _box.get('line_spacing', defaultValue: 1.85);
  set lineSpacing(double v) {
    _box.put('line_spacing', v);
    notifyListeners();
  }

  String get readerTheme =>
      _box.get('reader_theme', defaultValue: 'Dark');
  set readerTheme(String v) {
    _box.put('reader_theme', v);
    notifyListeners();
  }

  // ─── TTS ───────────────────────────────────────────────────────
  double get ttsSpeed =>
      _box.get('tts_speed', defaultValue: 0.75);
  set ttsSpeed(double v) {
    _box.put('tts_speed', v);
    notifyListeners();
  }

  double get ttsPitch =>
      _box.get('tts_pitch', defaultValue: 1.0);
  set ttsPitch(double v) {
    _box.put('tts_pitch', v);
    notifyListeners();
  }

  String get ttsVoice =>
      _box.get('tts_voice', defaultValue: 'Default');
  set ttsVoice(String v) {
    _box.put('tts_voice', v);
    notifyListeners();
  }

  // ─── Notifications ─────────────────────────────────────────────
  bool get pushNotifications =>
      _box.get('push_notifications', defaultValue: true);
  set pushNotifications(bool v) {
    _box.put('push_notifications', v);
    notifyListeners();
  }

  bool get newChapterAlerts =>
      _box.get('new_chapter_alerts', defaultValue: true);
  set newChapterAlerts(bool v) {
    _box.put('new_chapter_alerts', v);
    notifyListeners();
  }

  // ─── Downloads ─────────────────────────────────────────────────
  bool get downloadOnWifi =>
      _box.get('download_on_wifi', defaultValue: true);
  set downloadOnWifi(bool v) {
    _box.put('download_on_wifi', v);
    notifyListeners();
  }

  // ─── Camera ────────────────────────────────────────────────────
  bool get cameraBackground =>
      _box.get('camera_background', defaultValue: false);
  set cameraBackground(bool v) {
    _box.put('camera_background', v);
    notifyListeners();
  }

  bool get keepScreenOn =>
      _box.get('keep_screen_on', defaultValue: true);
  set keepScreenOn(bool v) {
    _box.put('keep_screen_on', v);
    notifyListeners();
  }

  // ─── Colors ────────────────────────────────────────────────────
  static const Map<String, Color> accentColors = {
    'amber': Color(0xFFC8823A),
    'blue': Color(0xFF5B9BD5),
    'green': Color(0xFF3AAA6A),
    'purple': Color(0xFF8B5CF6),
    'red': Color(0xFFE05555),
    'pink': Color(0xFFE85D8A),
    'teal': Color(0xFF2DD4BF),
    'orange': Color(0xFFF97316),
  };

  static const Map<String, Map<String, Color>> appThemes = {
    'dark': {
      'bg': Color(0xFF120D08),
      'surface': Color(0xFF1E1610),
      'card': Color(0xFF241A11),
      'border': Color(0xFF2E2018),
      'text': Color(0xFFF0D9B5),
      'textSecondary': Color(0xFFC4A882),
      'textMuted': Color(0xFF8A6A4A),
      'textFaint': Color(0xFF5A4535),
      'textGhost': Color(0xFF3D2E1E),
    },
    'midnight': {
      'bg': Color(0xFF0A0A0F),
      'surface': Color(0xFF12121A),
      'card': Color(0xFF1A1A25),
      'border': Color(0xFF252535),
      'text': Color(0xFFE8E8FF),
      'textSecondary': Color(0xFFAAAACC),
      'textMuted': Color(0xFF666688),
      'textFaint': Color(0xFF444466),
      'textGhost': Color(0xFF222244),
    },
    'forest': {
      'bg': Color(0xFF0A120A),
      'surface': Color(0xFF121A12),
      'card': Color(0xFF1A251A),
      'border': Color(0xFF253025),
      'text': Color(0xFFE8F5E8),
      'textSecondary': Color(0xFFAAC8AA),
      'textMuted': Color(0xFF668066),
      'textFaint': Color(0xFF445544),
      'textGhost': Color(0xFF223322),
    },
    'ocean': {
      'bg': Color(0xFF080E14),
      'surface': Color(0xFF10181F),
      'card': Color(0xFF18222A),
      'border': Color(0xFF202E38),
      'text': Color(0xFFE0F0FF),
      'textSecondary': Color(0xFFA0C0D8),
      'textMuted': Color(0xFF607080),
      'textFaint': Color(0xFF405060),
      'textGhost': Color(0xFF203040),
    },
  };

  Color get currentAccentColor =>
      accentColors[accentColor] ?? const Color(0xFFC8823A);

  Map<String, Color> get currentTheme =>
      appThemes[appTheme] ?? appThemes['dark']!;

  Color get bgColor =>
      currentTheme['bg'] ?? const Color(0xFF120D08);
  Color get surfaceColor =>
      currentTheme['surface'] ?? const Color(0xFF1E1610);
  Color get cardColor =>
      currentTheme['card'] ?? const Color(0xFF241A11);
  Color get borderColor =>
      currentTheme['border'] ?? const Color(0xFF2E2018);
  Color get textColor =>
      currentTheme['text'] ?? const Color(0xFFF0D9B5);
  Color get textSecondaryColor =>
      currentTheme['textSecondary'] ?? const Color(0xFFC4A882);
  Color get textMutedColor =>
      currentTheme['textMuted'] ?? const Color(0xFF8A6A4A);
  Color get textFaintColor =>
      currentTheme['textFaint'] ?? const Color(0xFF5A4535);
  Color get textGhostColor =>
      currentTheme['textGhost'] ?? const Color(0xFF3D2E1E);
}
