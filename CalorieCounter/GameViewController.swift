import ARKit
import LBTAComponents

class GameViewController: UIViewController, ARSCNViewDelegate {
    
    let arView: ARSCNView = {
        let view = ARSCNView()
        return view
    }()
    
    var startingPositionNode: SCNNode?
    var endingPositionNode: SCNNode?
    let cameraRelativePosition = SCNVector3(0,0,-0.1)
    
    var distances: [Float]?
    var calorieCount = Float(0.0)
    
    // MARK: Buttons
    
    // Plus: add a dimension size
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
        addDimensionalDistance()
    }
    
    func addDimensionalDistance() {
        startingPositionNode?.removeFromParentNode()
        endingPositionNode?.removeFromParentNode()
        startingPositionNode = nil
        endingPositionNode = nil
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        arView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        if startingPositionNode != nil && endingPositionNode != nil {
            let addDimensionalDistanceAlert = UIAlertController(title: "Error", message: "You have tapped twice! Please click on Add Button again!", preferredStyle: UIAlertControllerStyle.alert)
            addDimensionalDistanceAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
                print("Cancel")
            })
            self.present(addDimensionalDistanceAlert, animated: true)
        } else if startingPositionNode != nil && endingPositionNode == nil {
            let sphere = SCNNode(geometry: SCNSphere(radius: 0.002))
            sphere.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            Service.addChildNode(sphere, toNode: arView.scene.rootNode, inView: arView, cameraRelativePosition: cameraRelativePosition)
            endingPositionNode = sphere
        } else if startingPositionNode == nil && endingPositionNode == nil {
            let sphere = SCNNode(geometry: SCNSphere(radius: 0.002))
            sphere.geometry?.firstMaterial?.diffuse.contents = UIColor.purple
            Service.addChildNode(sphere, toNode: arView.scene.rootNode, inView: arView, cameraRelativePosition: cameraRelativePosition)
            startingPositionNode = sphere
        }
    }
    
    // Minus: remove a dimension size
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
        removeDimensionalDistance()
    }
    
    func removeDimensionalDistance() {
        print(distances!)
        distances?.remove(at: (distances?.endIndex)!)
    }
    
    // Reset
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
    
    func resetScene() {
        arView.session.pause()
        arView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
    }
    
    // Check: all sizes are added
    let checkButtonWidth = ScreenSize.width * 0.1
    lazy var checkButton: UIButton = {
        var button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "CheckButton").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor(white: 1.0, alpha: 0.7)
        button.layer.cornerRadius = resetButtonWidth * 0.5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleCheckButtonTapped), for: .touchUpInside)
        button.layer.zPosition = 1
        button.imageView?.contentMode = .scaleAspectFill
        return button
    } ()
    
    @objc func handleCheckButtonTapped() {
        print("Tapped on check button")
        calculateCalories()
    }
    
    func calculateCalories() {
        print(distances!)
        calorieCount = 2 * (distances?.reduce(1, *))!
        calories.text = "Calories: " + String(format: "Distance: %.2f", calorieCount)
    }

    // MARK: Labels
    let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.black
        label.text = "Distance:"
        return label
    }()
    
    let type: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.black
        label.text = "Type:"
        return label
    }()
    
    let calories: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.black
        label.text = "Calories:"
        return label
    }()
    
    let tracking: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.black
        label.text = "Tracking State:"
        return label
    }()
    
    let centerImageView: UIImageView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "Center")
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    // MARK: View setup
    func setupViews() {
        view.addSubview(arView)
        arView.fillSuperview()
        
        view.addSubview(plusButton)
        plusButton.anchor(nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, topConstant: 0, leftConstant: 24, bottomConstant: 24, rightConstant: 0, widthConstant: plusButtonWidth, heightConstant: plusButtonWidth)
        
        view.addSubview(minusButton)
        minusButton.anchor(nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, topConstant: 0, leftConstant: 115, bottomConstant: 24, rightConstant: 0, widthConstant: minusButtonWidth, heightConstant: minusButtonWidth)

        view.addSubview(checkButton)
        checkButton.anchor(nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 24, rightConstant: 115, widthConstant: checkButtonWidth, heightConstant: checkButtonWidth)
        
        view.addSubview(resetButton)
        resetButton.anchor(nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 24, rightConstant: 24, widthConstant: resetButtonWidth, heightConstant: resetButtonWidth)
        
        view.addSubview(distanceLabel)
        distanceLabel.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: nil, topConstant: 24, leftConstant: 24, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 24)
        
        view.addSubview(type)
        type.anchor(distanceLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 24, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 24)
        
        view.addSubview(calories)
        calories.anchor(type.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 24, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 24)
        
        view.addSubview(tracking)
        tracking.anchor(calories.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 24, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 24)
        
        view.addSubview(centerImageView)
        centerImageView.anchorCenterSuperview()
        centerImageView.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: ScreenSize.width * 0.05, heightConstant: ScreenSize.width * 0.05)
    }
    
    // MARK: AR Session
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configuration.planeDetection = [.horizontal, .vertical]
        arView.session.run(configuration, options: [])
        arView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        arView.autoenablesDefaultLighting = true
        arView.delegate = self
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func createFloor(anchor: ARPlaneAnchor) -> SCNNode {
        let floor = SCNNode()
        //floor.name = name
        floor.eulerAngles = SCNVector3(90.degreesToRadians,0,0)
        floor.geometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        floor.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "Material")
        floor.opacity = 0.10
        floor.geometry?.firstMaterial?.isDoubleSided = true
        floor.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
        return floor
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.measure()
        }
    }
    
    func measure() {
        type.text = "Type: Cake"
        tracking.text = "Tracking:" + getTrackigDescription()
        if startingPositionNode != nil && endingPositionNode != nil {
            return
        }
        guard let xDistance = Service.distance3(fromStartingPositionNode: startingPositionNode, onView: arView, cameraRelativePosition: cameraRelativePosition)?.x else {return}
        guard let yDistance = Service.distance3(fromStartingPositionNode: startingPositionNode, onView: arView, cameraRelativePosition: cameraRelativePosition)?.y else {return}
        guard let zDistance = Service.distance3(fromStartingPositionNode: startingPositionNode, onView: arView, cameraRelativePosition: cameraRelativePosition)?.z else {return}
        distanceLabel.text = String(format: "Distance: %.2f", Service.distance(x: xDistance, y: yDistance, z: zDistance)) + "m"
        distances?.append( Service.distance(x: xDistance, y: yDistance, z: zDistance) )
    }
    
    var trackingState: ARCamera.TrackingState!
    func getTrackigDescription() -> String {
        var description = ""
        if let t = trackingState {
            switch(t) {
            case .notAvailable:
                description = "TRACKING UNAVAILABLE"
            case .normal:
                description = "TRACKING NORMAL"
            case .limited(let reason):
                switch reason {
                case .excessiveMotion:
                    description = "TRACKING LIMITED - Too much camera movement"
                case .insufficientFeatures:
                    description = "TRACKING LIMITED - Not enough surface detail"
                case .initializing:
                    description = "INITIALIZING"
                case .relocalizing:
                    description = "RELOCALIZING"
                }
            }
        }
        return description
    }
    
    func removeNode(named: String) {
        arView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == named {
                node.removeFromParentNode()
            }
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        trackingState = camera.trackingState
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchorPlane = anchor as? ARPlaneAnchor else { return }
        print("New Plane Anchor found at extent:", anchorPlane.extent)
        let floor = createFloor(anchor: anchorPlane)
        node.addChildNode(floor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchorPlane = anchor as? ARPlaneAnchor else { return }
        //print("Plane Anchor updated with extent:", anchorPlane.extent)
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
