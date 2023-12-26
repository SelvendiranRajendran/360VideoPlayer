//
//  VideoPlayerController.swift
//  react-native-video360
//
//  Created by Selvendiran on 16/12/23.
//

import UIKit
import SceneKit
import CoreMotion
import SpriteKit
import AVFoundation
import Foundation
import Darwin
import CoreGraphics


public class VideoPlayerController :  UIViewController, SCNSceneRendererDelegate, UIGestureRecognizerDelegate  {
    
    @IBOutlet var slider: UISlider!
    @IBOutlet var rightSceneView: SCNView!
    @IBOutlet var mainView: UIView!
    
    var scenes: [SCNScene]!
    
    var videosNode: [SCNNode]!
    var videosSpriteKitNode: SKVideoNode!
    var camerasNode: [SCNNode]!
    var camerasRollNode: [SCNNode]!
    var camerasPitchNode: [SCNNode]!
    var camerasYawNode: [SCNNode]!
    var recognizer: UITapGestureRecognizer?
    var panRecognizer: UIPanGestureRecognizer?
    var motionManager: CMMotionManager?
    var player: AVPlayer!
    var currentAngleX: Float!
    var currentAngleY: Float!
    var oldY: Float!
    var oldX: Float!
    var progressObserver: AnyObject?
    var playingVideo: Bool = false
    var activateStereoscopicVideo: Bool = false
    var hiddenButton: Bool = false
    var cardboardViewOn: Bool = false
    var fileURL : NSURL!
    
#if arch(arm64)
    var PROCESSOR_64BITS: Bool = true
#else
    var PROCESSOR_64BITS: Bool = false
#endif

    override public func viewDidLoad() {
        super.viewDidLoad()
        if let view = Bundle.main.loadNibNamed("VideoView", owner: self, options: nil)?.first as? UIView {
            view.frame = self.view.frame
            self.view.addSubview(view)
            rightSceneView?.backgroundColor = UIColor.black
            rightSceneView.delegate = self
            
            let camX = 0.0 as Float
            let camY = 0.0 as Float
            let camZ = 0.0 as Float
            let zFar = 50.0
            let leftCamera = SCNCamera()
            let rightCamera = SCNCamera()
            
            leftCamera.zFar = zFar
            rightCamera.zFar = zFar
            
            let leftCameraNode = SCNNode()
            leftCameraNode.camera = leftCamera
            
            let rightCameraNode = SCNNode()
            rightCameraNode.camera = rightCamera
            
            let scene1 = SCNScene()
            
            let cameraNodeLeft = SCNNode()
            let cameraRollNodeLeft = SCNNode()
            let cameraPitchNodeLeft = SCNNode()
            let cameraYawNodeLeft = SCNNode()
            
            cameraNodeLeft.addChildNode(leftCameraNode)
            cameraNodeLeft.addChildNode(rightCameraNode)
            cameraRollNodeLeft.addChildNode(cameraNodeLeft)
            cameraPitchNodeLeft.addChildNode(cameraRollNodeLeft)
            cameraYawNodeLeft.addChildNode(cameraPitchNodeLeft)
            
            scenes = [scene1]
            camerasNode = [cameraNodeLeft]
            camerasRollNode = [cameraRollNodeLeft]
            camerasPitchNode = [cameraPitchNodeLeft]
            camerasYawNode = [cameraYawNodeLeft]
            rightSceneView?.scene = scene1
            
            leftCameraNode.position = SCNVector3(x: camX - ((true == activateStereoscopicVideo) ? 0.0 : 0.5), y: camY, z: camZ)
            rightCameraNode.position = SCNVector3(x: camX + ((true == activateStereoscopicVideo) ? 0.0 : 0.5), y: camY, z: camZ)
            
            let camerasNodeAngles = getCamerasNodeAngle()
            
            for cameraNode in camerasNode {
                cameraNode.position = SCNVector3(x: camX, y:camY, z:camZ)
                cameraNode.eulerAngles = SCNVector3Make(Float(camerasNodeAngles[0]), Float(camerasNodeAngles[1]), Float(camerasNodeAngles[2]))
            }
            
            if scenes.count == camerasYawNode.count {
                for i in 0 ..< scenes.count {
                    let scene                           = scenes[i]
                    let cameraYawNode                   = camerasYawNode[i]
                    
                    scene.rootNode.addChildNode(cameraYawNode)
                }
            }
            
            rightSceneView?.pointOfView = rightCameraNode
            
            rightSceneView?.isPlaying = true
            
            // Respond to user head movement. Refreshes the position of the camera 60 times per second.
            motionManager = CMMotionManager()
            motionManager?.deviceMotionUpdateInterval   = 1.0 / 60.0
            motionManager?.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xArbitraryZVertical)
            
            // Add gestures on screen
            recognizer = UITapGestureRecognizer(target: self, action:#selector(VideoPlayerController.tapTheScreen))
            recognizer!.delegate                        = self
            view.addGestureRecognizer(recognizer!)
            
            panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(VideoPlayerController.panGesture(_:)))
            panRecognizer?.delegate                     = self
            view.addGestureRecognizer(panRecognizer!)
            
            //Initialize position variable (for the panGesture)
            currentAngleX                               = 0
            currentAngleY                               = 0
            
            oldX                                        = 0
            oldY                                        = 0
            
            //Launch the player
            play()
            
        }
        
    }
    
    //MARK: Camera Orientation
    public override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
            let camerasNodeAngles                       = getCamerasNodeAngle()
            
            for cameraNode in camerasNode {
                cameraNode.eulerAngles                  = SCNVector3Make(Float(camerasNodeAngles[0]), Float(camerasNodeAngles[1]), Float(camerasNodeAngles[2]))
            }
        }
        
        func getCamerasNodeAngle() -> [Double] {
            
            var camerasNodeAngle1: Double!              = 0.0
            var camerasNodeAngle2: Double!              = 0.0
            
            let orientation = UIApplication.shared.statusBarOrientation.rawValue
            
            if orientation == 1 {
                camerasNodeAngle1                       = -M_PI_2
            } else if orientation == 2 {
                camerasNodeAngle1                       = M_PI_2
            } else if orientation == 3 {
                camerasNodeAngle1                       = 0.0
                camerasNodeAngle2                       = M_PI
            }
            
            return [ -M_PI_2, camerasNodeAngle1, camerasNodeAngle2]
        
        }
        
    public func setUrl(url:NSURL){
        fileURL = url
    }
    //MARK: Video Player
        func play(){
            if (fileURL != nil){
                
                var screenScale : CGFloat                                       = 1.0
                if PROCESSOR_64BITS {
                    screenScale                                                 = CGFloat(3.0)
                }
                
                player                                                          = AVPlayer(url: fileURL! as URL)
                slider.minimumValue = 0
                slider.maximumValue = Float(CMTimeGetSeconds(player?.currentItem?.asset.duration ?? CMTime(seconds: 1, preferredTimescale: 1)))
                slider.value = 0
                slider.addTarget(self, action: #selector(seekBarValueChanged), for: .valueChanged)
                addTimeObserver()
                let videoSpriteKitNodeLeft                                      = SKVideoNode(avPlayer: player)
                let videoNodeLeft                                               = SCNNode()
                let spriteKitScene1                                             = SKScene(size: CGSize(width: 1280 * screenScale, height: 1280 * screenScale))
                spriteKitScene1.shouldRasterize                                 = true
                var spriteKitScenes                                             = [spriteKitScene1]
                
                videoNodeLeft.geometry                                          = SCNSphere(radius: 30)
                spriteKitScene1.scaleMode                                       = .aspectFit
                videoSpriteKitNodeLeft.position                                 = CGPoint(x: spriteKitScene1.size.width / 2.0, y: spriteKitScene1.size.height / 2.0)
                videoSpriteKitNodeLeft.size                                     = spriteKitScene1.size
                
                    videosSpriteKitNode                                         = videoSpriteKitNodeLeft
                    videosNode                                                  = [videoNodeLeft]
                    
                    spriteKitScene1.addChild(videoSpriteKitNodeLeft)
                
                if videosNode.count == spriteKitScenes.count && scenes.count == videosNode.count {
                    for i in 0 ..< videosNode.count {
                        weak var spriteKitScene                                         = spriteKitScenes[i]
                        let videoNode                                                   = videosNode[i]
                        let scene                                                       = scenes[i]
                        
                        videoNode.geometry?.firstMaterial?.diffuse.contents             = spriteKitScene
                        videoNode.geometry?.firstMaterial?.isDoubleSided                  = true
                        
                        // Flip video upside down, so that it's shown in the right position
                        var transform                                                   = SCNMatrix4MakeRotation(Float(M_PI), 0.0, 0.0, 1.0)
                        transform                                                       = SCNMatrix4Translate(transform, 1.0, 1.0, 0.0)
                        
                        videoNode.pivot                                                 = SCNMatrix4MakeRotation(Float(M_PI_2), 0.0, -1.0, 0.0)
                        videoNode.geometry?.firstMaterial?.diffuse.contentsTransform    = transform
                        
                        videoNode.position                                              = SCNVector3(x: 0, y: 0, z: 0)
                        videoNode.position                                              = SCNVector3(x: 0, y: 0, z: 0)
                        
                        scene.rootNode.addChildNode(videoNode)
                    }
                }
                
                playPausePlayer(play: false)
            }
        }
    @objc func seekBarValueChanged() {
        let time = CMTime(seconds: Double(slider.value), preferredTimescale: 1)
        player.seek(to: time)
    }
    func addTimeObserver() {
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: DispatchQueue.main) { [weak self] time in
            guard let self = self else { return }
            let currentTime = CMTimeGetSeconds(time)
            self.slider.value = Float(currentTime)
        }
    }
    public func playPausePlayer(play : Bool){
            if true == playingVideo {
                videosSpriteKitNode.pause()
            } else {
                videosSpriteKitNode.play()
            }
        
        playingVideo = !playingVideo
    }
        
    //MARK: Touch Methods
        @objc func tapTheScreen(){
            
            hiddenButton                                                        = !hiddenButton
        }
        
        @objc func panGesture(_ sender: UIPanGestureRecognizer){
            
            let translation                                                     = sender.translation(in: sender.view!)
            let protection : Float                                              = 2.0
            
            if (abs(Float(translation.x) - oldX) >= protection){
                let newAngleX                                                   = Float(translation.x) - oldX - protection
                currentAngleX                                                   = newAngleX/100 + currentAngleX
                oldX                                                            = Float(translation.x)
            }
            
            if (abs(Float(translation.y) - oldY) >= protection){
                let newAngleY                                                   = Float(translation.y) - oldY - protection
                currentAngleY                                                   = newAngleY/100 + currentAngleY
                oldY                                                            = Float(translation.y)
            }
            
            if(sender.state == UIGestureRecognizer.State.ended) {
                oldX                                                            = 0
                oldY                                                            = 0
            }
        }
        
        
    //MARK: Render the scene
    public func renderer(_ aRenderer: SCNSceneRenderer, updateAtTime time: TimeInterval){
            
            // Render the scene
            DispatchQueue.main.async { [weak self] () -> Void in
                if let strongSelf = self {
                    if let mm = strongSelf.motionManager, let motion = mm.deviceMotion {
                        let currentAttitude                                     = motion.attitude
                        
                        var roll : Double                                       = currentAttitude.roll
                        
                        if(UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeRight) {
                            roll                                                = -1.0 * (-M_PI - roll)
                        }
                        
                        for cameraRollNode in strongSelf.camerasRollNode {
                            cameraRollNode.eulerAngles.x                        = Float(roll) - strongSelf.currentAngleY
                        }
                        
                        for cameraPitchNode in strongSelf.camerasPitchNode {
                            cameraPitchNode.eulerAngles.z                       = Float(currentAttitude.pitch)
                        }
                        
                        for cameraYawNode in strongSelf.camerasYawNode {
                            cameraYawNode.eulerAngles.y                         = Float(currentAttitude.yaw) + strongSelf.currentAngleX
                        }
                    }
                }
            }
        }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    //MARK: Clean perf
    deinit {
        
        motionManager?.stopDeviceMotionUpdates()
        motionManager = nil
        
        if let observer = progressObserver {
            player.removeTimeObserver(observer)
        }
        
        playingVideo = false
        
        videosSpriteKitNode.removeFromParent()
        
        for scene in scenes {
            for node in scene.rootNode.childNodes {
                removeNode(node)
            }
        }
    }
        
    func removeNode(_ node : SCNNode) {
        
        for node in node.childNodes {
            removeNode(node)
        }
        
        if 0 == node.childNodes.count {
            node.removeFromParentNode()
        }
        
    }
        
    public override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}
