# Flutter Proguard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# SQLite Rules
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }

# Notification Rules
-keep class com.dexterous.** { *; }
-keep class androidx.core.app.CoreComponentFactory { *; }

# Desugaring Rules
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Rxdart Rules
-keep class io.reactivex.** { *; }
-keep class io.reactivex.rxjava3.** { *; }

# Java 8 Time Rules (for timezone support)
-keep class java.time.** { *; }
