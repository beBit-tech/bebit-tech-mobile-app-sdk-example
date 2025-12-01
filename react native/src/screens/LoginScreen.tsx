import React, { useState } from "react";
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  ToastAndroid,
} from "react-native";
import {
  COLORS,
  FONTFAMILY,
  FONTSIZE,
  SPACING,
  BORDERRADIUS,
} from "../theme/theme";
import CustomIcon from "../components/CustomIcon";

import OmniSegment, {
  OSGEventBuilder,
  OSGProduct,
} from "@bebit-tech/omnisegment";

const LoginScreen = ({ navigation }: any) => {
  const [username, setUsername] = useState("Test@App");
  const [password, setPassword] = useState("Test");

  const handleLogin = () => {
    ToastAndroid.showWithGravity(
      "Login Successful",
      ToastAndroid.SHORT,
      ToastAndroid.CENTER
    );
    // OmniSegment SDK
    // Purpose: Track current page/screen for user journey analytics
    // https://github.com/beBit-tech/bebit-tech-react-native-app-sdk/wiki/Usage#set-current-page
    OmniSegment.setCurrentPage("Login");
    OmniSegment.login("omnisegment20240101")

    navigation.navigate("Tab", { screen: "Home" });
  };

  const handleRegister = () => {
    OmniSegment.setCurrentPage("Register");
    // OmniSegment SDK
    // Purpose: Track event
    // https://github.com/beBit-tech/bebit-tech-react-native-app-sdk/wiki/Track-events
    const event = OSGEventBuilder.completeRegistration({email: 'renee@bebit-tech.com'})
    event.location = 'app://Register'
    event.locationTitle = 'Register'
    OmniSegment.trackEvent(event);

    navigation.navigate("Tab", { screen: "Home" });
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Welcome Back!</Text>
      <View style={styles.inputContainer}>
        <CustomIcon
          name='bean'
          size={FONTSIZE.size_18}
          color={COLORS.primaryLightGreyHex}
          style={styles.icon}
        />
        <TextInput
          placeholder='Username'
          value={username}
          onChangeText={setUsername}
          style={styles.input}
        />
      </View>
      <View style={styles.inputContainer}>
        <CustomIcon
          name='bean'
          size={FONTSIZE.size_18}
          color={COLORS.primaryLightGreyHex}
          style={styles.icon}
        />
        <TextInput
          placeholder='Password'
          value={password}
          onChangeText={setPassword}
          secureTextEntry
          style={styles.input}
        />
      </View>
      <TouchableOpacity style={styles.button} onPress={handleLogin}>
        <Text style={styles.buttonText}>Login</Text>
      </TouchableOpacity>
      <TouchableOpacity style={styles.button} onPress={handleRegister}>
        <Text style={styles.buttonText}>Register</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: COLORS.primaryBlackHex,
    padding: SPACING.space_30,
  },
  title: {
    fontSize: FONTSIZE.size_28,
    fontFamily: FONTFAMILY.poppins_semibold,
    color: COLORS.primaryWhiteHex,
    marginBottom: SPACING.space_36,
  },
  inputContainer: {
    flexDirection: "row",
    marginVertical: SPACING.space_10,
    borderRadius: BORDERRADIUS.radius_20,
    backgroundColor: COLORS.primaryDarkGreyHex,
    alignItems: "center",
    width: "100%",
    paddingHorizontal: SPACING.space_20,
  },
  icon: {
    marginRight: SPACING.space_10,
  },
  input: {
    flex: 1,
    fontFamily: FONTFAMILY.poppins_medium,
    fontSize: FONTSIZE.size_14,
    color: COLORS.primaryWhiteHex,
  },
  button: {
    marginTop: SPACING.space_20,
    backgroundColor: COLORS.primaryOrangeHex,
    borderRadius: BORDERRADIUS.radius_20,
    paddingVertical: SPACING.space_12,
    paddingHorizontal: SPACING.space_30,
    width: "100%",
    alignItems: "center",
  },
  buttonText: {
    fontFamily: FONTFAMILY.poppins_medium,
    fontSize: FONTSIZE.size_16,
    color: COLORS.primaryWhiteHex,
  },
});

export default LoginScreen;
