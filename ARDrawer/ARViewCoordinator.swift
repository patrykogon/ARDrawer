import SwiftUI
import RealityKit
import SceneKit
import Vision
import ARKit
import Combine

enum SelectedModel: String, Equatable, CaseIterable {
    case box = "Box"
    case boxWithPhysics = "Box with Physics"
    case multimeter = "Multimeter"
    case ogon = "Ogon"
    case profesor = "Profesor"
    case pawello = "pawello"
    case agata = "agata"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

final class ARViewCoordinator: NSObject, ARSessionDelegate {
    var arVC: ARViewContainer
    unowned var arView: ARView?
    
    @Binding var size: Float
    @Binding var color: Color
    @Binding var selectedModel: SelectedModel
    @Binding var isLoading: Bool
    
    var cancellables = Set<AnyCancellable>()
    
    lazy var request:VNRequest = {
        var handPoseRequest = VNDetectHumanHandPoseRequest(completionHandler: handDetectionCompletionHandler)
        handPoseRequest.maximumHandCount = 1
        return handPoseRequest
    }()
    
    init(
        _ control: ARViewContainer,
        size: Binding<Float>,
        isLoading: Binding<Bool>,
        color: Binding<Color>,
        selectedModel: Binding<SelectedModel> // zwrapować w jakąś strukturkę
    ) {
        self.arVC = control
        _size = size
        _color = color
        _selectedModel = selectedModel
        _isLoading = isLoading
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let pixelBuffer = frame.capturedImage
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let handler = VNImageRequestHandler(cvPixelBuffer:pixelBuffer, orientation: .up, options: [:])
            do {
                try handler.perform([self.request])
            } catch let error {
                print(error)
            }
        }
    }
    
    private var recentIndexFingerPoint: CGPoint = .zero
    func handDetectionCompletionHandler(request: VNRequest?, error: Error?) {
            guard let observation = request?.results?.first as? VNHumanHandPoseObservation else { return }
            guard let indexFingerTip = try? observation.recognizedPoints(.all)[.indexTip],
                  indexFingerTip.confidence > 0.3 else {return}
            let normalizedIndexPoint = VNImagePointForNormalizedPoint(
                CGPoint(
                    x: indexFingerTip.location.y,
                    y: indexFingerTip.location.x),
                Int(UIScreen.main.bounds.width),
                Int(UIScreen.main.bounds.height)
            )
        
            if let arView, let entity = arView.entity(at: normalizedIndexPoint) as? ModelEntity {
                entity.addForce([0,40,0], relativeTo: nil)
            }
            recentIndexFingerPoint = normalizedIndexPoint
        }
}
