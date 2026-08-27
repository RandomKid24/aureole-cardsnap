# ─────────────────────────────────────────────────────────────────────────────
# CardSnap release (R8) keep rules.
# Flutter's Gradle plugin auto-applies this file when it exists.
# ─────────────────────────────────────────────────────────────────────────────

# ── Google ML Kit text recognition ──────────────────────────────────────────
# The plugin references every script recognizer (Chinese, Devanagari, Japanese,
# Korean) but we only bundle the Latin model, so R8 sees the others as missing.
# We don't use those scripts — silence the warnings.
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions

# Keep ML Kit / Play Services vision internals (reflection-driven).
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_common.** { *; }
-dontwarn com.google.mlkit.**

# ── flutter_local_notifications ─────────────────────────────────────────────
# Uses GSON to (de)serialize scheduled-notification details. Without these rules
# generic type information is stripped and rescheduling after reboot breaks.
-keep class com.dexterous.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-dontwarn sun.misc.**
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep public class * implements java.lang.reflect.Type
