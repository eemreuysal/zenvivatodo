plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.zenvivatodo"
    compileSdk = 34 // Android 14
    ndkVersion = "27.0.12077973"

    compileOptions {
        // Desugaring için Java 11 kullanımı
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Desugaring etkinleştirme
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.zenvivatodo"
        minSdk = 23 // Android 6.0 (Marshmallow) için daha iyi destek
        targetSdk = 34 // Android 14
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // MultiDex desteği
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // Optimizasyonlar
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug")
        }
        
        debug {
            // Debug için optimizasyonlar
            applicationIdSuffix = ".debug"
            isDebuggable = true
        }
    }
    
    // Lint kontrolleri
    lint {
        disable += "MissingTranslation"
        abortOnError = false
    }
    
    // Çoklu APK desteği
    splits {
        abi {
            isEnable = true
            reset()
            include("armeabi-v7a", "arm64-v8a", "x86_64")
            isUniversalApk = false
        }
    }
}

// Desugaring ve MultiDex bağımlılıkları
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
    implementation("androidx.multidex:multidex:2.0.1")
}

flutter {
    source = "../.."
}
