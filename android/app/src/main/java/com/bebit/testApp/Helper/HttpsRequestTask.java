package com.bebit.testApp.Helper;

import android.os.AsyncTask;
import android.util.Log;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

import java.io.IOException;

public class HttpsRequestTask extends AsyncTask<String, Void, String> {

  private static final String TAG = "HttpsRequestTask";
  private OkHttpClient client = new OkHttpClient();
  private HttpsRequestCallback callback;

  public interface HttpsRequestCallback {
    void onResponse(String response);

    void onFailure(Exception e);
  }

  public HttpsRequestTask(HttpsRequestCallback callback) {
    this.callback = callback;
  }

  @Override
  protected String doInBackground(String... params) {
    String urlString = params[0];
    Request request = new Request.Builder()
        .url(urlString)
        .build();

    try (Response response = client.newCall(request).execute()) {
      if (response.isSuccessful() && response.body() != null) {
        return response.body().string();
      } else {
        Log.e(TAG, "GET request failed: " + response.code());
        return null;
      }
    } catch (IOException e) {
      Log.e(TAG, "Exception in GET request: ", e);
      return null;
    }
  }

  @Override
  protected void onPostExecute(String result) {
    if (result != null) {
      Log.d(TAG, "Response: " + result);
      callback.onResponse(result);
    } else {
      callback.onFailure(new IOException("Failed to fetch data"));
    }
  }
}
