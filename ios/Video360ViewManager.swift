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
    
    let View = VideoPlayerController()
    
    @objc var url: String = "" {
        didSet {
            initiatVideo(url: url)
        }
    }
    
    func initiatVideo(url: String){
        View.view.frame = self.frame
        self.addSubview(View.view)
    }
    
}
