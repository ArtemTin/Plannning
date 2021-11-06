import SwiftUI
import Firebase                                                                                       

struct MainMenu: View {
    
    @StateObject var sessionStore = SessionStore()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account")) {
                    NavigationLink(destination: AccountMainMenu()) {
                        HStack {
                            Image(systemName: "person.circle")
                            if let user = sessionStore.session {
                                Text("Welcome, \(user.email ?? "Anon")!")
                            } else {
                                Text("Sign in / sign up")
                            }
                        }
                    }
                }
            }
            .navigationTitle(Text("Plannning"))
        }
        .environmentObject(sessionStore)
    }
}

struct NewProjectMenu: View {
    var body: some View {
        Text("NewProject: pass")
    }
}

struct OpenProjectMenu: View {
    var body: some View {
        Text("Open project: pass")
    }
}

struct SettingsMenu: View {
    var body: some View {
        Text("Settings: pass")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenu()
    }
}
