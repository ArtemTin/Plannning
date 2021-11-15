import SwiftUI
import FirebaseStorage
import FirebaseAuth

struct FRFile: Identifiable {
    let id = UUID()
    let name: String
    let ref: StorageReference
}

struct ExistingProjectMenu: View {
    @EnvironmentObject var sessionStore: SessionStore
    @State var filesList: [FRFile] = []
    
    @State var showingErrorAlert = false
    @State var errorText = ""
    var body: some View {
        if let user = sessionStore.session {
            List {
                ForEach(filesList) {
                    f in
                    NavigationLink(destination: FileRedactor(fileRef: f)) {
                        Text(f.name)
                    }
                }
            }
            .onAppear {
                let privatePath = Storage.storage().reference().child("user/\(user.uid)/private")
                privatePath.listAll { result, error in
                    if let realError = error {
                        errorText = realError.localizedDescription
                        showingErrorAlert = true
                    } else {
                        for item in result.items {
                            filesList.append(FRFile(name: item.name, ref: item))
                        }
                    }
                }
            }
            
        } else {
            Text("You're not signed in!")
        }
    }
}

struct ImportProjectMenu: View {
    var body: some View {
        Text("ImportProject: pass")
            .navigationTitle("Import")
    }
}

struct NewProjectMenu: View {
    var body: some View {
        Text("NewProject: pass")
            .navigationTitle("New")
    }
}
