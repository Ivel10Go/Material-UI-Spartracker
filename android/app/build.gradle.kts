plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    // Es bringt zugleich das Kotlin-Plugin mit ("Built-in Kotlin"), weshalb
    // der Compose-Compiler danach kommt.
    id("dev.flutter.flutter-gradle-plugin")
    // Compose-Compiler für das Homescreen-Widget (Glance) und dessen
    // Einstellungen. Seit Kotlin 2.0 folgt die Version dem Kotlin-Release.
    id("org.jetbrains.kotlin.plugin.compose")
}

android {
    namespace = "com.spartracker.spartracker"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.spartracker.spartracker"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    buildFeatures {
        compose = true
    }
}

dependencies {
    // Compose-Versionen kommen gebündelt aus der BOM - so passen Runtime,
    // UI und Material 3 garantiert zusammen.
    implementation(platform("androidx.compose:compose-bom:2024.09.00"))

    // Glance zeichnet das Homescreen-Widget. GlanceTheme liefert dabei ab
    // Android 12 die Wallpaper-Farben, also denselben Material-You-Look,
    // den die App über dynamic_color bekommt.
    implementation("androidx.glance:glance-appwidget:1.1.1")
    implementation("androidx.glance:glance-material3:1.1.1")

    // Widget-Einstellungen als Compose-Material-3-Bildschirm.
    implementation("androidx.activity:activity-compose:1.9.2")
    implementation("androidx.compose.material3:material3")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
