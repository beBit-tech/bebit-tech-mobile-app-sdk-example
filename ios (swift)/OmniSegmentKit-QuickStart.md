# OmniSegmentKit Quick Start Guide

This guide demonstrates how to integrate and use OmniSegmentKit SDK in your iOS app, based on the ShopDemo implementation.

## 1. Installation

Add OmniSegmentKit to your project using Swift Package Manager or follow the [installation guide](https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Installation).

## 2. Basic Setup

### Import the SDK

```swift
import OmniSegmentKit
```

### Initialize in AppDelegate

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configure endpoints
        let omniSegmentInstance = OmniSegment()
        omniSegmentInstance.changeEventApiEndpoint("https://staging.omnicloud.tech/api/v1/beacon/track-event/")
        omniSegmentInstance.changeBackgroundServiceURL("https://omnitag-staging.omniscientai.com/appPopup.js?env=TW_STAGING")
        omniSegmentInstance.changeApiHost("https://staging.omnicloud.tech")
        
        // Initialize with API key and TID
        OmniSegment.enableDebugLogs()
        OmniSegment.initialize("YOUR_API_KEY", tid: "YOUR_TID")
        
        // Set app metadata
        OmniSegment.setAppName("your-app-name")
        OmniSegment.setBundleId("your-bundle-id")
        OmniSegment.setBundleVersion("your-version")
        
        // Set device ID
        if let deviceId = UIDevice.current.identifierForVendor?.uuidString {
            OmniSegment.setDeviceId(deviceId)
        }
        
        return true
    }
}
```

## 3. Page Tracking

Track page views when users navigate to different screens:

```swift
struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .onAppear {
                    OmniSegment.setCurrentPage("Home")
                }
            
            CartView()
                .onAppear {
                    OmniSegment.setCurrentPage("Cart")
                }
        }
    }
}
```

## 4. E-commerce Event Tracking

### Add to Cart

```swift
Button("Add to Cart") {
    // Your cart logic
    cartManager.addToCart(product: product)
    
    // Track with OmniSegment
    let productIdString = product.id.uuidString
    let osgProduct = OSGProduct(id: productIdString, name: product.name)
    osgProduct.price = NSNumber(value: product.price)
    
    var event = OSGEvent.addToCart([osgProduct])
    event.location = "ProductList"
    event.locationTitle = "YourAppName"
    OmniSegment.trackEvent(event)
}
```

### Remove from Cart

```swift
Button("Remove") {
    // Your cart logic
    cartManager.removeFromCart(product: product)
    
    // Track with OmniSegment
    let productIdString = product.id.uuidString
    let osgProduct = OSGProduct(id: productIdString, name: product.name)
    
    let event = OSGEvent.removeFromCart([osgProduct])
    event.location = "Cart"
    event.locationTitle = "YourAppName"
    OmniSegment.trackEvent(event)
}
```

### Add to Wishlist

```swift
Button("Add to Wishlist") {
    // Track with OmniSegment
    let productIdString = product.id.uuidString
    let osgProduct = OSGProduct(id: productIdString, name: product.name)
    osgProduct.price = NSNumber(value: product.price)
    
    var event = OSGEvent.addToWishlist([osgProduct])
    event.location = "ProductList"
    event.locationTitle = "YourAppName"
    OmniSegment.trackEvent(event)
}
```

## 5. Firebase Cloud Messaging Integration

### Setup FCM Token

```swift
// In MessagingDelegate
func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    if let fcmToken = fcmToken {
        OmniSegment.setFCMToken(fcmToken)
        OmniSegment.trackEvent(OSGEvent.appOpen())
    }
}
```

### Handle Push Notifications

```swift
private func handleNotification(_ userInfo: [AnyHashable: Any]) {
    if let omniSegmentData = userInfo["omnisegment_data"] {
        OmniSegment.handleNotification(userInfo: userInfo)
    }
    
    if let destinationURL = userInfo["destination_url"] as? String,
       let trackingURL = userInfo["omnisegment_tracking_url"] as? String {
        // Handle tracking URL
        callTrackingURL(trackingURL)
        
        // Handle deep link
        if let url = URL(string: destinationURL) {
            handleDeepLink(url)
        }
    }
}
```

## 6. Common Event Types

- `OSGEvent.appOpen()` - Track app launches
- `OSGEvent.addToCart([products])` - Track add to cart actions
- `OSGEvent.removeFromCart([products])` - Track remove from cart actions
- `OSGEvent.addToWishlist([products])` - Track wishlist additions
- `OmniSegment.setCurrentPage(pageName)` - Track page views

## 7. Product Object Format

```swift
let osgProduct = OSGProduct(id: "product-id", name: "Product Name")
osgProduct.price = NSNumber(value: 29.99)
// Add other product properties as needed
```

## 8. Best Practices

1. **Always set location and locationTitle** for events to provide context
2. **Use consistent page names** for better analytics
3. **Convert product IDs to strings** when creating OSGProduct objects
4. **Enable debug logs** during development
5. **Handle FCM tokens** for push notification analytics

## 9. Documentation Links

- [Installation Guide](https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Installation)
- [Track Events](https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events)
- [Built-in Events](https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events)
- [OSGProduct Properties](https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#osgproduct-properties)

