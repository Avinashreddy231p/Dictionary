# Flutter ProGuard/R8 Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class io.flutter.plugin.editing.** { *; }

# Suppress warnings for missing Play Core deferred components optional classes
-dontwarn com.google.android.play.core.**

# LiteRT / TensorFlow Lite keep rules
-keep class com.google.ai.edge.** { *; }
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**
-dontwarn com.google.ai.edge.**

# Drift / SQLite3 keep rules
-keep class com.simonbinder.sqlite3.** { *; }
