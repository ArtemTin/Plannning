import SwiftUI
import Firebase

@main
struct PetProject1App: App {
    var body: some Scene {
        WindowGroup {
            MainMenu()
        }
    }
    
    init() {
        FirebaseApp.configure()
    }
}
