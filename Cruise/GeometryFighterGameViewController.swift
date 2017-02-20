//
//  GameViewController.swift
//  Cruise
//
//  Created by Mark Anderson on 2/10/17.
//  Copyright © 2017 MartianRover. All rights reserved.
//

import UIKit
import SceneKit

class GeometryFighterGameViewController: UIViewController {
    
    var scnView: SCNView!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    var spawnTime: TimeInterval = 0
    var game = GameHelper.sharedInstance
    var sounds:[String:SCNAudioSource] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScene()
        setupCamera()
        spawnShape()
        setupHUD()
        
        game.loadSound(name: "test", fileNamed: "Cruise.scnassets/Sounds/test")
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
    
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        scnScene.background.contents = "Cruise.scnassets/Textures/Background_Diffuse.png"
    }
    
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 10)
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    func spawnShape() {
        var geometry = SCNGeometry()
        
        switch ShapeType.random() {
        default:
            geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0,
                              chamferRadius: 0.0)
        }
        
        let color = UIColor.random()
        geometry.materials.first?.diffuse.contents = color
        
        
        let geometryNode = SCNNode(geometry: geometry)
        
        let trailEmitter = createTrail(color: color, geometry: geometry)
        geometryNode.addParticleSystem(trailEmitter)
        
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        scnScene.rootNode.addChildNode(geometryNode)
        
        let randomX = Float.random(min: -2, max: 2)
        let randomY = Float.random(min: 10, max: 18)
        geometryNode.physicsBody?.applyForce(SCNVector3(x:randomX, y:randomY, z:randomX), at: SCNVector3(x:0.025, y:0.015, z:0.075), asImpulse: true)
    }
    
    func setupHUD() {
        game.hudNode.position = SCNVector3(x: 0, y: 10, z: 0)
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
        game.playSound(node:node, name: "test")
        game.score += 1
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: scnView)
        let hitResult = scnView.hitTest(location, options: nil)
        if let result = hitResult.first {
            handleTouchFor(node: result.node)
        }
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
        
        let rotationMatrix = SCNMatrix4MakeRotation(rotation.w, rotation.x, rotation.y, rotation.z)
        let translationMatrix = SCNMatrix4MakeTranslation(position.x, position.y, position.z)
        let transformMatrix = SCNMatrix4Mult(rotationMatrix, translationMatrix)
        scnScene.addParticleSystem(explosion, transform: transformMatrix)
    }
    
}

extension GeometryFighterGameViewController: SCNSceneRendererDelegate {
    func renderer(_ : SCNSceneRenderer, updateAtTime time: TimeInterval ) {
        if (time > spawnTime) {
            spawnShape()
            spawnTime = time + TimeInterval(Float.random(min: 1.0, max: 1.5))
        }
        
        cleanScene()
        game.updateHUD()
    }
}
