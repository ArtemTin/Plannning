import FirebaseStorage
import FirebaseAuth
import SwiftUI


struct FileRedactor: View {
    var fileRef: FRFile
    @State private var docString: String = ""
    @State private var showingFatalErrorAlert: Bool = false
    @State private var fatalErrorText: String = ""
    @State private var showingErrorAlert: Bool = false
    @State private var errorText: String = ""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        TextEditor(text: $docString)
            .padding()
            .background(.ultraThinMaterial)
        .onAppear {
            fileRef.ref.getData(maxSize: 5 * 1024 * 1024) {
                data, error in
                if let realError = error {
                    fatalErrorText = realError.localizedDescription
                    showingFatalErrorAlert = true
                } else {
                    docString = String(data: data!, encoding: .utf8)!
                }
            }
        }
        .navigationBarItems(trailing: Button("Save") {
            let data = docString.data(using: .utf8)!
            let _ = fileRef.ref.putData(data, metadata: nil) {
                metadata, error in
                if let realError = error {
                    errorText = realError.localizedDescription
                    showingErrorAlert = true
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        })
        // fatal
        .alert("Error occured",
               isPresented: $showingFatalErrorAlert,
               actions: {
            Button(role: .destructive,
                   action: {
                showingFatalErrorAlert = false
                presentationMode.wrappedValue.dismiss()
            }, label: { Text("Exit") })
        }, message: { Text(fatalErrorText) })
        // common
        .alert("Error occured",
               isPresented: $showingErrorAlert,
               actions: {
            Button(role: .cancel,
                   action: {
                showingErrorAlert = false
            }, label: { Text("Dismiss") })
        }, message: { Text(errorText) })
    }
}
