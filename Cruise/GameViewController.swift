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
    case ball     = 0b0001
    case barrier  = 0b0010
    case brick    = 0b0100
    case paddle   = 0b1000
}

class GameViewController: UIViewController {
    
    var scnView: SCNView!
    var scnScene: SCNScene!
    var horizontalCameraNode: SCNNode!
    var verticalCameraNode: SCNNode!
    var paddleNode: SCNNode!
    var spawnTime: TimeInterval = 0
    var lastContactNode: SCNNode!
    var game = GameHelper.sharedInstance
    var sounds:[String:SCNAudioSource] = [:]
    var ballNode: SCNNode!
    var touchX: CGFloat = 0
    var paddleX: Float = 0
    var floorNode: SCNNode!
    var bricksNode: SCNNode!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScene()
        setupCameras()
        setupNodes()
        setupHUD()
        setupSounds()
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
        ballNode = scnScene.rootNode.childNode(withName: "Ball", recursively: true)!
        bricksNode = scnScene.rootNode.childNode(withName: "Bricks", recursively: true)!
        paddleNode = scnScene.rootNode.childNode(withName: "Paddle", recursively: true)!
        
        ballNode.physicsBody?.contactTestBitMask =
            ColliderType.barrier.rawValue |
            ColliderType.brick.rawValue |
            ColliderType.paddle.rawValue
        
        floorNode = scnScene.rootNode.childNode(withName: "Floor", recursively: true)!

        verticalCameraNode.constraints =
            [SCNLookAtConstraint(target: floorNode)]
        horizontalCameraNode.constraints =
            [SCNLookAtConstraint(target: floorNode)]
    }
    
    func setupScene() {
        scnScene = SCNScene(named: "Cruise.scnassets/Scenes/Breakout.scn")
        scnView.scene = scnScene
        scnScene.background.contents = "Cruise.scnassets/Textures/Background_Diffuse.png"
        
        scnScene.physicsWorld.contactDelegate = self
    }
    
    func setupCameras() {
        horizontalCameraNode = scnScene.rootNode.childNode(withName:
            "HorizontalCamera", recursively: true)!
        verticalCameraNode = scnScene.rootNode.childNode(withName:
            "VerticalCamera", recursively: true)!
    }
    
    func setupSounds() {
        game.loadSound(name: "Paddle",
                       fileNamed: "Cruise.scnassets/Sounds/Paddle.wav")
        game.loadSound(name: "Block0",
                       fileNamed: "Cruise.scnassets/Sounds/Block0.wav")
        game.loadSound(name: "Block1",
                       fileNamed: "Cruise.scnassets/Sounds/Block1.wav")
        game.loadSound(name: "Block2",
                       fileNamed: "Cruise.scnassets/Sounds/Block2.wav")
        game.loadSound(name: "Barrier",
                       fileNamed: "Cruise.scnassets/Sounds/Barrier.wav")
    }
    
    func setupHUD() {
        game.hudNode.position = SCNVector3(x:0, y:-0.3, z:-9.9)
        scnScene.rootNode.addChildNode(game.hudNode)
    }
    
    func cleanScene() {
        for node in scnScene.rootNode.childNodes {
            if node.presentation.position.y < -2 {
                node.removeFromParentNode()
            }
        }
    }
    
    func handleTouchFor(node: SCNNode) {
        node.removeFromParentNode()
        createExplosion(geometry: node.geometry!, position: node.presentation.position, rotation: node.presentation.rotation)
        game.score += 1
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: scnView)
            touchX = location.x
            paddleX = paddleNode.position.x
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: scnView)
            paddleNode.position.x = paddleX + (Float(location.x - touchX) * 0.1)
            
            if paddleNode.position.x > 4.25 {
                paddleNode.position.x = 4.25
            }
            else if paddleNode.position.x < -4.25 {
                paddleNode.position.x = -4.25
            }
        }
        
        verticalCameraNode.position.x = paddleNode.position.x
        horizontalCameraNode.position.x = paddleNode.position.x
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
        
//        let rotationMatrix = SCNMatrix4MakeRotation(rotation.w, rotation.x, rotation.y, rotation.z)
        let translationMatrix = SCNMatrix4MakeTranslation(position.x, position.y, position.z + bricksNode.position.z)
//        let transformMatrix = SCNMatrix4Mult(rotationMatrix, translationMatrix)
        scnScene.addParticleSystem(explosion, transform: translationMatrix)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator:
        UIViewControllerTransitionCoordinator) {
        let deviceOrientation = UIDevice.current.orientation
        switch(deviceOrientation) {
        case .portrait:
            scnView.pointOfView = verticalCameraNode
        default:
            scnView.pointOfView = horizontalCameraNode
        }
    }
    
    
}

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ : SCNSceneRenderer, updateAtTime time: TimeInterval ) {
        if (time > spawnTime) {
            spawnTime = time + TimeInterval(Float.random(min: 1.0, max: 1.5))
        }
        
        cleanScene()
        game.updateHUD()
    }
}

extension GameViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        var contactNode: SCNNode!
        
        if contact.nodeA.name == "Ball" {
            contactNode = contact.nodeB
        }
        else {
            contactNode = contact.nodeA
        }
        
        if lastContactNode != nil && lastContactNode == contactNode {
            return
        }
        
        lastContactNode = contactNode
        
        if contactNode.physicsBody?.categoryBitMask ==
            ColliderType.barrier.rawValue {
            
            game.playSound(node: scnScene.rootNode, name: "Barrier")

            if contactNode.name == "Bottom" {
                game.lives -= 1
                if game.lives == 0 {
                    game.saveState()
                    game.reset()
                }
            }
            else {
                if (ballNode.physicsBody!.velocity.xzAngle > -5) {
                    ballNode.physicsBody!.velocity.xzAngle +=
                        (convertToRadians(angle: Float.random(min: 0, max: 20)))
                }

            }
        }

        if contactNode.physicsBody?.categoryBitMask ==
            ColliderType.brick.rawValue {
            
            game.playSound(node: scnScene.rootNode, name: "Block\(Int.random(min: 0, max: 2))")
            
            createExplosion(geometry: contactNode.geometry!, position: contactNode.position, rotation: contactNode.rotation)

            game.score += 1
            contactNode.isHidden = true
            contactNode.runAction(
                SCNAction.waitForDurationThenRunBlock(duration: 60) {
                    (node:SCNNode!) -> Void in
                    node.isHidden = false
            })
        }

        if contactNode.physicsBody?.categoryBitMask ==
            ColliderType.paddle.rawValue {

            game.playSound(node: scnScene.rootNode, name: "Paddle")

            if contactNode.name == "Left" {
                ballNode.physicsBody!.velocity.xzAngle -=
                    (convertToRadians(angle: Float.random(min: 15, max: 25)))
            }
            if contactNode.name == "Right" {
                ballNode.physicsBody!.velocity.xzAngle +=
                    (convertToRadians(angle: Float.random(min: 15, max: 25)))
            }
        }

        ballNode.physicsBody?.velocity.length = 2.5
    }
}
