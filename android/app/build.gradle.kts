plugins {
id("com.android.application")
id("com.google.gms.google-services")
id("dev.flutter.flutter-gradle-plugin")
}

android {
namespace = "com.example.service_finder"
compileSdk = flutter.compileSdkVersion
ndkVersion = flutter.ndkVersion


compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

defaultConfig {
    applicationId = "com.example.service_finder"
    minSdk = flutter.minSdkVersion
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")
    }
}


}

dependencies {
coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

kotlin {
compilerOptions {
jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
}
}

flutter {
source = "../.."
}
