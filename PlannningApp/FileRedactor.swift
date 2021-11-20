import FirebaseStorage
import FirebaseAuth
import SwiftUI


struct FileRedactor: View {
    var fileRef: FRFile
    @State var docString: String = ""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        Form {
            TextEditor(text: $docString)
        }
        .onAppear {
            fileRef.ref.getData(maxSize: 5 * 1024 * 1024) { data, error in
                if let _ = error {
                    
                } else {
                    docString = String(data: data!, encoding: .utf8)!
                }
            }
        }
        .navigationBarItems(trailing: Button("Close") {
            presentationMode.wrappedValue.dismiss()
        })
    }
}
