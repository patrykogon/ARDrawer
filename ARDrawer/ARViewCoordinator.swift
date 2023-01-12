import SwiftUI
import RealityKit
import SceneKit
import Vision
import ARKit

enum SelectedModel: String, Equatable, CaseIterable {
    case box = "Box"
    case multimeter = "Multimeter"
    case ogon = "Ogon"
    case profesor = "Profesor"
    case pawello = "pawello"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

class ARViewCoordinator: NSObject, ARSessionDelegate {
    var arVC: ARViewContainer
    
    @Binding var size: Float
    @Binding var color: Color
    @Binding var selectedModel: SelectedModel
    
    init(
        _ control: ARViewContainer,
        size: Binding<Float>,
        color: Binding<Color>,
        selectedModel: Binding<SelectedModel>
    ) {
        self.arVC = control
        _size = size
        _color = color
        _selectedModel = selectedModel
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
    }
}
