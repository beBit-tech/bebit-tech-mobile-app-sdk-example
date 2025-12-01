import React, { useState } from 'react';
import { ActivityIndicator, View, StyleSheet } from 'react-native';
import { WebView } from 'react-native-webview';
import OmniSegment, {
  OSGEventBuilder,
  OSGRecommendRequest,
  OSGRecommendType,
  OSGProduct,
} from "@bebit-tech/omnisegment";
const OrderHistoryScreen = () => {
  const [loading, setLoading] = useState(true);

  const handleLoadEnd = () => {
    setLoading(false);
  };

  return (
    <View style={styles.container}>
      {loading && (
        <ActivityIndicator
          color="#0000ff"
          size="large"
          style={styles.activityIndicator}
        />
      )}
      <WebView 
        source={{ uri: 'https://bebittech.shoplineapp.com/products/安瓶保濕精華' }} 
        onLoadEnd={handleLoadEnd}
        style={loading ? styles.hidden : styles.webView}
        onMessage={(event) => {
          try{
            // OmniSegment SDK
          // Purpose: ensures that events within webview pages are tracked by the SDK.
          // https://github.com/beBit-tech/bebit-tech-react-native-app-sdk/wiki/Usage#integrate-omnisegment-sdk-with-webview-pages
            OmniSegment.handleWebViewMessage(event.nativeEvent.data)
            console.log('Message handled by SDK');
          }catch(error){
            console.log('Message not handled by SDK');
          }
          

        }}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  activityIndicator: {
    position: 'absolute', 
    left: 0, 
    right: 0, 
    top: 0, 
    bottom: 0, 
    alignItems: 'center', 
    justifyContent: 'center'
  },
  webView: {
    flex: 1
  },
  hidden: {
    height: 0,
    flex: 0,
  }
});

export default OrderHistoryScreen;
