import SwiftUI
import Firebase


class SessionStore: ObservableObject {
    @Published var session: User?
    
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
            })
        }
    }
    
}


struct MainMenu: View {
    
    @StateObject var sessionStore = SessionStore()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account")) {
                    NavigationLink(destination: AccountMainMenu()) {
                        HStack {
                            Image(systemName: "person.circle")
                            if let user = sessionStore.session {
                                Text("Welcome, \(user.email ?? "Anon")!")
                            } else {
                                Text("Sign in / sign up")
                            }
                        }
                    }
                }
            }
        }
        .environmentObject(sessionStore)
    }
}

func logOutFirebase() {
    do {
        try Auth.auth().signOut()
    } catch let signOutError as NSError {
        print("Error signing out: %@", signOutError)
    }
}

struct AccountMainMenu: View {
    @State private var showingLogoutAlert: Bool = false
    @EnvironmentObject var sessionStore: SessionStore
    
    var body: some View {
        if let user = sessionStore.session { // user is logged in
            Form { // basic account info
                Text("Your E-mail: \(user.email ?? "*error getting email*")")
                Text("Your name: \(user.displayName ?? "*error getting name*")") // TODO: после регистрации имя не подгружается, тк это не ивент изменения статуса входа/выхода
                
                Button("Log out", action: { showingLogoutAlert.toggle() })
            }
            
            .alert("Are you sure?", isPresented: $showingLogoutAlert) { // Log out alert
                Button(role: .destructive, action: logOutFirebase, label: { Text("Log out") })
                Button(role: .cancel, action: { showingLogoutAlert = false }, label: { Text("Cancel") })
            } message: {
                Text("Are you sure want to log out from \(sessionStore.session?.email ?? "*error getting email*")?")
            }
        }
        else { // user isn't logged in
            NavigationView {
                Form {
                    NavigationLink(destination: CreateAccountView()) {
                        Text("Create new account")
                            .bold()
                    }
                    NavigationLink(destination: LogInView()) {
                        Text("Log-in into existing account")
                            .bold()
                    }
                }
            }
            .navigationTitle(Text("You're not signed in"))
        }
    }
}


struct CreateAccountView: View {
    @State private var userEmail = ""
    @State private var userName = ""
    @State private var userPassword = ""
    @State private var userPasswordConfirmation = ""
    @FocusState private var emailFieldIsFocused: Bool
    @FocusState private var nameFieldIsFocused: Bool
    @FocusState private var passwordFieldIsFocused: Bool
    @FocusState private var passwordConfirmationFieldIsFocused: Bool
    @State private var showingErrorAlert: Bool = false
    @State private var errorText: String = ""
    @State private var showingSuccessAlert: Bool = false
    @State private var successText: String = ""
    @EnvironmentObject var sessionStore: SessionStore
    
    var body: some View {
        Form { // new account form
            TextField(
                "E-mail",
                text: $userEmail,
                prompt: Text("Enter your e-mail address")
            )
                .focused($emailFieldIsFocused)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            TextField(
                "Name",
                text: $userName,
                prompt: Text("Enter your name")
            )
                .focused($nameFieldIsFocused)
            SecureField(
                "Password",
                text: $userPassword,
                prompt: Text("Enter your password")
            )
                .focused($passwordFieldIsFocused)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            SecureField(
                "Password confirmation",
                text: $userPasswordConfirmation,
                prompt: Text("Repeat your password")
            )
                .focused($passwordConfirmationFieldIsFocused)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            if userPasswordConfirmation != userPassword {
                Text("Passwords don't match")
            }
            Button("Create account") {
                Auth.auth().createUser(withEmail: userEmail, password: userPassword) {
                    data, error in
                    if let realError = error {
                        errorText = realError.localizedDescription
                        print(errorText)
                        showingErrorAlert = true
                    } else {
                        let changeRequest = sessionStore.session?.createProfileChangeRequest()
                        changeRequest?.displayName = userName
                        if let cR = changeRequest {
                            cR.commitChanges { error in
                                if let realError = error {
                                    errorText = realError.localizedDescription
                                    print(errorText)
                                    showingErrorAlert = true
                                } else {
                                    successText = "We successfully created user with email \(userEmail)"
                                    print(successText)
                                    showingSuccessAlert = true
                                }
                            }
                        } else {
                            errorText = "Error creating changeRequest"
                            print(errorText)
                            showingErrorAlert = true
                        }
                    }
                }
            }
        }
        .alert("Error occured",
               isPresented: $showingErrorAlert,
               actions: {
            Button(role: .cancel,
                   action: {
                showingErrorAlert.toggle()
                userPassword = ""
                userPasswordConfirmation = ""
            }, label: { Text("Dismiss") })
        }, message: { Text(errorText) })
        
        .alert("Success",
               isPresented: $showingSuccessAlert,
               actions: {
            Button(role: .none,
                   action: {
                showingSuccessAlert.toggle()
            }, label: { Text("Okay") })
        }, message: { Text(successText) })
    }
}

struct LogInView: View {
    @State private var userEmail: String = ""
    @State private var userPassword: String = ""
    @State private var showingErrorAlert: Bool = false
    @State private var errorText: String = ""
    @State private var showingSuccessAlert: Bool = false
    @State private var successText: String = ""
    @FocusState private var emailFieldIsFocused: Bool
    @FocusState private var passwordFieldIsFocused: Bool
    
    @EnvironmentObject var sessionStore: SessionStore
    
    var body: some View {
        Form {
            Section(header: Text("E-mail")) {
                TextField(
                    "Your e-mail",
                    text: $userEmail,
                    prompt: Text("Enter your e-mail")
                )
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .focused($emailFieldIsFocused)
            }
            Section(header: Text("Password")) {
                SecureField(
                    "Your password",
                    text: $userPassword,
                    prompt: Text("Enter your password")
                )
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .focused($passwordFieldIsFocused)
            }
            Button("Log-in") {
                Auth.auth().signIn(withEmail: userEmail, password: userPassword) { data, error in
                    if let realError = error {
                        errorText = realError.localizedDescription
                        print(errorText)
                        showingErrorAlert = true
                    } else {
                        successText = "We succefully logged you into \(sessionStore.session?.email ?? "*error getting email*")"
                        print(successText)
                        showingSuccessAlert = true
                    }
                }
            }
        }
        .alert("Error occurred", isPresented: $showingErrorAlert) {
            Button(role: .cancel) {
                showingErrorAlert.toggle()
            } label: {
                Text("Cancel")
            }
            
        } message: {
            Text(errorText)
        }
        .alert("Success", isPresented: $showingSuccessAlert) {
            Button("Okay") {
                showingSuccessAlert.toggle()
            }
        } message: {
            Text(successText)
        }
        
        
    }
}

struct NewProjectMenu: View {
    var body: some View {
        Text("NewProject: pass")
    }
}

struct OpenProjectMenu: View {
    var body: some View {
        Text("Open project: pass")
    }
}

struct SettingsMenu: View {
    var body: some View {
        Text("Settings: pass")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenu()
    }
}
