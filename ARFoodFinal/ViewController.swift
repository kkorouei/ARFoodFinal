//
//  ViewController.swift
//  ARFoodFinal
//
//  Created by Koushan Korouei on 13/10/2018.
//  Copyright © 2018 Koushan Korouei. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a new scene
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        // Gestures
        let tapGesure = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tapGesure)
        
        addLight()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    func addFoodModelTo(position: SCNVector3) {
        guard let fruitCakeScene = SCNScene(named: "art.scnassets/FruitCake/FruitCake.dae") else {
            fatalError("Unable to find FruitCake.dae")
        }
        guard let baseNode = fruitCakeScene.rootNode.childNode(withName: "baseNode", recursively: true) else {
            fatalError("Unable to find baseNode")
        }
        baseNode.position = position
        baseNode.scale = SCNVector3Make(0.005, 0.005, 0.005)
        let cakeNode = baseNode.childNode(withName: "cake", recursively: true)
        let cakeMaterial = SCNMaterial()
        // The lightingModel of the material has to be set to .physicallyBased to take advantage of the environment lighting
        cakeMaterial.lightingModel = .physicallyBased
        cakeMaterial.diffuse.contents = UIImage(named: "art.scnassets/FruitCake/CL_LR_01DiffuseMap.jpg")
        cakeMaterial.normal.contents = UIImage(named: "art.scnassets/FruitCake/CL_LR_01NormalsMap.jpg")
        cakeMaterial.normal.intensity = 0.5
        cakeNode?.geometry?.firstMaterial = cakeMaterial
        
        let plateNode = baseNode.childNode(withName: "plate", recursively: true)
        let plateMaterial = SCNMaterial()
        plateMaterial.lightingModel = .physicallyBased
        plateMaterial.diffuse.contents = UIImage(named: "art.scnassets/FruitCake/Piatto_B1.jpg")
        plateMaterial.metalness.contents = 0.8
        plateMaterial.roughness.contents = 0.2
        plateNode?.geometry?.firstMaterial = plateMaterial
        sceneView.scene.rootNode.addChildNode(baseNode)
        
        addPlaneTo(node: baseNode)
    }
    
    func addPlaneTo(node:SCNNode) {
        // Create a plane that only receives shadows
        let plane = SCNPlane(width: 200, height: 200)
        plane.firstMaterial?.colorBufferWriteMask = .init(rawValue: 0)
        let planeNode = SCNNode(geometry: plane)
        planeNode.rotation = SCNVector4Make(1, 0, 0, -Float.pi / 2)
        node.addChildNode(planeNode)
    }
    
    func addLight() {
        let directionalLight = SCNLight()
        directionalLight.type = .directional
        directionalLight.intensity = 0
        directionalLight.castsShadow = true
        directionalLight.shadowMode = .deferred
        directionalLight.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        directionalLight.shadowSampleCount = 10
        
        let directionalLightNode = SCNNode()
        directionalLightNode.light = directionalLight
        directionalLightNode.rotation = SCNVector4Make(1, 0, 0, -Float.pi / 3)
        sceneView.scene.rootNode.addChildNode(directionalLightNode)
    }
    
    // MARK: - Gesture Recognizers
    @objc func handleTap(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: sceneView)
        guard let hitTestResult = sceneView.hitTest(location, types: .existingPlane).first else { return }
        let position = SCNVector3Make(hitTestResult.worldTransform.columns.3.x,
                                      hitTestResult.worldTransform.columns.3.y,
                                      hitTestResult.worldTransform.columns.3.z)
        addFoodModelTo(position: position)
    }
}
