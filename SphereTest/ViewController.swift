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

class ViewController: UIViewController {

    @IBOutlet weak var scnView: SCNView!
    let cameraNode = SCNNode()
    let motionManager = CMMotionManager()
    override func viewDidLoad() {
        super.viewDidLoad()

        
        scnView.showsStatistics = true
        //可以旋转模型
        //scnView.allowsCameraControl = true
        let scene = SCNScene()
        scnView.scene = scene
   
        cameraNode.position = SCNVector3(0, 0, 0)
        cameraNode.camera = SCNCamera()
        
       
        
        let sphere = SCNSphere(radius: 50)
        
        sphere.firstMaterial?.cullMode = .front
        sphere.firstMaterial?.isDoubleSided = false
        
//        let url = Bundle.main.url(forResource: "img", withExtension: "jpg")
//        sphere.firstMaterial?.diffuse.contents = url
        sphere.firstMaterial?.diffuse.contents = play()
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3(0, 0, 0)
    
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(sphereNode)
        //scnView.play(self)
        guard motionManager.isDeviceMotionAvailable else {
            fatalError("Device motion is not available")
        }
        addMotion()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.scnView.play(self)
    }
    func play() -> SKScene{
        guard let url = Bundle.main.url(forResource: "b", withExtension: "mp4") else{
            fatalError()
        }
        let player = AVPlayer(url: url)
        let videoNode = SKVideoNode(avPlayer: player)
        videoNode.size = CGSize(width: 2000, height: 1000)
        //videoNode.size = CGSize(width:view.frame.width, height:view.frame.height)
        videoNode.position = CGPoint(x: videoNode.size.width/2, y: videoNode.size.height/2)
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

