//
//  GameViewController.swift
//  ARMagic
//
//  Created by Alex Nagy on 09/01/2018.
//  Copyright © 2018 Alex Nagy. All rights reserved.
//

import ARKit
import LBTAComponents

class GameViewController: UIViewController, ARSCNViewDelegate {
  
  let arView: ARSCNView = {
    let view = ARSCNView()
    return view
  }()
 
  // MARK: Plus Button
  let plusButtonWidth = ScreenSize.width * 0.1
  lazy var plusButton: UIButton = {
    var button = UIButton(type: .system)
    button.setImage(#imageLiteral(resourceName: "PlusButton").withRenderingMode(.alwaysTemplate), for: .normal)
    button.tintColor = UIColor(white: 1.0, alpha: 0.7)
    button.layer.cornerRadius = plusButtonWidth * 0.5
    button.layer.masksToBounds = true
    button.addTarget(self, action: #selector(handlePlusButtonTapped), for: .touchUpInside)
    button.layer.zPosition = 1
    button.imageView?.contentMode = .scaleAspectFill
    return button
  } ()

  @objc func handlePlusButtonTapped() {
    print("Tapped on plus button")
    addNode()
  }
    
    // MARK: Minus Button
  let minusButtonWidth = ScreenSize.width * 0.1
  lazy var minusButton: UIButton = {
    var button = UIButton(type: .system)
    button.setImage(#imageLiteral(resourceName: "MinusButton").withRenderingMode(.alwaysTemplate), for: .normal)
    button.tintColor = UIColor(white: 1.0, alpha: 0.7)
    button.layer.cornerRadius = minusButtonWidth * 0.5
    button.layer.masksToBounds = true
    button.addTarget(self, action: #selector(handleMinusButtonTapped), for: .touchUpInside)
    button.layer.zPosition = 1
    button.imageView?.contentMode = .scaleAspectFill
    return button
  } ()
    
    @objc func handleMinusButtonTapped() {
        print("Tapped on minus button")
        removeAllBoxes()
    }
    
    // MARK: Reset Button
    let resetButtonWidth = ScreenSize.width * 0.1
    lazy var resetButton: UIButton = {
        var button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ResetButton").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor(white: 1.0, alpha: 0.7)
        button.layer.cornerRadius = resetButtonWidth * 0.5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleResetButtonTapped), for: .touchUpInside)
        button.layer.zPosition = 1
        button.imageView?.contentMode = .scaleAspectFill
        return button
    } ()
    
    @objc func handleResetButtonTapped() {
        print("Tapped on reset button")
        resetScene()
    }
  
  let configuration = ARWorldTrackingConfiguration()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    configuration.planeDetection = .horizontal
    arView.session.run(configuration, options: [])
    arView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
    arView.autoenablesDefaultLighting = true
    arView.delegate = self
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    arView.addGestureRecognizer(tapGestureRecognizer)
  }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let tappedView = sender.view as! SCNView
        let touchLocation = sender.location(in: tappedView)
        let hitTest = tappedView.hitTest(touchLocation, options: nil)
        if !hitTest.isEmpty {
            let result = hitTest.first!
            let name = result.node.name
            let geometry = result.node.geometry
            print("Tapped \(String(describing: name)) with geometry: \(String(describing: geometry))")
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setupViews() {
        view.addSubview(arView)
        arView.fillSuperview()
        
        view.addSubview(plusButton)
        plusButton.anchor(nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, topConstant: 0, leftConstant: 24, bottomConstant: 12, rightConstant: 0, widthConstant: plusButtonWidth, heightConstant: plusButtonWidth)
        
        view.addSubview(minusButton)
        minusButton.anchor(nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 12, rightConstant: 24, widthConstant: minusButtonWidth, heightConstant: minusButtonWidth)
        
        view.addSubview(resetButton)
        resetButton.anchor(nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 12, rightConstant: 0, widthConstant: resetButtonWidth, heightConstant: resetButtonWidth)
        resetButton.anchorCenterXToSuperview()
        
    }
    
    func addNode() {
        let shapeNode = SCNNode()
        //shapeNode.geometry = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0.0002)
        shapeNode.geometry = SCNCapsule(capRadius: 0.05, height: 0.20)
        shapeNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "Material")
        shapeNode.position = SCNVector3(0.0, 0.0, -0.3)
        shapeNode.name = "node"
        arView.scene.rootNode.addChildNode(shapeNode)
    }
    
    func removeAllBoxes() {
        arView.scene.rootNode.enumerateChildNodes{ (node, _) in
            if node.name == "node" {
                node.removeFromParentNode()
            }
        }
    }
    
    func resetScene() {
        arView.session.pause()
        arView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == "node" {
                node.removeFromParentNode()
            }
        }
        arView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
        
    }
    
    func createFloor(anchor: ARPlaneAnchor) -> SCNNode {
        let floor = SCNNode()
        floor.name = "floor"
        floor.eulerAngles = SCNVector3(90.degreesToRadians,0,0)
        floor.geometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        floor.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "Material")
        floor.geometry?.firstMaterial?.isDoubleSided = true
        // set floor position
        floor.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
        return floor
    }
    
    func removeNode(named: String) {
        arView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == named {
                node.removeFromParentNode()
            }
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchorPlane = anchor as? ARPlaneAnchor else { return }
        print("New Plane Anchor found at extent:", anchorPlane.extent)
        let floor = createFloor(anchor: anchorPlane)
        node.addChildNode(floor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchorPlane = anchor as? ARPlaneAnchor else { return }
        print("Plane Anchor updated with extent:", anchorPlane.extent)
        removeNode(named: "floor")
        let floor = createFloor(anchor: anchorPlane)
        node.addChildNode(floor)
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let anchorPlane = anchor as? ARPlaneAnchor else { return }
        print("Plane Anchor removed with extent:", anchorPlane.extent)
        removeNode(named: "floor")
    }
    
    
    
    
    
    
    
    
    
}
