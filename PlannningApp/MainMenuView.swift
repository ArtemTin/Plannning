import SwiftUI
import Firebase


struct MainMenu: View {
    @EnvironmentObject var sessionStore: SessionStore
    @State var selection: String?
    @AppStorage("showIcons") var showIcons = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account")) {
                    NavigationLink(destination: AccountMainMenu()) {
                        HStack {
                            if showIcons {
                                Image(systemName: "person")
                            }
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
                        if showIcons {
                            Image(systemName: "doc.on.doc")
                        }
                        Text("Open project...")
                    }
                    
                    NavigationLink(destination: ImportProjectMenu()) {
                        if showIcons {
                            Image(systemName: "network")
                        }
                        Text("Browse projects online")
                    }
                    
                    NavigationLink(destination: NewProjectMenu()) {
                        if showIcons {
                            Image(systemName: "doc.badge.plus")
                        }
                        Text("Create new project")
                    }
                }
                Section(header: Text("Settings")) {
                    NavigationLink(destination: SettingsMenu()) {
                        if showIcons {
                            Image(systemName: "gear")
                        }
                        Text("General settings")
                    }
                }
            }
            .navigationBarTitle(Text("Plannning"))
        }
    }
}


struct SettingsMenu: View {
    @AppStorage("showIcons") private var showIcons = true
    
    var body: some View {
        Form {
            Toggle("Show icons in main menu", isOn: $showIcons)
        }
    }
}

