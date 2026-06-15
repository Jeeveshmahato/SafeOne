# Keep generic signatures & annotations — Gson needs these at runtime, and R8
# strips them by default. Without this, flutter_local_notifications crashes when
# it (de)serializes a scheduled notification:
#   "TypeToken must be created with a type argument ... make sure that generic
#    signatures are preserved."
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# flutter_local_notifications (com.dexterous.*) and the Gson models it serializes.
-keep class com.dexterous.** { *; }

# Gson itself + anything using TypeToken / reflection-based (de)serialization.
-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep public class * implements java.lang.reflect.Type
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Flutter engine (defensive; usually covered by the default Flutter rules).
-keep class io.flutter.** { *; }

# Flutter references Play Core (deferred components / split install) classes that
# this app doesn't bundle. They're optional — tell R8 not to fail on them.
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
