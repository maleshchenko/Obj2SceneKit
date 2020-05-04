//
//  SceneViewController.swift
//  Obj2SceneKit
//
//  Created by Mykola Aleshchenko on 5/3/20.
//  Copyright © 2020 Mykola Aleshchenko. All rights reserved.
//

import UIKit
import SceneKit

final class SceneViewController: UIViewController {

    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var progressView: UIProgressView!

    private let scene = SCNScene()
    private let mainNode = SCNNode()

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }

    // MARK: - Initial Scene setup

    private func loadData() {
        if let path = Bundle.main.path(forResource: SceneConfiguration.fileName, ofType: "obj") {
            progressView.setProgress(0, animated: false)

            DispatchQueue.global().async(execute: {
                let sceneGeometry = FileParser(path: path, delegate: self).loadScene()
                DispatchQueue.main.async(execute: {
                    self.setupScene(geometry: sceneGeometry)
                    self.progressView.isHidden = true
                })
            })
        }
    }

    private func setupScene(geometry: SCNGeometry) {
        mainNode.geometry = geometry
        geometry.materials = [MainNodeMaterial(mainColor: SceneConfiguration.mainColor)]

        scene.rootNode.addChildNode(self.mainNode)
        sceneView.scene = self.scene

        customizeScene()
    }

    // MARK: - Miscellaneous scene properties

    private func customizeScene() {
        setupSpotlight()
        setupCamera()
        setupFloor()
        setupSky()
        setupAnimations()
    }

    private func setupSpotlight() {
        let spotlightNodeSpot = SCNNode()
        spotlightNodeSpot.light = SCNLight()
        spotlightNodeSpot.light!.type = SCNLight.LightType.spot
        spotlightNodeSpot.light!.attenuationStartDistance = 40
        spotlightNodeSpot.light!.attenuationFalloffExponent = 2
        spotlightNodeSpot.light!.attenuationEndDistance = 50
        spotlightNodeSpot.position = SCNVector3(0, 20, 15)
        spotlightNodeSpot.rotation = SCNVector4(10, 0, 0, Float(-.pi / 5.0))
        scene.rootNode.addChildNode(spotlightNodeSpot)
    }

    private func setupCamera() {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 8, 15)
        cameraNode.rotation = SCNVector4(10, 0, 0, Float(-.pi / 8.0))
        scene.rootNode.addChildNode(cameraNode)
    }

    private func setupFloor() {
        let floor = SCNFloor()
        floor.materials = [FloorMaterial()]
        floor.reflectivity = 0.75
        floor.reflectionResolutionScaleFactor = 1
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(0, -1, 0)
        scene.rootNode.addChildNode(floorNode)
    }

    private func setupSky() {
        let sky = MDLSkyCubeTexture(name: nil,
                                    channelEncoding: MDLTextureChannelEncoding.uInt8,
                                    textureDimensions: [Int32(10), Int32(10)],
                                    turbidity: 0.5,
                                    sunElevation: 0.3,
                                    upperAtmosphereScattering: 0.5,
                                    groundAlbedo: 0.2)
        scene.background.contents = sky.imageFromTexture()?.takeUnretainedValue()
    }

    private func setupAnimations() {
        // Fade in while moving closer, then start rotating
        mainNode.position = SCNVector3(x: 0, y: 0, z: -100)
        mainNode.opacity = 0.0

        let fadeInDuration = SceneConfiguration.fadeInDuration

        let fadeInAction = SCNAction.fadeOpacity(by: 1.0, duration: fadeInDuration)
        mainNode.runAction(fadeInAction)

        let moveCloserAction = SCNAction.move(to: SCNVector3Make(0, 0, -5), duration: fadeInDuration)
        let rotateAction = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 10.0))

        let sequence = SCNAction.sequence([moveCloserAction, rotateAction])
        mainNode.runAction(sequence)
    }
}

// MARK: - FileParserDelegate

extension SceneViewController: FileParserDelegate {
    func didReachProgress(_ progress: Float) {
        DispatchQueue.main.async(execute: {
            self.progressView.setProgress(progress, animated: false)
        })
    }
}
