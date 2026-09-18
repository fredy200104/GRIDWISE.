plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // ID único de la aplicación GridWise en el ecosistema Android
    namespace = "com.gridwise.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Application ID único para GridWise en Google Play Store
        applicationId = "com.gridwise.app"

        // minSdk 23 requerido por:
        //   - firebase_auth (autenticación biométrica, secure storage)
        //   - google_sign_in (OAuth 2.0 con Chrome Custom Tabs)
        //   - image_picker (acceso a MediaStore moderno)
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Para producción real: configurar signing con keystore propio.
            // Ver: https://docs.flutter.dev/deployment/android#create-an-upload-keystore
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
