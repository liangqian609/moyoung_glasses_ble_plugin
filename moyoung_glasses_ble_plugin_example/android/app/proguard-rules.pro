# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /Users/bill/Library/Android/sdk/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add any project specific keep options here:

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}


-keep class com.crrepa.ble.** { *; }
-keep class com.moyoung.moyoung_ble_plugin.** { *; }

# 抑制 SDK 中引用但未包含的类的警告
# Suppress warnings for classes referenced but not included in SDK
-dontwarn com.blankj.utilcode.util.ArrayUtils
-dontwarn com.blankj.utilcode.util.ConvertUtils
-dontwarn com.jieli.bmp_convert.BmpConvert
-dontwarn com.jieli.bmp_convert.OnConvertListener
-dontwarn com.realsil.sdk.core.bluetooth.BluetoothProfileManager
-dontwarn com.yanzhenjie.kalle.BodyRequest$Api
-dontwarn com.yanzhenjie.kalle.Canceller
-dontwarn com.yanzhenjie.kalle.JsonBody
-dontwarn com.yanzhenjie.kalle.Kalle
-dontwarn com.yanzhenjie.kalle.Request$Api
-dontwarn com.yanzhenjie.kalle.RequestBody
-dontwarn com.yanzhenjie.kalle.StringBody
-dontwarn com.yanzhenjie.kalle.simple.Callback
-dontwarn com.yanzhenjie.kalle.simple.SimpleBodyRequest$Api
-dontwarn com.yanzhenjie.kalle.simple.SimpleCallback

-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}
