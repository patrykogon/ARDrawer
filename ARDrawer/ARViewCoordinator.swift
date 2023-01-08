import SwiftUI
import RealityKit
import SceneKit
import Vision
import ARKit

class ARViewCoordinator: NSObject, ARSessionDelegate {
     var arVC: ARViewContainer

//     @Binding var overlayText: String

    init(_ control: ARViewContainer) {//, overlayText: Binding<String>) {
         self.arVC = control
//         _overlayText = overlayText
     }

     func session(_ session: ARSession, didUpdate frame: ARFrame) {
     }
 }
