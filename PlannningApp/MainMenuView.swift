import SwiftUI
import Firebase


struct MainMenu: View {
    
    @StateObject var sessionStore = SessionStore()
    @State var selection: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account")) {
                    NavigationLink(destination: AccountMainMenu()) {
                        HStack {
                            Image(systemName: "person.circle")
                            if let user = sessionStore.session {
                                Text("Welcome, \(user.email ?? "*error getting email*")!")
                            } else {
                                Text("Sign in / sign up")
                            }
                        }
                    }
                }
                Section(header: Text("Projects")) {
                    NavigationLink(destination: ExistingProjectMenu()) {
                        HStack {
                            Text("Open project...")
                        }
                    }
                    
                    NavigationLink(destination: ImportProjectMenu()) {
                        HStack {
                            Text("Browse projects online")
                        }
                    }
                    
                    NavigationLink(destination: NewProjectMenu()) {
                        HStack {
                            Text("Create new project")
                        }
                    }
                }
                Section(header: Text("Settings")) {
                    NavigationLink(destination: SettingsMenu()) {
                        HStack {
                            Text("General settings")
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Plannning"))
        }
        .environmentObject(sessionStore)
    }
}


struct SettingsMenu: View {
    var body: some View {
        Text("Settings: pass")
            .navigationTitle("General")
    }
}

