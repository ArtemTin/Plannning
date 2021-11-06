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
    
    var store: Firestore?
    
    var handle: AuthStateDidChangeListenerHandle?
    
    deinit {
        if handle != nil {
            Auth.auth().removeStateDidChangeListener(handle!)
        }
    }
    
    init() {
        self.store = Firestore.firestore()
        if handle == nil {
            handle = Auth.auth().addStateDidChangeListener({ [unowned self] _, user in
                self.session = user
                self.displayName = user?.displayName
            })
        }
    }
    
    func addDBListener(forDocument: String, inCollection: String) {
        self.store?.collection(inCollection).document(forDocument).addSnapshotListener({ documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            print("Current data: \(data)")
        })
    }
}
