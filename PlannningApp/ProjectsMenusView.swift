import SwiftUI
import FirebaseStorage
import FirebaseAuth

struct FRFile: Identifiable {
    let id = UUID()
    let name: String
    let ref: StorageReference
    let author: String? = nil
}

struct ExistingProjectMenu: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var sessionStore: SessionStore
    @State private var filesList: [FRFile] = []
    @State private var showingErrorAlert = false
    @State private var errorText = ""
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
            .navigationTitle("Your files")
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
            .alert("Error occured", isPresented: $showingErrorAlert) {
                Button(role: .cancel,
                       action: {
                    showingErrorAlert = false
                    presentationMode.wrappedValue.dismiss()
                }, label: { Text("Dismiss") })
            } message: { Text(errorText) }
            
        } else {
            Text("You're not signed in!")
                .bold()
                .navigationTitle("Your files")
        }
    }
}

struct ImportProjectMenu: View {
    @State private var filesList: [FRFile] = []
    @EnvironmentObject private var sessionStore: SessionStore
    var body: some View {
        Text("ImportProject: pass")
            .navigationTitle("Import")
            .onAppear {
                
            }
        
    }
}

struct NewProjectMenu: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var sessionStore: SessionStore
    @State private var newFileName: String = ""
    @State private var navigationTag: String?
    @State private var showingErrorAlert = false
    @State private var errorText = ""
    
    var body: some View {
        if let user = sessionStore.session {
            Form {
                TextField("New file name", text: $newFileName, prompt: Text("Enter new file name"))
                Button("Proceed") {
                    var flag = false
                    let storage = Storage.storage()
                    let privateFilesPath = storage.reference().child("user/\(user.uid)/private/")
                    privateFilesPath.listAll { (result, error) in
                        if let realError = error {
                            errorText = realError.localizedDescription
                            showingErrorAlert = true
                        } else {
                            for item in result.items {
                                if "user/\(user.uid)/private/\(newFileName)" == item.fullPath {
                                    flag = true
                                }
                            }
                        }
                    }
                    if !flag {
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
                    } else {
                        navigationTag = "1"
                    }
                }
            }
            .navigationTitle("Create a new one")
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
                .isDetailLink(false)
                .hidden()
        } else {
            Text("You're not signed in!")
                .bold()
                .navigationTitle("Create a new one")
        }
    }
}
