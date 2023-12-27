package com.video360;

import android.content.Context;
import android.view.LayoutInflater;
import android.widget.LinearLayout;

public class VideoView extends LinearLayout {
  public VideoView(Context context) {
    super(context);
    LayoutInflater.from(context).inflate(R.layout.activityvideoview, this, true);
  }
}
