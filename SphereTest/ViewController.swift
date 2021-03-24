//
//  ViewController.swift
//  SphereTest
//
//  Created by cho Sigyo on 2021/03/05.
//

import UIKit
import SceneKit
import SpriteKit
import AVFoundation
import CoreMotion
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var scnView: SCNView!
    let scene = SCNScene()
    let cameraNode = SCNNode()
    let sphere = SCNSphere(radius: 20)
    let motionManager = CMMotionManager()
    var onlineUrl:String?
    let application = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scnView.scene = scene
        cameraNode.position = SCNVector3(0, 0, 0)
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        materialToSCN()
        
        //scnView.play(self)
        guard motionManager.isDeviceMotionAvailable else {
            fatalError("Device motion is not available")
        }
        addMotion()
        scnView.play(self)
        NotificationCenter.default.addObserver(self, selector: #selector(playisFinished(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        application.rotation = true
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        
    }
    @objc func playisFinished(notification:Notification){
        //放个监视器，一播完，就重播
        materialToSCN()
    }
    func materialToSCN(){
        //scnView.showsStatistics = true
        //可以旋转模型
        //scnView.allowsCameraControl = true
        
        sphere.firstMaterial?.cullMode = .front
        sphere.firstMaterial?.isDoubleSided = false
//        let url = Bundle.main.url(forResource: "img", withExtension: "jpg")
//        sphere.firstMaterial?.diffuse.contents = url
        sphere.firstMaterial?.diffuse.contents = play()
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3(0, 0, 0)
        //球体沿y轴旋转180度，显示视频正确前后
        sphereNode.rotation = SCNVector4Make(0, 1, 0, Float.pi)
        //球体沿x轴旋转180度，显示视频正确上下
        //sphereNode.rotation = SCNVector4Make(1, 0, 0, Float.pi)
        
        scene.rootNode.addChildNode(sphereNode)
    }
    func play() -> SKScene{
//        guard let url = Bundle.main.url(forResource: "aT", withExtension: "mp4") else{
//            fatalError()
//        }
        guard let url = URL(string: onlineUrl!) else{
            fatalError()
        }
        let item = AVPlayerItem(url: url)
        //let player = AVPlayer(url: url)
        let player = AVPlayer()
        player.replaceCurrentItem(with: item)
        player.actionAtItemEnd = .none
        
        let videoNode = SKVideoNode(avPlayer: player)
        videoNode.size = CGSize(width: 2000, height: 1000)
        //videoNode.size = CGSize(width:view.frame.width, height:view.frame.height)
        videoNode.position = CGPoint(x: videoNode.size.width/2, y: videoNode.size.height/2)
        //把视频位置上下颠倒，才能显示上下正确的
        videoNode.zRotation = CGFloat(Double.pi)
        videoNode.play()
        let skScene = SKScene(size: videoNode.size)
        skScene.addChild(videoNode)
        return skScene
    }
    //调用coremotion
    func addMotion(){
        motionManager.deviceMotionUpdateInterval = 1.0/60.0
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) {
            [weak self](data: CMDeviceMotion?, error: Error?) in
            guard let data = data else { return }
            let attitude: CMAttitude = data.attitude
            self?.cameraNode.eulerAngles = SCNVector3Make(-Float(attitude.roll + Double.pi/2), Float(attitude.yaw), -Float(attitude.pitch))
        }
    }

}

