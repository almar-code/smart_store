plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.omarabdalfatah.smart_store"
    compileSdk = 35 // يفضل استخدام 35 حالياً لضمان الاستقرار مع المكتبات
    ndkVersion = flutter.ndkVersion
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.omarabdalfatah.smart_store"
        minSdk = 23
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        val mapsApiKey = (project.findProperty("MAPS_API_KEY") as? String) ?: ""

        manifestPlaceholders.putAll(mapOf(
            "MAPS_API_KEY" to mapsApiKey
        ))
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}