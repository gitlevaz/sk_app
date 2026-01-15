plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

dependencies {
    // ✅ Firebase BoM (Bill of Materials)
    implementation(platform("com.google.firebase:firebase-bom:34.5.0"))

    // ✅ Optional Firebase Analytics (for verification)
    implementation("com.google.firebase:firebase-analytics")

    // ✅ Kotlin stdlib (usually auto-added)
    implementation("org.jetbrains.kotlin:kotlin-stdlib")
         // ✅ Kotlin DSL version
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

android {
    namespace = "com.example.sahakaru"
    // compileSdk = flutter.compileSdkVersion
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

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
        applicationId = "com.example.sahakaru"
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
}



// plugins {
//     id("com.android.application")
//     id("kotlin-android")
//     id("dev.flutter.flutter-gradle-plugin")
//     id("com.google.gms.google-services")
// }

// android {
//     namespace = "com.example.sahakaru"
//     compileSdk = 36
//     ndkVersion = flutter.ndkVersion

//     defaultConfig {
//         applicationId = "com.example.sahakaru"
//         minSdk = flutter.minSdkVersion
//         targetSdk = flutter.targetSdkVersion
//         versionCode = flutter.versionCode
//         versionName = flutter.versionName
//     }

//     compileOptions {
//         sourceCompatibility = JavaVersion.VERSION_1_8
//         targetCompatibility = JavaVersion.VERSION_1_8
//         isCoreLibraryDesugaringEnabled = true  // ✅ Kotlin DSL requires 'isCoreLibraryDesugaringEnabled'
//     }

//     kotlinOptions {
//         jvmTarget = "1.8"
//     }

//     buildTypes {
//         release {
//             signingConfig = signingConfigs.getByName("debug")
//         }
//     }
// }

// dependencies {
//     implementation(platform("com.google.firebase:firebase-bom:34.5.0"))
//     implementation("com.google.firebase:firebase-analytics")
//     implementation("org.jetbrains.kotlin:kotlin-stdlib")

//     // ✅ Kotlin DSL version
//     coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
// }
