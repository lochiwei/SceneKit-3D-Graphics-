//
//  ViewController.swift
//  SceneKit (3D Graphics)
//
//  Created by pegasus on 2018/07/24.
//  Copyright © 2018年 Lo Chiwei. All rights reserved.
//

import SceneKit

class ViewController: UIViewController {
    
    private var scene: SCNScene!
    
    // MARK: - Outlets

    @IBOutlet weak var sceneView: SCNView!
    
    // MARK: - Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
    }
    
    func setupScene() {
        scene = MyScene()
        sceneView.scene = scene
        sceneView.backgroundColor = .black
        sceneView.allowsCameraControl = true
        sceneView.showsStatistics = true
    }
    
    // MARK: - Controller Settings
    
    override var shouldAutorotate: Bool { return true }
    override var prefersStatusBarHidden: Bool { return false }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.current.userInterfaceIdiom == .phone ? .allButUpsideDown : .all
    }

}

