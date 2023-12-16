import * as React from 'react';

import { SafeAreaView, StyleSheet, View } from 'react-native';
import { Video360View } from 'react-native-video360';

export default function App() {
  return (
    <SafeAreaView style={styles.container}>
      <View style={{flex:1,overflow:'hidden'}}>
      <Video360View
        url={'https://www.pexels.com/download/video/3209828'}
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
    flex:1
  },
});
