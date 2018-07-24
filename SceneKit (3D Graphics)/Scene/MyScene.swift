/*
 
 */

import SceneKit
import Vectors

// custom scene class
class MyScene: SCNScene {
    
    // model
    var numbers:[Int] = [2,5,3,6,4]
    
    var chart: SCNNode!
    
    // MARK: - init
    
    // init from code
    override init() {
        super.init()
        setupScene()
        
    }
    
    // init from IB
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupScene()
    }
    
    // scene
    func setupScene() {
        
        // camera, lights
        setupCamera()
        setupLights()
        
        // other nodes in scene
        putFloor()
        putChart()
    }
    
    // MARK: - Scene
    
    // chart
    func putChart() {
        
        let r = 1
        let p = 0.2
        let n = numbers.count
        
        // create chart ndoe
        chart = SCNNode()
        chart.rotation = [0, 1, 0, 0]
        // add chart into scene graph
        rootNode.addChildNode(chart)
        
        // add (bars)
        putBars(heights: numbers, radius: r, padding: p)
        
        // add plane
        let totalWidth = (n-1)*(2*r + p)
        let padding = 8*r
        let w = totalWidth + padding
        let h = padding
        //putPlane(width: CGFloat(w), height: CGFloat(h))
    }
    
    // put plane
    func putPlane(width w:CGFloat, height h:CGFloat) {
        
        let plane = SCNPlane(width: w, height: h)
        
        // solid white, not affected by light
        plane.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        plane.firstMaterial?.lightingModel = .constant
        
        // SCNPlane has NO reflectivity attribute.
        
        // put floor in a node, then put this node into scene graph
        let node = chart.putShape(plane, at: [0, -0.1, 0])
        node.rotation = [1,0,0, -pi/2]
    }
    
    // put bars
    func putBars(heights h:[RealNumber], radius r:RealNumber, padding p:RealNumber) {
        let step = 2 * r.realValue + p.realValue
        let n = h.count
        let totalWidth = (n-1)*step
        for i in 0...(n-1) {
            let offset = i*step - totalWidth/2
            putBar(height: h[i], radius: r, at: (offset, 0))
        }
    }
    
    // bar
    func putBar(height h:RealNumber, radius r:RealNumber, at position:(x:RealNumber, z:RealNumber) = (0,0)) {
        
        let x = position.x.realValue
        let z = position.z.realValue
        
        // create bar node
        let bar = SCNNode()
        bar.position = [x, 0, z]
        // put bar node into chart
        chart.addChildNode(bar)
        
        // cylinder node (bar's subnode)
        let cylinder = SCNCylinder(radius: CGFloat(r.realValue), height: CGFloat(h.realValue))
        //          cylinder.firstMaterial = ?
        let cylNode = bar.putShape(cylinder)
        cylNode.position = [0, h.realValue/2, 0]
        
        // text node (bar's subnode)
        let string = "\(h)"
        let text = SCNText(string: string, extrusionDepth: 0.2)
        text.font = UIFont.systemFont(ofSize: 2.5)
        text.flatness = 0.1  // lower value for smoother text
        text.firstMaterial?.diffuse.contents = UIColor(white: 0.9, alpha: 1)
        
        let textNode = bar.putShape(text)
        
        // ⭐️ rotate text toward camera (text node given inverse transform of the chart node)
        textNode.transform = SCNMatrix4Invert(chart.worldTransform)
        
        // ⭐️ center text on top of bar
        // ⭐️ in iOS, SCNText has NO textSize property
        let w = text.boundingBox.max.x - text.boundingBox.min.x
        textNode.position = [-w/2, h, 0]
    }
    
    // box
    func putBox() {
        let a:CGFloat = 10
        let box = SCNBox(width: a, height: a, length: a, chamferRadius: 0)
        let node = rootNode.putShape(box, at: [0, a/2, 0], color: #colorLiteral(red: 0.239215686917305, green: 0.674509823322296, blue: 0.968627452850342, alpha: 1.0))
        node.rotation = [0, 1, 0, pi/4]
    }
    
    // reflective floor
    // ⭐️ floor is an INFINITE plane ‼️
    func putFloor() {
        // setup floor geometry
        let floor = SCNFloor()
        
        // solid white, not affected by light
        floor.firstMaterial?.diffuse.contents = UIColor.white
        floor.firstMaterial?.lightingModel = .constant
        
        // less reflective, decrease by distance
        floor.reflectivity = 0.15
        floor.reflectionFalloffEnd = 15 // reflection fade out over 15 units
        
        // put floor in a node, then put this node into scene graph
        rootNode.putShape(floor, at: [0, -0.1, 0])
    }
    
    // MARK: - Camera
    
    // camera
    func setupCamera() {
        // camera
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        let angle = -Float(atan(0.5))
        cameraNode.camera = camera
        cameraNode.position = [0, 20, 40]
        cameraNode.rotation = [1,0,0, angle]
        rootNode.addChildNode(cameraNode)
    }
    
    // MARK: - Lights
    
    // setup lights
    func setupLights() {
        addAmbientLight()
        addDirectionalLight()
        addSpotLight()
    }
    
    // spot light (back, up, to the left)
    // ⭐️ Only spotlight can cast shadows
    func addSpotLight() {
        
        // create spotlight
        let light = SCNLight()
        light.type = .spot
        light.color = UIColor(white: 0.4, alpha: 1)
        light.spotInnerAngle = 60  // spotlight inner/outer angle (in degrees)
        light.spotOuterAngle = 100
        
        // allow spotlight to cast shadow
        light.castsShadow = true
        
        
        // put light in node
        let node = SCNNode()
        node.light = light
        node.position = [-30, 25, 30]
        
        // set target (always look at the center of the scene)
        // ⭐️ it's constraints of a node‼️
        let lookAtOrigin = SCNLookAtConstraint(target: rootNode)
        node.constraints = [lookAtOrigin]
        
        // put node into scene graph
        rootNode.addChildNode(node)
    }
    
    // ambient light (make sure everything isn't completely black)
    func addAmbientLight() {
        // create ambient light
        let light = SCNLight()
        light.type = .ambient
        light.color = UIColor(white: 0.25, alpha: 1)
        // put light in node
        let node = SCNNode()
        node.light = light
        // put node in scene graph
        rootNode.addChildNode(node)
    }
    
    // directional light (slightly to the right)
    func addDirectionalLight() {
        // create directional light
        let light = SCNLight()
        light.type = .directional
        light.color = UIColor(white: 0.3, alpha: 1)
        // put light in node
        let node = SCNNode()
        node.light = light
        node.rotation = [0, 1, 0, -pi/4]
        // put node in scene graph
        rootNode.addChildNode(node)
    }
    
}// end: MyScene



