# SpriteView-not-updating

Sample SwiftUI / SpriteKit Xcode 13 project showing a simple `ContentView` that displays a [`SpriteView`](https://developer.apple.com/documentation/spritekit/spriteview) using a `SceneStore` manager with an `@EnvironmentObject var sceneStore: SceneStore` property.

The `ContentView` has a "**Restart**" button that should recreate the `SKScene` when pressed. The `SKScene` gets recreated inside the `SceneStore` and the `ContentView`'s `Text` view (with the new time assigned to the `name` property of the scene), but the `SpriteView` doesn't change the scene.

It seems that the `SpriteView` keeps the initial scene in memory, and doesn't let it go to replace it with the new scene. This can be seen in the Console, by hitting the Restart button twice and looking for something like "*-- Scene 7:49:44 PM deinit --*":

1. on first press, a second scene is created but the first scene doesn't get deinitialized because it is held by the SpriteView
2. on second press, a third scene is created, the second scene gets deinitialized from the `SceneStore`, but the first scene is still inside the SpriteView

The updates from the `@Published var updates = 0` property inside the scene also stop (at the top of the screen), because the new scene that gets created is not added into the view, so the `SKScene.didMove(to view:)` method is never called, thus the `updates` property is 0.

The "**Paused:**" button shows a similar problem with the SpriteView not updating when the state changes.

Related questions:

- [Stackoverflow: SpriteView doesn't pause scene on state change](https://stackoverflow.com/questions/69610165/spriteview-doesnt-pause-scene-on-state-change)
- [Apple Dev Forums: SpriteView doesn't pause scene on state change](https://developer.apple.com/forums/thread/692527)

![SpriteView-not-updating-visual](SpriteView-not-updating.gif)

All the code is in [ContentView.swift](https://github.com/clns/SpriteView-not-updating/blob/main/SpriteView-not-updating/ContentView.swift):

```swift
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
```
