package com.bebit.testApp;

import android.app.Application;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.provider.Settings;
import android.content.Context;
import android.os.Build;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import android.util.Log;
import android.widget.Toast;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.FirebaseMessaging;

import com.bebittech.omnisegment.OSGEvent;
import com.bebittech.omnisegment.OmniSegment;

public class TestApplication extends Application {

  private static final String TAG = "MainActivity";

  @Override
  public void onCreate() {
    super.onCreate();
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      NotificationChannel channel = new NotificationChannel(
          "default",
          "Default Channel",
          NotificationManager.IMPORTANCE_HIGH);
      NotificationManager manager = getSystemService(NotificationManager.class);
      manager.createNotificationChannel(channel);
    }

    // OmniSegment SDK Initialization
    // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Usage#enable-debug-logs
    // Purpose: Enable debug logs for development/testing to see SDK events in logcat
    OmniSegment.enableDebugLogs(true);

    // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Installation#step-2---initialize-omnisegment
    // Purpose: Initialize OmniSegment SDK with your API key and organization ID
    // Replace with your actual API key and organization ID from the OmniSegment dashboard
    OmniSegment.initialize(this, "xxx-xxx-xxx-xxx-xxx", "OA-XXX");

    // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Track-events#track-events
    // Purpose: Set application metadata for tracking and analytics
    OmniSegment.setAppId("test-AppId");
    OmniSegment.setAppName("test-AppName");
    OmniSegment.setAppVersion("test-2024090401");

    // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Track-events#track-events
    // Purpose: Set unique device identifier for user tracking across sessions
    String deviceId = Settings.Secure.getString(getContentResolver(), Settings.Secure.ANDROID_ID);
    OmniSegment.setDeviceId(deviceId);
    FirebaseApp.initializeApp(this);

    FirebaseMessaging.getInstance().getToken()
        .addOnCompleteListener(new OnCompleteListener<String>() {
          @Override
          public void onComplete(@NonNull Task<String> task) {
            if (!task.isSuccessful()) {
              Log.w(TAG, "Fetching FCM registration token failed", task.getException());
              return;
            }

            String token = task.getResult();

            Log.d(TAG, "FCM registration token: " + token);

            // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Usage#set-firebase-cloud-messaging-token
            // Purpose: Register FCM token with OmniSegment to enable push notifications
            OmniSegment.setFCMToken(token);

            // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Send-Action-(Event)-Examples#app-open
            // Purpose: Track app open event for user engagement analytics
            OmniSegment.trackEvent(OSGEvent.appOpen());
          }
        });
  }
}
