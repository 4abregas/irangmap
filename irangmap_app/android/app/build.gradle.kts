import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val localProperties = Properties().apply {
    val file = rootProject.file("local.properties")
    if (file.exists()) {
        file.inputStream().use(::load)
    }
}

val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) {
        file.inputStream().use(::load)
    }
}

val hasReleaseKeystore = !keystoreProperties.getProperty("storeFile").isNullOrBlank()

val googleMapsApiKey =
    providers.gradleProperty("IRANGMAP_GOOGLE_MAPS_API_KEY_ANDROID").orNull
        ?: localProperties.getProperty("IRANGMAP_GOOGLE_MAPS_API_KEY_ANDROID", "")

val admobAppId =
    providers.gradleProperty("IRANGMAP_ADMOB_APP_ID_ANDROID").orNull
        ?: localProperties.getProperty(
            "IRANGMAP_ADMOB_APP_ID_ANDROID",
            "ca-app-pub-3940256099942544~3347511713",
        )

android {
    namespace = "com.irangmap.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            val storeFilePath = keystoreProperties.getProperty("storeFile")
            if (hasReleaseKeystore) {
                storeFile = file(storeFilePath)
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    defaultConfig {
        applicationId = "com.irangmap.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["irangmapGoogleMapsApiKey"] = googleMapsApiKey
        manifestPlaceholders["irangmapAdmobAppId"] = admobAppId
    }

    buildTypes {
        release {
            signingConfig =
                if (!hasReleaseKeystore) {
                    signingConfigs.getByName("debug")
                } else {
                    signingConfigs.getByName("release")
                }
        }
    }
}

flutter {
    source = "../.."
}
