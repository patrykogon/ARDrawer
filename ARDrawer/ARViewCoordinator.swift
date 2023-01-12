import SwiftUI
import RealityKit
import SceneKit
import Vision
import ARKit

class ARViewCoordinator: NSObject, ARSessionDelegate {
     var arVC: ARViewContainer

     @Binding var size: Float
    @Binding var color: Color

    init(_ control: ARViewContainer, size: Binding<Float>, color: Binding<Color>) {
         self.arVC = control
        _size = size
        _color = color
     }

     func session(_ session: ARSession, didUpdate frame: ARFrame) {
     }
 }
