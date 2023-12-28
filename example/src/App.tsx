import * as React from 'react';

import { StyleSheet } from 'react-native';
import { Video360View } from 'react-native-video360';

export default function App() {
  return (
      <Video360View
      url={'https://firebasestorage.googleapis.com/v0/b/deft-station-368306.appspot.com/o/build%2Fjfk%20(3).mp4?alt=media&token=135ed790-b440-45ca-82ac-32b45564bd12'}
      // onLoadStart={() => { }}
      // onLoadEnd={() => { }}
      // play={true}
      // mute={true}
      // showControls={false}
      // seek={20}
      // onEnd={() => { }}
      // onPause = {()=>{}}
      // onError = {()=>{}}
      style={styles.box}
      />
  );
}

const styles = StyleSheet.create({

  box: {
    flex:1
  },
});
