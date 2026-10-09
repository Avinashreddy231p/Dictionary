import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/database.dart';
import '../../data/models/settings_state.dart';

enum RestoreStrategy {
  mergeSkip,
  mergeUpdate,
  replaceAll,
}

class BackupConfig {
  final bool includeSettings;
  final bool includeVocabulary;
  final bool includeCollections;
  final bool includeHistory;

  BackupConfig({
    this.includeSettings = true,
    this.includeVocabulary = true,
    this.includeCollections = true,
    this.includeHistory = true,
  });
}

class RestoreConfig {
  final bool restoreSettings;
  final RestoreStrategy wordStrategy;
  final RestoreStrategy collectionStrategy;
  final RestoreStrategy historyStrategy;

  RestoreConfig({
    this.restoreSettings = false,
    this.wordStrategy = RestoreStrategy.mergeSkip,
    this.collectionStrategy = RestoreStrategy.mergeSkip,
    this.historyStrategy = RestoreStrategy.mergeSkip,
  });
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<SettingsState> {
  late final SharedPreferences _prefs;

  static const _keyThemeMode = 'settings_theme_mode';
  static const _keyAccentColor = 'settings_accent_color';
  static const _keyFontScale = 'settings_font_scale';
  static const _keyPreferredAccent = 'settings_preferred_accent';
  static const _keyAutoPlayAudio = 'settings_auto_play_audio';
  static const _keyAudioSpeed = 'settings_audio_speed';
  static const _keyDailyGoal = 'settings_daily_goal';
  static const _keyDailyReminders = 'settings_daily_reminders';
  static const _keyReminderTime = 'settings_reminder_time';
  static const _keyStreakProtection = 'settings_streak_protection';
  static const _keyOfflineDatabase = 'settings_offline_database';
  static const _keyHapticFeedback = 'settings_haptic_feedback';
  static const _keySoundEffects = 'settings_sound_effects';
  static const _keyWotdNotification = 'settings_wotd_notification';
  static const _keyWotdTime = 'settings_wotd_time';
  static const _keyGeminiApiKey = 'settings_gemini_api_key';
  static const _keyGeminiAiEnabled = 'settings_gemini_ai_enabled';
  static const _keyGeminiModel = 'settings_gemini_model';
  static const _keyThemeVariant = 'settings_theme_variant';
  static const _keyShowBgBlobs = 'settings_show_bg_blobs';
  static const _keyBgTexture = 'settings_bg_texture';
  static const _keyBgTextureOpacity = 'settings_bg_texture_opacity';
  static const _keyAppFontFamily = 'settings_app_font_family';
  static const _keyCardRadiusStyle = 'settings_card_radius_style';
  static const _keyBorderWidthStyle = 'settings_border_width_style';
  static const _keySearchBarShape = 'settings_search_bar_shape';
  static const _keyDefinitionDensity = 'settings_definition_density';
  static const _keyEnableAnimations = 'settings_enable_animations';
  static const _keyCardShadowStyle = 'settings_card_shadow_style';
  static const _keyPageTransitionStyle = 'settings_page_transition_style';
  static const _keyHeaderStyle = 'settings_header_style';

  @override
  SettingsState build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return _loadFromPrefs();
  }

  SettingsState _loadFromPrefs() {
    final themeIndex = _prefs.getInt(_keyThemeMode);
    final themeMode = themeIndex != null && themeIndex < ThemeMode.values.length
        ? ThemeMode.values[themeIndex]
        : ThemeMode.system;

    final accentVal = _prefs.getInt(_keyAccentColor);
    final accentColor = accentVal != null ? Color(accentVal) : const Color(0xFFD97706);

    final fontScale = _prefs.getDouble(_keyFontScale) ?? 1.25;
    final preferredAccent = _prefs.getString(_keyPreferredAccent) ?? 'US';
    final autoPlayAudio = _prefs.getBool(_keyAutoPlayAudio) ?? true;
    final audioSpeed = _prefs.getDouble(_keyAudioSpeed) ?? 1.0;
    final dailyGoal = _prefs.getInt(_keyDailyGoal) ?? 10;
    final dailyReminders = _prefs.getBool(_keyDailyReminders) ?? true;
    final reminderTime = _prefs.getString(_keyReminderTime) ?? '08:00 PM';
    final streakProtection = _prefs.getBool(_keyStreakProtection) ?? true;
    final offlineDatabaseEnabled = _prefs.getBool(_keyOfflineDatabase) ?? true;
    final hapticFeedbackEnabled = _prefs.getBool(_keyHapticFeedback) ?? true;
    final soundEffectsEnabled = _prefs.getBool(_keySoundEffects) ?? true;
    final wordOfTheDayNotification = _prefs.getBool(_keyWotdNotification) ?? true;
    final wordOfTheDayTime = _prefs.getString(_keyWotdTime) ?? '09:00 AM';
    final geminiApiKey = _prefs.getString(_keyGeminiApiKey) ?? '';
    final geminiAiEnabled = _prefs.getBool(_keyGeminiAiEnabled) ?? true;
    final geminiModel = _prefs.getString(_keyGeminiModel) ?? 'gemini-2.0-flash';
    final themeVariant = _prefs.getString(_keyThemeVariant) ?? 'standard';
    final showBgBlobs = _prefs.getBool(_keyShowBgBlobs) ?? true;
    final bgTexture = _prefs.getString(_keyBgTexture) ?? 'dots';
    final bgTextureOpacity = _prefs.getDouble(_keyBgTextureOpacity) ?? 0.5;
    final appFontFamily = _prefs.getString(_keyAppFontFamily) ?? 'SF Pro Rounded';
    final cardRadiusStyle = _prefs.getString(_keyCardRadiusStyle) ?? 'pill';
    final borderWidthStyle = _prefs.getString(_keyBorderWidthStyle) ?? 'thin';
    final searchBarShape = _prefs.getString(_keySearchBarShape) ?? 'roundedBox';
    final definitionDensity = _prefs.getString(_keyDefinitionDensity) ?? 'spacious';
    final enableAnimations = _prefs.getBool(_keyEnableAnimations) ?? true;
    final cardShadowStyle = _prefs.getString(_keyCardShadowStyle) ?? 'soft';
    final pageTransitionStyle = _prefs.getString(_keyPageTransitionStyle) ?? 'standard';
    final headerStyle = _prefs.getString(_keyHeaderStyle) ?? 'glassmorphism';

    return SettingsState(
      themeMode: themeMode,
      accentColor: accentColor,
      fontScale: fontScale,
      preferredAccent: preferredAccent,
      autoPlayAudio: autoPlayAudio,
      audioSpeed: audioSpeed,
      dailyGoal: dailyGoal,
      dailyReminders: dailyReminders,
      reminderTime: reminderTime,
      streakProtection: streakProtection,
      offlineDatabaseEnabled: offlineDatabaseEnabled,
      hapticFeedbackEnabled: hapticFeedbackEnabled,
      soundEffectsEnabled: soundEffectsEnabled,
      wordOfTheDayNotification: wordOfTheDayNotification,
      wordOfTheDayTime: wordOfTheDayTime,
      geminiApiKey: geminiApiKey,
      geminiAiEnabled: geminiAiEnabled,
      geminiModel: geminiModel,
      themeVariant: themeVariant,
      showBgBlobs: showBgBlobs,
      bgTexture: bgTexture,
      bgTextureOpacity: bgTextureOpacity,
      appFontFamily: appFontFamily,
      cardRadiusStyle: cardRadiusStyle,
      borderWidthStyle: borderWidthStyle,
      searchBarShape: searchBarShape,
      definitionDensity: definitionDensity,
      enableAnimations: enableAnimations,
      cardShadowStyle: cardShadowStyle,
      pageTransitionStyle: pageTransitionStyle,
      headerStyle: headerStyle,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setInt(_keyThemeMode, mode.index);
  }

  Future<void> setAccentColor(Color color) async {
    state = state.copyWith(accentColor: color);
    await _prefs.setInt(_keyAccentColor, color.toARGB32());
  }

  Future<void> setFontScale(double scale) async {
    state = state.copyWith(fontScale: scale);
    await _prefs.setDouble(_keyFontScale, scale);
  }

  Future<void> setPreferredAccent(String accent) async {
    state = state.copyWith(preferredAccent: accent);
    await _prefs.setString(_keyPreferredAccent, accent);
  }

  Future<void> setAutoPlayAudio(bool enabled) async {
    state = state.copyWith(autoPlayAudio: enabled);
    await _prefs.setBool(_keyAutoPlayAudio, enabled);
  }

  Future<void> setAudioSpeed(double speed) async {
    state = state.copyWith(audioSpeed: speed);
    await _prefs.setDouble(_keyAudioSpeed, speed);
  }

  Future<void> setDailyGoal(int goal) async {
    state = state.copyWith(dailyGoal: goal);
    await _prefs.setInt(_keyDailyGoal, goal);
  }

  Future<void> setDailyReminders(bool enabled) async {
    state = state.copyWith(dailyReminders: enabled);
    await _prefs.setBool(_keyDailyReminders, enabled);
  }

  Future<void> setReminderTime(String time) async {
    state = state.copyWith(reminderTime: time);
    await _prefs.setString(_keyReminderTime, time);
  }

  Future<void> setStreakProtection(bool enabled) async {
    state = state.copyWith(streakProtection: enabled);
    await _prefs.setBool(_keyStreakProtection, enabled);
  }

  Future<void> setOfflineDatabaseEnabled(bool enabled) async {
    state = state.copyWith(offlineDatabaseEnabled: enabled);
    await _prefs.setBool(_keyOfflineDatabase, enabled);
  }

  Future<void> setHapticFeedback(bool enabled) async {
    state = state.copyWith(hapticFeedbackEnabled: enabled);
    await _prefs.setBool(_keyHapticFeedback, enabled);
  }

  Future<void> setSoundEffects(bool enabled) async {
    state = state.copyWith(soundEffectsEnabled: enabled);
    await _prefs.setBool(_keySoundEffects, enabled);
  }

  Future<void> setWordOfTheDayNotification(bool enabled) async {
    state = state.copyWith(wordOfTheDayNotification: enabled);
    await _prefs.setBool(_keyWotdNotification, enabled);
  }

  Future<void> setWordOfTheDayTime(String time) async {
    state = state.copyWith(wordOfTheDayTime: time);
    await _prefs.setString(_keyWotdTime, time);
  }

  Future<void> setGeminiApiKey(String apiKey) async {
    state = state.copyWith(geminiApiKey: apiKey);
    await _prefs.setString(_keyGeminiApiKey, apiKey);
  }

  Future<void> setGeminiAiEnabled(bool enabled) async {
    state = state.copyWith(geminiAiEnabled: enabled);
    await _prefs.setBool(_keyGeminiAiEnabled, enabled);
  }

  Future<void> setGeminiModel(String model) async {
    state = state.copyWith(geminiModel: model);
    await _prefs.setString(_keyGeminiModel, model);
  }

  Future<void> setThemeVariant(String variant) async {
    state = state.copyWith(themeVariant: variant);
    await _prefs.setString(_keyThemeVariant, variant);
  }

  Future<void> setUseOledBlack(bool enabled) async {
    await setThemeVariant(enabled ? 'oled' : 'standard');
  }

  Future<void> setShowBgBlobs(bool show) async {
    state = state.copyWith(showBgBlobs: show);
    await _prefs.setBool(_keyShowBgBlobs, show);
  }

  Future<void> setBgTexture(String texture) async {
    state = state.copyWith(bgTexture: texture);
    await _prefs.setString(_keyBgTexture, texture);
  }

  Future<void> setBgTextureOpacity(double opacity) async {
    state = state.copyWith(bgTextureOpacity: opacity);
    await _prefs.setDouble(_keyBgTextureOpacity, opacity);
  }

  Future<void> setAppFontFamily(String fontFamily) async {
    state = state.copyWith(appFontFamily: fontFamily);
    await _prefs.setString(_keyAppFontFamily, fontFamily);
  }

  Future<void> setCardRadiusStyle(String radiusStyle) async {
    state = state.copyWith(cardRadiusStyle: radiusStyle);
    await _prefs.setString(_keyCardRadiusStyle, radiusStyle);
  }

  Future<void> setBorderWidthStyle(String widthStyle) async {
    state = state.copyWith(borderWidthStyle: widthStyle);
    await _prefs.setString(_keyBorderWidthStyle, widthStyle);
  }

  Future<void> setSearchBarShape(String shape) async {
    state = state.copyWith(searchBarShape: shape);
    await _prefs.setString(_keySearchBarShape, shape);
  }

  Future<void> setDefinitionDensity(String density) async {
    state = state.copyWith(definitionDensity: density);
    await _prefs.setString(_keyDefinitionDensity, density);
  }

  Future<void> setEnableAnimations(bool enable) async {
    state = state.copyWith(enableAnimations: enable);
    await _prefs.setBool(_keyEnableAnimations, enable);
  }

  Future<void> setCardShadowStyle(String style) async {
    state = state.copyWith(cardShadowStyle: style);
    await _prefs.setString(_keyCardShadowStyle, style);
  }

  Future<void> setPageTransitionStyle(String style) async {
    state = state.copyWith(pageTransitionStyle: style);
    await _prefs.setString(_keyPageTransitionStyle, style);
  }

  Future<void> setHeaderStyle(String style) async {
    state = state.copyWith(headerStyle: style);
    await _prefs.setString(_keyHeaderStyle, style);
  }

  Future<int> importVocabularyJson(String jsonString, AppDatabase db, {int? collectionId}) async {
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      final companions = <SavedWordsCompanion>[];

      for (final item in list) {
        if (item is Map<String, dynamic> && item.containsKey('word')) {
          final word = (item['word'] as String).trim();
          if (word.isEmpty) continue;

          DateTime dateAdded = DateTime.now();
          if (item['dateAdded'] != null) {
            final parsed = DateTime.tryParse(item['dateAdded'].toString());
            if (parsed != null) dateAdded = parsed;
          }

          companions.add(SavedWordsCompanion.insert(
            word: word.toLowerCase(),
            phonetic: Value(item['phonetic'] as String?),
            partOfSpeech: Value(item['partOfSpeech'] as String?),
            meaning: Value(item['meaning'] as String?),
            example: Value(item['example'] as String?),
            syllables: Value(item['syllables'] as String?),
            cefr: Value(item['cefr'] as String? ?? 'B2'),
            dateAdded: dateAdded,
            contextSentence: Value(item['contextSentence'] as String?),
            personalNote: Value(item['personalNote'] as String?),
            source: Value(item['source'] as String? ?? 'Backup Import'),
            reviewState: Value((item['reviewState'] as num?)?.toInt() ?? 0),
            isFavorite: Value((item['isFavorite'] as bool?) ?? false),
          ));
        }
      }

      if (companions.isEmpty) return 0;
      if (collectionId != null) {
        return await db.batchSaveWordsAndAddToCollection(companions, collectionId);
      }
      return await db.batchSaveWords(companions);
    } catch (e) {
      return 0;
    }
  }

  Future<int> importVocabularyCsv(String csvString, AppDatabase db, {int? collectionId}) async {
    try {
      final lines = const LineSplitter().convert(csvString);
      final companions = <SavedWordsCompanion>[];

      for (final rawLine in lines) {
        final line = rawLine.trim();
        if (line.isEmpty || line.startsWith('#')) continue;

        final delimiter = line.contains(';') ? ';' : ',';
        final parts = line.split(delimiter).map((e) => e.trim().replaceAll('"', '')).toList();

        if (parts.isNotEmpty && parts[0].isNotEmpty) {
          final word = parts[0];
          final pos = parts.length > 1 && parts[1].isNotEmpty ? parts[1] : null;
          final phonetic = parts.length > 2 && parts[2].isNotEmpty ? parts[2] : null;
          final meaning = parts.length > 3 && parts[3].isNotEmpty ? parts[3] : null;
          final example = parts.length > 4 && parts[4].isNotEmpty ? parts[4] : null;
          final source = parts.length > 5 && parts[5].isNotEmpty ? parts[5] : 'CSV Import';

          companions.add(SavedWordsCompanion.insert(
            word: word.toLowerCase(),
            phonetic: Value(phonetic),
            partOfSpeech: Value(pos),
            meaning: Value(meaning),
            example: Value(example),
            cefr: const Value('B2'),
            dateAdded: DateTime.now(),
            source: Value(source),
          ));
        }
      }

      if (companions.isEmpty) return 0;
      if (collectionId != null) {
        return await db.batchSaveWordsAndAddToCollection(companions, collectionId);
      }
      return await db.batchSaveWords(companions);
    } catch (e) {
      return 0;
    }
  }

  Future<void> clearCacheAndHistory() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('search_history_') || key.startsWith('cache_')) {
        await _prefs.remove(key);
      }
    }
  }

  // --- Export & Restore Settings ---
  Map<String, dynamic> exportPreferences() {
    final map = <String, dynamic>{};
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('settings_')) {
        map[key] = _prefs.get(key);
      }
    }
    return map;
  }

  Future<void> restorePreferences(Map<String, dynamic> prefsMap) async {
    for (final entry in prefsMap.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is int) {
        await _prefs.setInt(key, value);
      } else if (value is double) await _prefs.setDouble(key, value);
      else if (value is bool) await _prefs.setBool(key, value);
      else if (value is String) await _prefs.setString(key, value);
      else if (value is List) {
         await _prefs.setStringList(key, (value).map((e) => e.toString()).toList());
      }
    }
    state = _loadFromPrefs();
  }

  Future<String> exportCustomBackup({
    required BackupConfig config,
    required AppDatabase db,
    void Function(double, String)? onProgress,
  }) async {
    final payload = <String, dynamic>{
      'version': 1,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (config.includeSettings) {
      onProgress?.call(0.05, 'Exporting Settings...');
      payload['preferences'] = exportPreferences();
    }

    final dbData = await db.exportUserDatabase(
      includeWords: config.includeVocabulary,
      includeCollections: config.includeCollections,
      includeHistory: config.includeHistory,
      onProgress: onProgress,
    );

    payload.addAll(dbData);
    
    onProgress?.call(0.9, 'Encoding Backup File...');
    return const JsonEncoder().convert(payload);
  }

  Future<bool> restoreCustomBackup({
    required String jsonStr,
    required RestoreConfig config,
    required AppDatabase db,
    void Function(double, String)? onProgress,
  }) async {
    try {
      onProgress?.call(0.05, 'Parsing Backup File...');
      final payload = jsonDecode(jsonStr) as Map<String, dynamic>;

      if (config.restoreSettings && payload.containsKey('preferences')) {
        onProgress?.call(0.1, 'Restoring Settings...');
        await restorePreferences(payload['preferences'] as Map<String, dynamic>);
      }

      await db.restoreUserDatabase(
        payload,
        wordStrategy: config.wordStrategy,
        collectionStrategy: config.collectionStrategy,
        historyStrategy: config.historyStrategy,
        onProgress: onProgress,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> resetToDefaults() async {
    state = const SettingsState();
    await _prefs.remove(_keyThemeMode);
    await _prefs.remove(_keyAccentColor);
    await _prefs.remove(_keyFontScale);
    await _prefs.remove(_keyPreferredAccent);
    await _prefs.remove(_keyAutoPlayAudio);
    await _prefs.remove(_keyAudioSpeed);
    await _prefs.remove(_keyDailyGoal);
    await _prefs.remove(_keyDailyReminders);
    await _prefs.remove(_keyReminderTime);
    await _prefs.remove(_keyStreakProtection);
    await _prefs.remove(_keyOfflineDatabase);
    await _prefs.remove(_keyHapticFeedback);
    await _prefs.remove(_keySoundEffects);
    await _prefs.remove(_keyWotdNotification);
    await _prefs.remove(_keyWotdTime);
    await _prefs.remove(_keyGeminiApiKey);
    await _prefs.remove(_keyGeminiAiEnabled);
    await _prefs.remove(_keyGeminiModel);
    await _prefs.remove(_keyThemeVariant);
    await _prefs.remove(_keyShowBgBlobs);
    await _prefs.remove(_keyBgTexture);
    await _prefs.remove(_keyAppFontFamily);
    await _prefs.remove(_keyCardRadiusStyle);
    await _prefs.remove(_keyBorderWidthStyle);
    await _prefs.remove(_keySearchBarShape);
    await _prefs.remove(_keyDefinitionDensity);
    await _prefs.remove(_keyEnableAnimations);
    await _prefs.remove(_keyCardShadowStyle);
    await _prefs.remove(_keyPageTransitionStyle);
    await _prefs.remove(_keyHeaderStyle);
  }
}
