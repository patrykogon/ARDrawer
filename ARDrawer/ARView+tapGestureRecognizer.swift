import SwiftUI
import RealityKit
import SceneKit
import Vision
import ARKit
import Combine

extension ARView {
    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress(recognizer:))
        )
        
        self.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        let location = recognizer.location(in: self)
        if let anchorEntity = self.entity(at: location)?.anchor {
            anchorEntity.removeFromParent()
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if let touchInView = sender?.location(in: self) {
            rayCastingMethod(point: touchInView)
        }
    }
    
    func rayCastingMethod(point: CGPoint) {
        guard let coordinator = self.session.delegate as? ARViewCoordinator else { return }
        guard let raycastQuery = self.makeRaycastQuery(from: point, allowing: .existingPlaneInfinite, alignment: .horizontal),
              let result = self.session.raycast(raycastQuery).first else { return }
        let anchorEntity = AnchorEntity(plane: .horizontal)
        switch coordinator.selectedModel {
        case .box:
            let box = CustomBox(color: UIColor(coordinator.color), size: coordinator.size)
            box.generateCollisionShapes(recursive: true)
            box.transform = Transform(matrix: result.worldTransform)
            self.installGestures(.all, for: box)
            anchorEntity.addChild(box)
            self.scene.anchors.append(anchorEntity)
        case .boxWithPhysics:
            let plane = ModelEntity(mesh: .generatePlane(width: 2, depth: 2), materials: [OcclusionMaterial()])
            anchorEntity.addChild(plane)
            plane.generateCollisionShapes(recursive: false)
            plane.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .static)
            let box = ModelEntity(mesh: .generateBox(size: 0.05), materials: [SimpleMaterial(color: .white, isMetallic: true)])
            box.generateCollisionShapes(recursive: false)
            box.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .dynamic)
            box.position = [0,0.025,0]
            anchorEntity.addChild(box)
            self.scene.addAnchor(anchorEntity)
        case .multimeter:
            addModelAsync(name: "test", result: result, coordinator: coordinator)
        case .ogon:
            addModelAsync(name: "ogon", result: result, coordinator: coordinator)
        case .profesor:
            addModelAsync(name: "profesor", result: result, coordinator: coordinator)
        case .pawello:
            addModelAsync(name: "pawello", result: result, coordinator: coordinator)
        case .agata:
            addModelAsync(name: "agata1", result: result, coordinator: coordinator)
        }
        
        func addModelAsync(name: String, result: ARRaycastResult, coordinator: ARViewCoordinator) {
            coordinator.isLoading = true
            let plane = ModelEntity(mesh: .generatePlane(width: 2, depth: 2), materials: [OcclusionMaterial()])
            anchorEntity.addChild(plane)
            plane.generateCollisionShapes(recursive: false)
            plane.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .static)
            
            Entity.loadModelAsync(named: name)
                .sink(receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print("Unable to load a model due to error \(error)")
                    }
                    coordinator.isLoading = false
                    coordinator.cancellables.removeAll()
                    
                }, receiveValue: { [weak self] (model: Entity) in
                    guard let self else { return }
                    if let model = model as? ModelEntity {
                        print("Congrats! Model is successfully loaded!")
                        model.transform = Transform(matrix: result.worldTransform)
                        model.generateCollisionShapes(recursive: true)
                        self.installGestures(.all, for: model)
                        model.generateCollisionShapes(recursive: false)
                        model.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .dynamic)
                        model.position = [0,0.025,0]
                        anchorEntity.addChild(model)
                        self.scene.anchors.append(anchorEntity)
                        coordinator.cancellables.removeAll()
                        coordinator.isLoading = false
                    }
                })
                .store(in: &coordinator.cancellables)
        }
    }
}
