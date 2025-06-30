buildscript {
    repositories {
        google()  // Thêm kho lưu trữ Google
        mavenCentral()  // Thêm kho lưu trữ Maven
    }
    dependencies {
        classpath("com.android.tools.build:gradle:7.0.4")  // Đảm bảo sử dụng phiên bản phù hợp
        classpath("com.google.gms:google-services:4.4.2")  // Firebase plugin
    }
}

allprojects {
    repositories {
        google()  // Đảm bảo kho lưu trữ Google được cấu hình
        mavenCentral()  // Đảm bảo kho lưu trữ Maven được cấu hình
    }
}
