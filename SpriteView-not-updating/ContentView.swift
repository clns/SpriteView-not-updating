import SwiftUI
import SpriteKit

class GameScene: SKScene, ObservableObject {
    @Published var updates = 0
    private let label = SKLabelNode(text: "Updates in SKScene:\n0")
    
    override func didMove(to view: SKView) {
        addChild(label)
        label.numberOfLines = 4
        label.position = CGPoint(x: 0, y: -100)
    }
    
    override func update(_ currentTime: TimeInterval) {
        updates += 1
        label.text = "Updates in SKScene:\n\(updates)\nScene created at:\n\(name!)"
    }
    
    deinit {
        print("-- Scene \(name!) deinit --")
    }
}

class SceneStore : ObservableObject {
    @Published var currentScene: GameScene
    
    init() {
        currentScene = SceneStore.createScene()
    }
    
    func restartLevel() {
        currentScene = SceneStore.createScene()
    }
    
    // MARK: - Class Functions
    
    static private func createScene() -> GameScene {
        let scene = GameScene()
        scene.size = CGSize(width: 300, height: 400)
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.scaleMode = .fill
        scene.name = Date().formatted(date: .omitted, time: .standard)
        return scene
    }
}

struct ContentView: View {
    @EnvironmentObject private var sceneStore: SceneStore
    @EnvironmentObject private var scene: GameScene
    @State private var paused = false
    
    var body: some View {
        if #available(iOS 15.0, *) {
            print(Self._printChanges())
        }
        return ZStack {
            SpriteView(scene: scene, isPaused: paused).ignoresSafeArea()
            VStack {
                Text("Updates from SKScene: \(scene.updates)").padding().foregroundColor(.white)
                Text("Scene created at: \(scene.name!)" as String).foregroundColor(.white)
                Button("Restart") {
                    sceneStore.restartLevel()
                }.padding()
                Button("Paused: \(paused)" as String) {
                    paused.toggle()
                }
                Spacer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
