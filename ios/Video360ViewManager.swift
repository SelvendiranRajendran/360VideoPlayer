import AVFoundation

@objc(Video360ViewManager)
class Video360ViewManager: RCTViewManager {

  override func view() -> (Video360View) {
    return Video360View()
  }

  @objc override static func requiresMainQueueSetup() -> Bool {
    return false
  }
}

class Video360View : UIView {
    
    var View : VideoPlayerController!
    
    @objc var url: String = "" {
        didSet {
            View = VideoPlayerController()
            View.setUrl(url: URL(string: url)! as NSURL)
            initiatVideo(url: url)
        }
    }
    @objc var play: Bool = false {
        didSet {
            View.playPausePlayer(play: play)
        }
    }
    
    func initiatVideo(url: String){
        self.addSubview(View.view)
    }
    
    override func layoutSubviews() {
        View?.view.frame = self.frame
    }
    
}
