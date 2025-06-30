plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.addons.attendance.attendance"
    compileSdk = flutter.compileSdkVersion
     ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.addons.attendance.attendance"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
signingConfigs {
    create("release") {
        storeFile = file("H:/AppKeys/NassarAttend.jks")
        storePassword = "Disha2000$"
        keyAlias = "Mustafa"
        keyPassword = "Disha2000$"
    }
}
    buildTypes {
        release {
        isMinifyEnabled = true
        isShrinkResources = true
        signingConfig = signingConfigs.getByName("release")  
    }
    }

      splits {
        abi {
            isEnable = true;
            reset();
            include(*setOf("x86", "x86_64", "armeabi-v7a", "arm64-v8a").toTypedArray());
            isUniversalApk = true;
        }
    }
}

flutter {
    source = "../.."
}
