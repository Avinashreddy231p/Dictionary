import 'package:flutter/material.dart';

class SettingsState {
  final ThemeMode themeMode;
  final Color accentColor;
  final double fontScale;
  final String preferredAccent; // 'US' or 'UK'
  final bool autoPlayAudio;
  final double audioSpeed; // 0.75, 1.0, 1.25, 1.5
  final int dailyGoal; // 5, 10, 15, 20
  final bool dailyReminders;
  final String reminderTime; // e.g. "08:00 PM"
  final bool streakProtection;
  final bool offlineDatabaseEnabled;
  final bool hapticFeedbackEnabled;
  final bool soundEffectsEnabled;
  final bool wordOfTheDayNotification;
  final String wordOfTheDayTime; // e.g. "09:00 AM"
  final String geminiApiKey;
  final bool geminiAiEnabled;
  final String geminiModel; // "gemini-2.0-flash", "gemini-1.5-flash", "gemini-1.5-pro"
  final String themeVariant; // 'standard', 'sepia', 'oled'
  final bool showBgBlobs;
  final String bgTexture; // 'none', 'dots', 'grid', 'crosshatch'
  final String appFontFamily; // 'SF Pro', 'SF Pro Display', 'SF Pro Rounded', 'Nunito', 'Inter', 'Lora', 'Fira Code'
  final String cardRadiusStyle; // 'sharp', 'rounded', 'pill'
  final String borderWidthStyle; // 'thin', 'standard', 'bold'
  final String searchBarShape; // 'pill', 'roundedBox'
  final String definitionDensity; // 'spacious', 'compact'

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.accentColor = const Color(0xFFFFBE98),
    this.fontScale = 1.0,
    this.preferredAccent = 'US',
    this.autoPlayAudio = true,
    this.audioSpeed = 1.0,
    this.dailyGoal = 10,
    this.dailyReminders = true,
    this.reminderTime = '08:00 PM',
    this.streakProtection = true,
    this.offlineDatabaseEnabled = true,
    this.hapticFeedbackEnabled = true,
    this.soundEffectsEnabled = true,
    this.wordOfTheDayNotification = true,
    this.wordOfTheDayTime = '09:00 AM',
    this.geminiApiKey = '',
    this.geminiAiEnabled = true,
    this.geminiModel = 'gemini-2.0-flash',
    this.themeVariant = 'standard',
    this.showBgBlobs = true,
    this.bgTexture = 'dots',
    this.appFontFamily = 'Nunito',
    this.cardRadiusStyle = 'rounded',
    this.borderWidthStyle = 'standard',
    this.searchBarShape = 'pill',
    this.definitionDensity = 'spacious',
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Color? accentColor,
    double? fontScale,
    String? preferredAccent,
    bool? autoPlayAudio,
    double? audioSpeed,
    int? dailyGoal,
    bool? dailyReminders,
    String? reminderTime,
    bool? streakProtection,
    bool? offlineDatabaseEnabled,
    bool? hapticFeedbackEnabled,
    bool? soundEffectsEnabled,
    bool? wordOfTheDayNotification,
    String? wordOfTheDayTime,
    String? geminiApiKey,
    bool? geminiAiEnabled,
    String? geminiModel,
    String? themeVariant,
    bool? showBgBlobs,
    String? bgTexture,
    String? appFontFamily,
    String? cardRadiusStyle,
    String? borderWidthStyle,
    String? searchBarShape,
    String? definitionDensity,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      fontScale: fontScale ?? this.fontScale,
      preferredAccent: preferredAccent ?? this.preferredAccent,
      autoPlayAudio: autoPlayAudio ?? this.autoPlayAudio,
      audioSpeed: audioSpeed ?? this.audioSpeed,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      dailyReminders: dailyReminders ?? this.dailyReminders,
      reminderTime: reminderTime ?? this.reminderTime,
      streakProtection: streakProtection ?? this.streakProtection,
      offlineDatabaseEnabled:
          offlineDatabaseEnabled ?? this.offlineDatabaseEnabled,
      hapticFeedbackEnabled:
          hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      wordOfTheDayNotification:
          wordOfTheDayNotification ?? this.wordOfTheDayNotification,
      wordOfTheDayTime: wordOfTheDayTime ?? this.wordOfTheDayTime,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      geminiAiEnabled: geminiAiEnabled ?? this.geminiAiEnabled,
      geminiModel: geminiModel ?? this.geminiModel,
      themeVariant: themeVariant ?? this.themeVariant,
      showBgBlobs: showBgBlobs ?? this.showBgBlobs,
      bgTexture: bgTexture ?? this.bgTexture,
      appFontFamily: appFontFamily ?? this.appFontFamily,
      cardRadiusStyle: cardRadiusStyle ?? this.cardRadiusStyle,
      borderWidthStyle: borderWidthStyle ?? this.borderWidthStyle,
      searchBarShape: searchBarShape ?? this.searchBarShape,
      definitionDensity: definitionDensity ?? this.definitionDensity,
    );
  }
}
