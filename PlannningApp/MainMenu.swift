import SwiftUI
import Firebase

struct MainMenu: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: AccountMainMenu()) {
                    HStack {
                        Image(systemName: "person.circle")
                        if let user = Auth.auth().currentUser {
                            Text("Welcome, \(user.email ?? "Anon")!")
                        } else {
                            Text("Sign in / sign up")
                        }
                    }
                }
            }
        }
    }
}

struct AccountMainMenu: View {
    var body: some View {
        if let user = Auth.auth().currentUser {
            Text(user.email ?? "Error retrieving user email")
        }
        else {
            NavigationView {
                List {
                    Text("New account: pass")
                        .padding()
                    NavigationLink(destination: CreateAccountView()) {
                        Text("Create new account")
                            .bold()
                    }
                }
            }
            
        }
    }
}


struct CreateAccountView: View {
    @State private var userEmail = ""
    @State private var userPassword = ""
    @State private var userPasswordConfirmation = ""
    @FocusState private var emailFieldIsFocused: Bool
    @FocusState private var passwordFieldIsFocused: Bool
    @FocusState private var passwordConfirmationFieldIsFocused: Bool
    @State private var showingErrorAlert: Bool = false
    @State private var errorText: String = ""
    @State private var showingSuccessAlert: Bool = false
    @State private var successText: String = ""
    
    var body: some View {
        Form {
            TextField(
                "E-mail",
                text: $userEmail,
                prompt: Text("Enter your e-mail address")
            )
                .focused($emailFieldIsFocused)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .border(.secondary)
            SecureField(
                "Password",
                text: $userPassword,
                prompt: Text("Enter your password")
            )
                .focused($passwordFieldIsFocused)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .border(.secondary)
            SecureField(
                "Password confirmation",
                text: $userPasswordConfirmation,
                prompt: Text("Repeat your password")
            )
                .focused($passwordConfirmationFieldIsFocused)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .border(.secondary)
            if userPasswordConfirmation != userPassword {
                Text("Passwords don't match")
            }
            Button("Create account") {
                Auth.auth().createUser(withEmail: userEmail, password: userPassword) {
                    data, error in
                    if let realError = error {
                        self.showingErrorAlert = true
                        self.errorText = realError.localizedDescription
                    } else {
                        self.showingSuccessAlert = true
                        self.successText = "We successfully credete user with email \(userEmail)"
                    }
                }
            }
        }
        .alert("Error occured",
               isPresented: $showingErrorAlert,
               actions: {
            Button(role: .cancel,
                action: {
                    self.showingErrorAlert = false
                    self.userPassword = ""
                    self.userPasswordConfirmation = ""
                }, label: {
                    Text("Dismiss")
                })
        },
               message: { Text(errorText) })
        .alert("Success",
               isPresented: $showingSuccessAlert,
               actions: {
            Button(role: .none,
                   action: {
                self.showingSuccessAlert = false
            }, label: {
                Text("Okay")
            })
        }, message: {
            Text(successText)
        })
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
