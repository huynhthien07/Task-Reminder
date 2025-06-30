buildscript {
    repositories {
        google()  // Kho lưu trữ Google
        mavenCentral()  // Kho lưu trữ Maven
    }
    dependencies {
        classpath("com.android.tools.build:gradle:7.0.4")  // Đảm bảo sử dụng đúng phiên bản
        classpath("com.google.gms:google-services:4.4.2")  // Firebase plugin
    }
}

allprojects {
    repositories {
        google()  // Đảm bảo kho lưu trữ Google có sẵn
        mavenCentral()  // Đảm bảo kho lưu trữ Maven có sẵn
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
