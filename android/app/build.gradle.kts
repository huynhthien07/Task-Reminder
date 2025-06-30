plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    
}

android {
    namespace = "com.example.task_remider_app"
    compileSdk = flutter.compileSdkVersion
    //ndkVersion = flutter.ndkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.task_remider_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
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
}


dependencies {
    // Core library desugaring for notification support
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

    // Firebase BoM (Bill of Materials) giúp quản lý phiên bản cho các thư viện Firebase
    implementation(platform("com.google.firebase:firebase-bom:33.15.0"))

    // Firebase Analytics (chỉ cần thêm các dịch vụ bạn sử dụng)
    implementation("com.google.firebase:firebase-analytics")

    // Thêm các Firebase services khác mà bạn sử dụng
    // Ví dụ, nếu bạn sử dụng Firestore:
    implementation("com.google.firebase:firebase-firestore")

    // Nếu sử dụng Firebase Auth:
    implementation("com.google.firebase:firebase-auth")
}

flutter {
    source = "../.."
}
