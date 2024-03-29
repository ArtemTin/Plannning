import SwiftUI
import Firebase

struct AccountMainMenu: View {
    @State private var showingLogoutAlert: Bool = false
    @EnvironmentObject private var sessionStore: SessionStore
    var body: some View {
        if let user = sessionStore.session { // user is logged in
            Form { // basic account info
                Section("ID: \(user.uid)") {
                    Text("Your E-mail: \(user.email ?? "*error getting email*")")
                    ZStack {
                        NavigationLink(destination: ChangeAccountName()) {
                            EmptyView()
                        }
                        .opacity(0)
                        HStack {
                            Text("Your name: \(user.displayName ?? "*error getting name*")")
                            Spacer()
                            Image(systemName: "pencil")
                        }
                    }
                }
                
                
                Button("Log out", action: { showingLogoutAlert = true })
            }
            .navigationTitle("Your info")
            .alert("Are you sure?", isPresented: $showingLogoutAlert) { // Log out alert
                Button(role: .destructive, action: { logOutFirebase(); showingLogoutAlert = false }, label: { Text("Log out") })
                Button(role: .cancel, action: { showingLogoutAlert = false }, label: { Text("Cancel") })
            } message: {
                Text("You are logging out from \(sessionStore.session?.email ?? "*error getting email*")")
            }
        }
        else { // user isn't logged in
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
            .navigationTitle("Welcome!")
        }
    }
}


struct ChangeAccountName: View {
    @EnvironmentObject private var sessionStore: SessionStore
    @State private var newUserName: String = ""
    @State private var errorText: String = ""
    @State private var showingErrorAlert: Bool = false
    @State private var successText: String = ""
    @State private var showingSuccessAlert: Bool = false
    @FocusState private var newNameFieldIsFocused: Bool
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        Form {
            Section("Old name") {
                Text(sessionStore.session!.displayName ?? "error getting displayName")
            }
            TextField("New name", text: $newUserName, prompt: Text("Enter your new name"))
                .focused($newNameFieldIsFocused)
                .disableAutocorrection(true)
            Button("Submit") {
                let changeRequest = sessionStore.session!.createProfileChangeRequest()
                changeRequest.displayName = newUserName
                changeRequest.commitChanges { error in
                    if let realError = error {
                        errorText = realError.localizedDescription
                        showingErrorAlert = true
                    } else {
                        sessionStore.displayName = newUserName
                        successText = "We succesfully changed your name to \(newUserName)"
                        showingSuccessAlert = true
                    }
                }
                
            }
        }
        .alert("Error occured", isPresented: $showingErrorAlert) {
            Button(role: .cancel) {
                showingErrorAlert = false
            } label: { Text("Dismiss") }
        } message: { Text(errorText) }
        
        .alert("Success", isPresented: $showingSuccessAlert) {
            Button {
                showingSuccessAlert = false
                presentationMode.wrappedValue.dismiss()
            } label: { Text("Okay") }
        } message: { Text(successText) }
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
    @EnvironmentObject private var sessionStore: SessionStore
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    // TODO: Проверка совпадения паролей только если второе поле непустое. Также приложение делает проверки, а не гугл (совпадение паролей и заполненность полей). Сделать кнопку серой, если не заполнено поле.
    
    var body: some View {
        Form {
            Section(header: Text("E-mail")) {
                TextField("E-mail", text: $userEmail, prompt: Text("Enter your e-mail address"))
                    .focused($emailFieldIsFocused)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            }
            TextField("Name", text: $userName, prompt: Text("Enter your name"))
                .focused($nameFieldIsFocused)
                .disableAutocorrection(true)
            
            Section(header: Text("Password")) {
                SecureField("Password", text: $userPassword, prompt: Text("Enter your password"))
                    .focused($passwordFieldIsFocused)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                
                SecureField("Password confirmation", text: $userPasswordConfirmation, prompt: Text("Repeat your password"))
                    .focused($passwordConfirmationFieldIsFocused)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                
                if userPasswordConfirmation != userPassword && userPasswordConfirmation != "" {
                    Text("Passwords don't match")
                }
            }
            
            Button("Create account") {
                Auth.auth().createUser(withEmail: userEmail, password: userPassword) {
                    data, error in
                    if let realError = error {
                        errorText = realError.localizedDescription
                        print(errorText)
                        showingErrorAlert = true
                    } else {
                        // setting displayName
                        let changeRequest = sessionStore.session!.createProfileChangeRequest()
                        changeRequest.displayName = userName
                        changeRequest.commitChanges {
                            error in
                            if error != nil {
                                successText = "We created the account, but couldn't set displayName"
                                print(successText)
                                showingSuccessAlert = true
                            } else {
                                successText = "We successfully created user with email \(userEmail)"
                                sessionStore.displayName = userName
                                print(successText)
                                showingSuccessAlert = true
                            }
                        }
                    }
                }
            }
            .disabled(userPassword != userPasswordConfirmation || userPassword == "" || userPasswordConfirmation == "")
        }
        .navigationTitle("New account")
        .alert("Error occured", isPresented: $showingErrorAlert) {
            Button(role: .cancel) {
                showingErrorAlert = false
            } label: { Text("Dismiss") }
        } message: { Text(errorText) }
        
        .alert("Success", isPresented: $showingSuccessAlert) {
            Button {
                showingSuccessAlert = false
                presentationMode.wrappedValue.dismiss()
            } label: { Text("Okay") }
        } message: { Text(successText) }
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
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var sessionStore: SessionStore
    
    var body: some View {
        Form {
            Section(header: Text("E-mail")) {
                TextField("Your e-mail", text: $userEmail, prompt: Text("Enter your e-mail"))
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
        .navigationTitle("Log in")
        .alert("Error occurred", isPresented: $showingErrorAlert) {
            Button(role: .cancel) {
                showingErrorAlert = false
            } label: { Text("Cancel") }
        } message: { Text(errorText) }
        
        .alert("Success", isPresented: $showingSuccessAlert) {
            Button {
                showingSuccessAlert = false
                presentationMode.wrappedValue.dismiss()
            } label: { Text("Okay") }
        } message: { Text(successText) }
    }
}

