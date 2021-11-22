import SwiftUI
import Firebase

@main
struct PetProject1App: App {
    @StateObject private var sessionStore = SessionStore()
    var body: some Scene {
        WindowGroup {
            MainMenu()
                .environmentObject(sessionStore)
        }
    }
    
    init() {
        FirebaseApp.configure()
    }
}
