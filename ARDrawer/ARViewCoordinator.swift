import SwiftUI
import RealityKit
import SceneKit
import Vision
import ARKit

class ARViewCoordinator: NSObject, ARSessionDelegate {
     var arVC: ARViewContainer

     @Binding var size: Float

    init(_ control: ARViewContainer, size: Binding<Float>) {
         self.arVC = control
        _size = size
     }

     func session(_ session: ARSession, didUpdate frame: ARFrame) {
     }
 }
