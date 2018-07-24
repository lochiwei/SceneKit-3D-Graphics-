import SceneKit

extension SCNNode {
    // put a geometry node
    public func putShape(_ geo:SCNGeometry, at position:SCNVector3? = nil, color:UIColor? = nil) -> SCNNode {
        let node = SCNNode(geometry: geo)
        if let p = position { node.position = p }
        if let c = color { node.geometry?.firstMaterial?.diffuse.contents = c }
        addChildNode(node)
        return node
    }
}
