import React, { useEffect } from "react";
import { NavigationContainer } from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";
import TabNavigator from "./src/navigators/TabNavigator";
import DetailsScreen from "./src/screens/DetailsScreen";
import PaymentScreen from "./src/screens/PaymentScreen";
import SplashScreen from "react-native-splash-screen";
import LoginScreen from "./src/screens/LoginScreen";
import OmniSegment, {
  OSGEventBuilder,
} from "@bebit-tech/omnisegment";
const Stack = createNativeStackNavigator();

const App = () => {
  useEffect(() => {
    SplashScreen.hide();
    // OmniSegment SDK
    // MARK: - OmniSegmentKit SDK Initialization
    // Please modify the key and tid from your omnisegment organization setting
    // https://github.com/beBit-tech/bebit-tech-react-native-app-sdk/wiki/Track-events
    // Handle FCM token registration and track app open events
    // FCM Token Setup: https://github.com/beBit-tech/bebit-tech-react-native-app-sdk/wiki/Usage#set-firebase-cloud-messaging-token
    OmniSegment.setFCMToken("Test FCM Token from RN");
    OmniSegment.setAppId("TestAppId");
    OmniSegment.setAppVersion("TestAppVersion");
    OmniSegment.setAppName("TestAppName");
    OmniSegment.setDeviceId("TestDeviceId");
    const event = OSGEventBuilder.appOpen()
    event.location = 'app://LaunchApp'
    event.locationTitle = 'RN Test App @OpenApp'
    OmniSegment.trackEvent(event);
  }, []);
  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        <Stack.Screen name="Login" component={LoginScreen} />

        <Stack.Screen
          name="Tab"
          component={TabNavigator}
          options={{ animation: "slide_from_bottom" }}
        ></Stack.Screen>
        <Stack.Screen
          name="Details"
          component={DetailsScreen}
          options={{ animation: "slide_from_bottom" }}
        ></Stack.Screen>
        <Stack.Screen
          name="Payment"
          component={PaymentScreen}
          options={{ animation: "slide_from_bottom" }}
        ></Stack.Screen>
      </Stack.Navigator>
    </NavigationContainer>
  );
};

export default App;
