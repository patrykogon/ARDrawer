import SwiftUI
import RealityKit
import SceneKit
import Vision
import ARKit



struct ContentView : View {
    @State var size: Float = 0.05
    
    var body: some View {
        ZStack {
            ARViewContainer(size: $size).edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                HStack {
                    Spacer(minLength: 32)
                    Slider(value: $size, in: 0.01...0.1, step: 0.01)
                    Spacer(minLength: 32)
                }
                Spacer().frame(height: 16)
            }
            
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var size: Float
    
    func makeCoordinator() -> ARViewCoordinator {
        ARViewCoordinator(self, size: $size)
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.addCoaching()
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        arView.session.run(config, options: [])
        
        arView.setupGestures()
        
        arView.session.delegate = context.coordinator
        return arView
    }
    func updateUIView(_ uiView: ARView, context: Context) { }
}

extension ARView: ARCoachingOverlayViewDelegate {
    func addCoaching() {
        
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.delegate = self
        coachingOverlay.session = self.session
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        coachingOverlay.goal = .anyPlane
        self.addSubview(coachingOverlay)
    }
    
    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        //Ready to add entities next?
    }
}

class CustomBox: Entity, HasModel, HasAnchoring, HasCollision {
    required init(color: UIColor, size: Float = 0.1) {
        super.init()
        self.components[ModelComponent.self] = ModelComponent(
            mesh: .generateBox(size: size),
            materials: [SimpleMaterial(color: color, isMetallic: false)]
        )
    }
    
    convenience init(color: UIColor, position: SIMD3<Float>) {
        self.init(color: color)
        self.position = position
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
