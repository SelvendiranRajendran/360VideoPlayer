import * as React from 'react';

import { SafeAreaView, StyleSheet, View } from 'react-native';
import { Video360View } from 'react-native-video360';

export default function App() {
  return (
    <SafeAreaView style={styles.container}>
      <View style={{flex:1,overflow:'hidden'}}>
      <Video360View
        url={'https://firebasestorage.googleapis.com/v0/b/deft-station-368306.appspot.com/o/build%2Fjfk%20(3).mp4?alt=media&token=135ed790-b440-45ca-82ac-32b45564bd12'}
        style={styles.box}
      />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor:"red"
  },
  box: {
    height: 200,
    width: 200,
    // overflow:"hidden "
  },
});
