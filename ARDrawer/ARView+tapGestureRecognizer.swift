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
         guard let coordinator = self.session.delegate as? ARViewCoordinator else { return }
             
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
         
         let box = CustomBox(color: .red, size: coordinator.size)
         box.generateCollisionShapes(recursive: true)
         box.transform = Transform(matrix: result.worldTransform)

         self.installGestures(.all, for: box)
         
         let anchorEntity = AnchorEntity(plane: .horizontal)
         anchorEntity.addChild(box)
         
         self.scene.anchors.append(anchorEntity)
     }
 }
