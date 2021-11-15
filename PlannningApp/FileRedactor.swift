import FirebaseStorage
import FirebaseAuth
import SwiftUI


struct FileRedactor: View {
    var fileRef: FRFile
    var body: some View {
        Text(fileRef.name)
    }
}
