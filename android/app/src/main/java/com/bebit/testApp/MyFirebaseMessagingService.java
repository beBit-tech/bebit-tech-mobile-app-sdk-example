package com.bebit.testApp;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import com.bebittech.omnisegment.OmniSegment;
import com.bebit.testApp.Activity.CartActivity;
import com.bebit.testApp.Activity.MainActivity;
import com.bebit.testApp.Activity.ProfileActivity;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import java.io.Serializable;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

public class MyFirebaseMessagingService extends FirebaseMessagingService {

  private static final String TAG = "MyFirebaseMsgService";
  private static final String CHANNEL_ID = "default";

  /* ─────────────── FCM callbacks ─────────────── */

  @Override
  public void onMessageReceived(RemoteMessage msg) {
    Map<String, String> data = msg.getData();

    // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Workflow-triggered-app-popup-setup
    // Purpose: use the app push mechanism to trigger app popups based on incoming push notification data from Firebase.
    // The mechanism involves evaluating notification data to determine whether to display the message or suppress it.
    if (data.containsKey("omnisegment_data")) {
      OmniSegment.handleNotification(data);
      return;
    }

    String title = msg.getNotification() != null ? msg.getNotification().getTitle() : data.get("title");
    String body = msg.getNotification() != null ? msg.getNotification().getBody() : data.get("body");

    Log.d(TAG, "Message received: " + title + " - " + body);
    showNotification(title, body, data);
  }

  @Override
  public void onNewToken(String token) {
    Log.d(TAG, "Refreshed token: " + token);
  }

  /* ─────────────── Notification builder ─────────────── */

  private void showNotification(String title, String body, Map<String, String> data) {

    Intent tapIntent = new Intent(this, NotificationTrampolineActivity.class)
        .putExtra("extra_data", new HashMap<>(data)); // key = "extra_data"

    PendingIntent pendingIntent = PendingIntent.getActivity(
        this, 0, tapIntent,
        PendingIntent.FLAG_ONE_SHOT | PendingIntent.FLAG_IMMUTABLE);

    // Android 8+ channel
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      NotificationChannel ch = new NotificationChannel(
          CHANNEL_ID, "Default Channel", NotificationManager.IMPORTANCE_HIGH);
      getSystemService(NotificationManager.class).createNotificationChannel(ch);
    }

    NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID)
        .setSmallIcon(R.mipmap.ic_launcher)
        .setContentTitle(title)
        .setContentText(body)
        .setPriority(NotificationCompat.PRIORITY_HIGH)
        .setAutoCancel(true)
        .setContentIntent(pendingIntent);

    NotificationManagerCompat.from(this).notify(0, builder.build());
  }

  /* ─────────────── Helpers ─────────────── */

  public static boolean isHttpsUrl(@Nullable String url) {
    if (url == null || !url.startsWith("https:"))
      return false;
    try {
      new URL(url);
      return true;
    } catch (MalformedURLException e) {
      return false;
    }
  }

  /* Maps "dest" → Intent */
  private static final class Navigator {

    static Intent resolve(Context ctx, @Nullable String dest) {
      if ("home".equals(dest))
        return new Intent(ctx, MainActivity.class);
      if ("cart".equals(dest))
        return new Intent(ctx, CartActivity.class);

      if (isHttpsUrl(dest)) {
        if (dest != null && dest.startsWith("https://bebit2.shoplineapp.com")) {
          return new Intent(ctx, ProfileActivity.class).putExtra("url", dest);
        }
        return new Intent(Intent.ACTION_VIEW, Uri.parse(dest));
      }
      return new Intent(ctx, MainActivity.class); // fallback
    }

    private Navigator() {
    }
  }

  public static class NotificationTrampolineActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);

      // ⬇️ pull it back out
      @SuppressWarnings("unchecked")
      Map<String, String> data = (Map<String, String>) getIntent().getSerializableExtra("extra_data");

      if (data == null) {
        finish();
        return;
      }

      String dest = data.get("destination_url");
      Log.d(TAG, "NotifClick" + " User tapped push → " + dest);

      // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Workflow-triggered-app-popup-setup
      // Purpose: use the app push mechanism to trigger app popups based on incoming push notification data from Firebase.
      // The mechanism involves evaluating notification data to determine whether to display the message or suppress it.
      OmniSegment.handleNotification(data, true);

      Intent next = Navigator.resolve(this, dest);
      startActivity(next);
      finish();
    }
  }
}
