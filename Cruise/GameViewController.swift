//
//  GameViewController.swift
//  Cruise
//
//  Created by Mark Anderson on 2/10/17.
//  Copyright © 2017 MartianRover. All rights reserved.
//

import UIKit
import SceneKit

enum ColliderType: Int {
    case geoid     = 0b0001
    case vehicle  = 0b0010
//    case third    = 0b0100
//    case fourth   = 0b1000
}

class GameViewController: UIViewController {
    
    var scnView: SCNView!
    var scnScene: SCNScene!
    var touchX: CGFloat = 0
    var game = GameHelper.sharedInstance
    var vehicleCameraNode: SCNNode!
    var lastContactNode: SCNNode!
    var geoidNode: SCNNode!
    var vehicleNode: SCNNode!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScene()
        setupCameras()
        setupNodes()
//        setupHUD()
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setupView() {
        scnView = self.view as! SCNView
        
        scnView.showsStatistics = true
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = true
        scnView.delegate = self
        scnView.isPlaying = true
    }
    
    func setupNodes() {
        geoidNode = scnScene.rootNode.childNode(withName: "Geoid", recursively: true)!
        vehicleNode = scnScene.rootNode.childNode(withName: "Vehicle", recursively: true)!
        
        geoidNode.physicsBody?.contactTestBitMask =
            ColliderType.vehicle.rawValue

        let xfm = SCNTransformConstraint(inWorldSpace: true) { (node, matrix) -> SCNMatrix4 in
            //
            let vPos = self.vehicleNode.presentation.position;
            let targetPos = SCNVector3Make(vPos.x + (vPos.x / fabs(vPos.x) * 3),
                                           vPos.y,
                                           vPos.z + (vPos.z / fabs(vPos.z) * 3));
            var cameraPos = node.position;
            let cameraDamping = Float(1.0);
            cameraPos = SCNVector3Make(cameraPos.x * Float(1.0 - cameraDamping) + targetPos.x * cameraDamping,
                                       cameraPos.y * Float(1.0 - cameraDamping) + targetPos.y * cameraDamping,
                                       cameraPos.z * Float(1.0 - cameraDamping) + targetPos.z * cameraDamping);

            return SCNMatrix4Translate(node.transform,
                                       cameraPos.x-node.position.x,
                                       cameraPos.y-node.position.y,
                                       cameraPos.z-node.position.z);
        }

        let look = SCNLookAtConstraint(target: geoidNode)
        look.isGimbalLockEnabled = true
        vehicleCameraNode.constraints = [xfm, look]

        
    }
    
    func setupScene() {
        scnScene = SCNScene(named: "Cruise.scnassets/Scenes/World1.scn")
        scnView.scene = scnScene
        scnScene.physicsWorld.contactDelegate = self
    }
    
    func setupCameras() {
        vehicleCameraNode = scnScene.rootNode.childNode(withName:
            "VehicleCamera", recursively: true)!
        
        scnView.pointOfView = vehicleCameraNode
    }
    
    func setupHUD() {
        game.hudNode.position = SCNVector3(x:0, y:-0.3, z:-9.9)
        scnScene.rootNode.addChildNode(game.hudNode)
    }
    
    func cleanScene() {
    }
    
    func handleTouchFor(node: SCNNode) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: scnView)
            touchX = location.x
//            paddleX = paddleNode.position.x
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch in touches {
//            let location = touch.location(in: scnView)
//            paddleNode.position.x = paddleX + (Float(location.x - touchX) * 0.1)
//        }
        
//        verticalCameraNode.position.x = paddleNode.position.x
//        horizontalCameraNode.position.x = paddleNode.position.x
    }
    
    func createTrail(color: UIColor, geometry: SCNGeometry) -> SCNParticleSystem {
        let trail = SCNParticleSystem(named: "Trail.scnp", inDirectory: nil)!
        trail.particleColor = color
        trail.emitterShape = geometry
        return trail
    }
    
    func createExplosion(geometry: SCNGeometry, position: SCNVector3, rotation: SCNVector4) {
        let explosion = SCNParticleSystem(named: "Explosion.scnp", inDirectory: nil)!
        explosion.emitterShape = geometry
        explosion.particleColor = geometry.materials.first?.diffuse.contents as! UIColor
        explosion.birthLocation = .surface
        
//        let translationMatrix = SCNMatrix4MakeTranslation(position.x, position.y, position.z + bricksNode.position.z)
//        scnScene.addParticleSystem(explosion, transform: translationMatrix)
    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator:
//        UIViewControllerTransitionCoordinator) {
//        let deviceOrientation = UIDevice.current.orientation
//        switch(deviceOrientation) {
//        case .portrait:
//            scnView.pointOfView = verticalCameraNode
//        default:
//            scnView.pointOfView = horizontalCameraNode
//        }
//    }
    
    
}

extension GameViewController: SCNSceneRendererDelegate {
//    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
//    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
    func renderer(_ : SCNSceneRenderer, updateAtTime time: TimeInterval ) {
    
//        let vPos = vehicleNode.presentation.position;
//        let targetPos = SCNVector3Make(vPos.x + (vPos.x / fabs(vPos.x) * 4),
//                                       vPos.y + (vPos.y / fabs(vPos.y) * 4),
//                                       vPos.z + (vPos.z / fabs(vPos.z) * 4));
//        var cameraPos = vehicleCameraNode.position;
//        let cameraDamping = Float(0.75);
//        cameraPos = SCNVector3Make(cameraPos.x * Float(1.0 - cameraDamping) + targetPos.x * cameraDamping,
//                                   cameraPos.y * Float(1.0 - cameraDamping) + targetPos.y * cameraDamping,
//                                   cameraPos.z * Float(1.0 - cameraDamping) + targetPos.z * cameraDamping);
//
//        vehicleCameraNode.position = cameraPos;
//        print(Int(cameraPos.x), Int(cameraPos.y), Int(cameraPos.z), "--",
//              Int(targetPos.x), Int(targetPos.y), Int(targetPos.z));
        
    }

}

extension GameViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        var contactNode: SCNNode!
        
        if contact.nodeA.name == "Geoid" {
            contactNode = contact.nodeB
        }
        else {
            contactNode = contact.nodeA
        }
        
        if lastContactNode != nil && lastContactNode == contactNode {
            return
        }
        
        lastContactNode = contactNode
        
    }
}
