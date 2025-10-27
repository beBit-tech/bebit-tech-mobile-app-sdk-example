package com.bebit.testApp.Helper;

import android.net.Uri;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.HashMap;
import java.util.Map;

public class URLUtils {

  public static String modifyUrlQueryParams(String urlString, Map<String, String> queryParams)
      throws URISyntaxException {
    // Parse the URL string into a URI object
    URI uri = new URI(urlString);

    // Create a Uri.Builder from the existing URI
    Uri.Builder uriBuilder = Uri.parse(uri.toString()).buildUpon();

    // Parse the existing query parameters into a map
    Uri existingUri = Uri.parse(uri.toString());
    Map<String, String> existingParams = new HashMap<>();
    for (String queryParam : existingUri.getQueryParameterNames()) {
      existingParams.put(queryParam, existingUri.getQueryParameter(queryParam));
    }

    // Merge existing parameters with new ones
    existingParams.putAll(queryParams);

    // Clear existing query parameters in the builder
    uriBuilder.clearQuery();

    // Add all merged query parameters to the builder
    for (Map.Entry<String, String> entry : existingParams.entrySet()) {
      uriBuilder.appendQueryParameter(entry.getKey(), entry.getValue());
    }

    // Build the new URI
    Uri newUri = uriBuilder.build();

    // Return the new URI as a string
    return newUri.toString();
  }
}
