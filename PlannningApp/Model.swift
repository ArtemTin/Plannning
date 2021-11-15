import Foundation
import Firebase

func logOutFirebase() {
    do {
        try Auth.auth().signOut()
    } catch let signOutError as NSError {
        print("Error signing out: %@", signOutError)
    }
}

class SessionStore: ObservableObject {
    @Published var session: User?
    @Published var displayName: String?
    var handle: AuthStateDidChangeListenerHandle?
    
    deinit {
        if handle != nil {
            Auth.auth().removeStateDidChangeListener(handle!)
        }
    }
    
    init() {
        if handle == nil {
            handle = Auth.auth().addStateDidChangeListener({ [unowned self] _, user in
                self.session = user
                self.displayName = user?.displayName
            })
        }
    }
}

class FilesStore {
    let storage = Storage.storage()
}
