import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

fun readKeystoreProp(name: String): String? {
    val direct = keystoreProperties.getProperty(name)?.trim()
    if (!direct.isNullOrEmpty()) {
        return direct
    }

    return keystoreProperties.entries
        .firstOrNull { (it.key as? String)?.trim('\uFEFF', ' ', '\t', '\r', '\n') == name }
        ?.value
        ?.toString()
        ?.trim()
        ?.takeIf { it.isNotEmpty() }
}

val releaseStoreFilePath = readKeystoreProp("storeFile")
val releaseStorePassword = readKeystoreProp("storePassword")
val releaseKeyAlias = readKeystoreProp("keyAlias")
val releaseKeyPassword = readKeystoreProp("keyPassword")

val hasCompleteReleaseSigning =
    !releaseStoreFilePath.isNullOrBlank() &&
    !releaseStorePassword.isNullOrBlank() &&
    !releaseKeyAlias.isNullOrBlank() &&
    !releaseKeyPassword.isNullOrBlank()

android {
    namespace = "com.semaimi.cipherguard"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.semaimi.cipherguard"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (hasCompleteReleaseSigning) {
                storeFile = file(releaseStoreFilePath!!)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasCompleteReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
