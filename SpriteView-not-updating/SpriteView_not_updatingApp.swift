import SwiftUI

@main
struct SpriteView_not_updatingApp: App {
    @StateObject private var sceneStore = SceneStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sceneStore)
                .environmentObject(sceneStore.currentScene)
        }
    }
}
