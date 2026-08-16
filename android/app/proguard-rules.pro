-keep class com.sun.jna.* { *; }
-keepclassmembers class * extends com.sun.jna.* { public *; }

# JNA's optional desktop/AWT integration is never used on Android; the
# classes don't exist on-device, so tell R8 not to fail on them.
-dontwarn java.awt.**
