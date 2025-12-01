import React from 'react';
import {StyleSheet, Image, View, TouchableOpacity, ToastAndroid} from 'react-native';
import {COLORS, SPACING} from '../theme/theme';
import OmniSegment, {
  OSGEventBuilder,
  OSGRecommendRequest,
  OSGRecommendType,
  OSGProduct,
} from "@bebit-tech/omnisegment";

const ProfilePic = ({navigation}: any) => {
  return (
    <View style={styles.ImageContainer}>
      <TouchableOpacity
            onPress={() => {
              // OmniSegment SDK
              // Track event
              // https://github.com/beBit-tech/bebit-tech-react-native-app-sdk/wiki/Track-events
              const event = OSGEventBuilder.appUnsubscribe();
              event.location = 'app://Home';
              event.locationTitle = 'RN Test App @Home';
              OmniSegment.trackEvent(event);
              
            
              // OmniSegment SDK
              // When the user logs out
              // https://github.com/beBit-tech/bebit-tech-react-native-app-sdk/wiki/Usage
              setTimeout(() => {
                OmniSegment.logout();
              }, 1000);
            
              ToastAndroid.showWithGravity(
                "Logout Successful",
                ToastAndroid.SHORT,
                ToastAndroid.CENTER
              );
              navigation.navigate("Login");
            }}
          >
      <Image
        source={require('../assets/app_images/avatar.png')}
        style={styles.Image}
      />
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  ImageContainer: {
    height: SPACING.space_36,
    width: SPACING.space_36,
    borderRadius: SPACING.space_12,
    borderWidth: 2,
    borderColor: COLORS.secondaryDarkGreyHex,
    alignItems: 'center',
    justifyContent: 'center',
    overflow: 'hidden',
  },
  Image: {
    height: SPACING.space_36,
    width: SPACING.space_36,
  },
});

export default ProfilePic;
