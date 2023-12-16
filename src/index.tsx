import {
  requireNativeComponent,
  UIManager,
  Platform,
  ViewStyle,
} from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-video360' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

type Video360Props = {
  url: string;
  style: ViewStyle;
};

const ComponentName = 'Video360View';

export const Video360View =
  UIManager.getViewManagerConfig(ComponentName) != null
    ? requireNativeComponent<Video360Props>(ComponentName)
    : () => {
        throw new Error(LINKING_ERROR);
      };
