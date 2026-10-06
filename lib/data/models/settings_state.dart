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

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.accentColor = const Color(0xFF6344FF),
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
    );
  }
}
