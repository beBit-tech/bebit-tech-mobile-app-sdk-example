package com.coffee_shop_app

import android.app.Application
import com.bebittechreactnativeappsdk.OmniSegmentModule
import com.facebook.react.PackageList
import com.facebook.react.ReactApplication
import com.facebook.react.ReactNativeHost
import com.facebook.react.ReactPackage
import com.facebook.react.defaults.DefaultNewArchitectureEntryPoint.load
import com.facebook.react.defaults.DefaultReactNativeHost
import com.facebook.soloader.SoLoader

class MainApplication : Application(), ReactApplication {
  private val mReactNativeHost: ReactNativeHost = object : DefaultReactNativeHost(this) {
    override fun getUseDeveloperSupport(): Boolean {
      return BuildConfig.DEBUG
    }

    override fun getPackages(): List<ReactPackage> {
      
      return PackageList(this).packages
    }

    override fun getJSMainModuleName(): String {
      return "index"
    }

    override val isNewArchEnabled: Boolean
      protected get() = BuildConfig.IS_NEW_ARCHITECTURE_ENABLED
    override val isHermesEnabled: Boolean
      protected get() = BuildConfig.IS_HERMES_ENABLED
  }

  override fun getReactNativeHost(): ReactNativeHost {
    return mReactNativeHost
  }

  override fun onCreate() {
    super.onCreate()
    SoLoader.init(this,  /* native exopackage */false)
    // OmniSegmentKit SDK Initialization
    // Installation Guide: https://github.com/beBit-tech/bebit-tech-react-native-app-sdk/wiki/Installation
    // Enable debug logs and initialize with API key and TID
    // Please modify the key and tid from your omnisegment organization setting
    OmniSegmentModule.enableDebugLogs(true)
    OmniSegmentModule.initialize(this, "XXXXXX-XXXXXX-XXXXX-XXXXXX-XXXXXX", "OA-XXXXXX")
    if (BuildConfig.IS_NEW_ARCHITECTURE_ENABLED) {
      // If you opted-in for the New Architecture, we load the native entry point for this app.
      load()
    }
  }
}