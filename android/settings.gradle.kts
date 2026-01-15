// pluginManagement {
//     repositories {
//         google()
//         mavenCentral()
//         gradlePluginPortal()
//         maven { url = uri("https://jitpack.io") }   // For PayHere
//     }
// }

// plugins {
//     id("com.android.application") version "8.9.1" apply false
//     id("org.jetbrains.kotlin.android") version "2.1.0" apply false

//     // Flutter plugin loader – correct one
//     id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false

//     // Firebase / Google services
//     id("com.google.gms.google-services") version("4.3.15") apply false
// }

// include(":app")

// dependencyResolutionManagement {
//     repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
//     repositories {
//         google()
//         mavenCentral()
//         maven { url = uri("https://jitpack.io") }   // Still needed for PayHere
//     }
// }

pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.3.15") apply false
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
