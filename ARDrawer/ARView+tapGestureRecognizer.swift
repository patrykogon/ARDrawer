import SwiftUI
import RealityKit
import SceneKit
import Vision
import ARKit

extension ARView {
     func setupGestures() {
         let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
         self.addGestureRecognizer(tap)
     }
     
     @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
         
         guard let touchInView = sender?.location(in: self) else {
             return
         }
         
         rayCastingMethod(point: touchInView)
     }
     
     func rayCastingMethod(point: CGPoint) {
         guard let raycastQuery = self.makeRaycastQuery(
            from: point,
            allowing: .existingPlaneInfinite,
            alignment: .horizontal
         ) else {
             print("failed first")
             return
         }
         
         guard let result = self.session.raycast(raycastQuery).first else {
             print("failed")
             return
         }
         
         let transformation = Transform(matrix: result.worldTransform)
         let box = CustomBox(color: .yellow)
         self.installGestures(.all, for: box)
         box.generateCollisionShapes(recursive: true)
         box.transform = transformation
         
         let raycastAnchor = AnchorEntity(raycastResult: result)
         raycastAnchor.addChild(box)
         self.scene.addAnchor(raycastAnchor)
     }
 }
