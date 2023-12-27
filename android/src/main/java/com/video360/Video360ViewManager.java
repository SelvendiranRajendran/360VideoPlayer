package com.video360;

import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.media3.common.MediaItem;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.ui.PlayerView;

import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;


public class Video360ViewManager extends SimpleViewManager<VideoView> {
  public static final String REACT_CLASS = "Video360View";
  private ThemedReactContext context;
  PlayerView playerView;

  @Override
  @NonNull
  public String getName() {
    return REACT_CLASS;
  }

  @Override
  @NonNull
  public VideoView createViewInstance(ThemedReactContext reactContext) {
    context = reactContext;
    return new VideoView(reactContext);
  }

  @ReactProp(name = "color")
  public void setColor(View view, String color) {
//    view.setBackgroundColor(Color.parseColor(color));
  }

  @ReactProp(name = "url")
  public void playVideo(View view, String url) {
    Log.d("url", url);
    ExoPlayer player = new ExoPlayer.Builder(context).build();
    playerView = view.findViewById(R.id.playerView);
    playerView.setPlayer(player);
    MediaItem mediaItem = MediaItem.fromUri(url);
    player.setMediaItem(mediaItem);
    player.prepare();
    player.play();
    playerView.onResume();
  }
}




