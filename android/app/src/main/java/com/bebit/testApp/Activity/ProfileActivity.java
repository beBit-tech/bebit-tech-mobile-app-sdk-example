package com.bebit.testApp.Activity;

import android.os.Bundle;
import android.os.Handler;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.util.Log;

import androidx.appcompat.app.AppCompatActivity;

import com.bebittech.omnisegment.OmniSegment;
import com.bebit.testApp.R;

public class ProfileActivity extends AppCompatActivity {

  private WebView webView;
  private Handler handler;
  private Runnable resetLocationRunnable;
  private static final int RESET_DELAY = 3000;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_profile);

    handler = new Handler();

    webView = findViewById(R.id.webview);
    webView.setWebViewClient(new CustomWebViewClient());

    WebSettings webSettings = webView.getSettings();
    webSettings.setJavaScriptEnabled(true); // Enable JavaScript
    webSettings.setDomStorageEnabled(true); // Enable DOM storage API
    webSettings.setLoadWithOverviewMode(true); // Loads the WebView completely zoomed out
    webSettings.setUseWideViewPort(true); // Enables wide viewport
    webSettings.setCacheMode(WebSettings.LOAD_DEFAULT); // Use default cache mode

    String url = getIntent().getStringExtra("url");
    if (url != null && !url.isEmpty()) {
      webView.loadUrl(url);
    } else {
      webView.loadUrl("https://bebit2.shoplineapp.com/");
    }
    // OmniSegment SDK
    // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Usage#integrating-omnisegment-sdk-with-webview-pages-in-android
    // Purpose: Enable OmniSegment tracking in WebView by injecting JavaScript interface for web-to-native event communication
    OmniSegment.addOmniSegmentJavascriptInterface(webView);
  }

  @Override
  protected void onResume() {
    super.onResume();
    // OmniSegment SDK
    // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Usage#set-current-page
    // Purpose: Track current page/screen for user journey analytics
    OmniSegment.setCurrentPage("Webview");
  }

  private class CustomWebViewClient extends WebViewClient {
    @Override
    public boolean shouldOverrideUrlLoading(WebView view, String url) {
      view.loadUrl(url);
      if (resetLocationRunnable != null) {
        handler.removeCallbacks(resetLocationRunnable);
      }
      // OmniSegment SDK
      // Wiki: https://github.com/beBit-tech/bebit-tech-android-app-sdk/wiki/Usage#managing-webview-document-location
      // Purpose: Reset WebView location tracking when navigating to new pages for accurate page view analytics
      OmniSegment.resetWebViewLocation();
      return true;
    }
  }
}
