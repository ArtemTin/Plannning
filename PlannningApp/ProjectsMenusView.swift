import SwiftUI
import FirebaseStorage
import FirebaseAuth

struct FRFile: Identifiable {
    let id = UUID()
    let name: String
    let ref: StorageReference
}

struct ExistingProjectMenu: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var sessionStore: SessionStore
    @State var filesList: [FRFile] = []
    
    @State var showingErrorAlert = false
    @State var errorText = ""
    var body: some View {
        if let user = sessionStore.session {
            List {
                ForEach(filesList) {
                    file in
                    NavigationLink(destination: FileRedactor(fileRef: file)) {
                        Text(file.name)
                    }
                }
            }
            .onAppear {
                filesList = []
                let storage = Storage.storage()
                let privateFilesPath = storage.reference().child("user/\(user.uid)/private/")
                privateFilesPath.listAll { (result, error) in
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
            .alert("Error occured",
                   isPresented: $showingErrorAlert,
                   actions: {
                Button(role: .cancel,
                       action: {
                    showingErrorAlert = false
                    presentationMode.wrappedValue.dismiss()
                }, label: { Text("Dismiss") })
            }, message: { Text(errorText) })
            
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
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var sessionStore: SessionStore
    @State var newFileName: String = ""
    @State var navigationTag: String?
    @State var showingErrorAlert = false
    @State var errorText = ""
    
    var body: some View {
        if let user = sessionStore.session {
            Form {
                TextField("New file name", text: $newFileName, prompt: Text("Enter new file name"))
                Button("Proceed") {
                    let privatePath = Storage.storage().reference().child("user/\(user.uid)/private/\(newFileName)")
                    let data = "Hello!".data(using: .utf8)!
                    let _ = privatePath.putData(data, metadata: nil) { metadata, error in
                        if let realError = error {
                            errorText = realError.localizedDescription
                            showingErrorAlert = true
                        } else {
                            navigationTag = "1"
                        }
                    }
                    
                }
            }
            .alert("Error occured",
                   isPresented: $showingErrorAlert,
                   actions: {
                Button(role: .cancel,
                       action: {
                    showingErrorAlert = false
                    presentationMode.wrappedValue.dismiss()
                }, label: { Text("Dismiss") })
            }, message: { Text(errorText) })
            
            NavigationLink("Continue to redacting", tag: "1", selection: $navigationTag, destination: { FileRedactor(fileRef: FRFile(name: newFileName, ref: Storage.storage().reference().child("user/\(user.uid)/private/\(newFileName)"))) })
                .hidden()
        } else {
            Text("You're not signed in!")
        }
    }
}
