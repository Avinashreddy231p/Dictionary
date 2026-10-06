import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/database.dart';
import '../../data/models/settings_state.dart';

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
    final accentColor = accentVal != null ? Color(accentVal) : const Color(0xFF6344FF);

    final fontScale = _prefs.getDouble(_keyFontScale) ?? 1.0;
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
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setInt(_keyThemeMode, mode.index);
  }

  Future<void> setAccentColor(Color color) async {
    state = state.copyWith(accentColor: color);
    await _prefs.setInt(_keyAccentColor, color.value);
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

  Future<int> importVocabularyJson(String jsonString, AppDatabase db) async {
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      int importedCount = 0;

      for (final item in list) {
        if (item is Map<String, dynamic> && item.containsKey('word')) {
          final word = item['word'] as String;
          await db.saveWord(
            word: word,
            phonetic: item['phonetic'] as String?,
            partOfSpeech: item['partOfSpeech'] as String?,
            meaning: item['meaning'] as String?,
            example: item['example'] as String?,
            cefr: item['cefr'] as String? ?? 'B2',
          );
          importedCount++;
        }
      }
      return importedCount;
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
  }
}
