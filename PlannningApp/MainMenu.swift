//
//  ContentView.swift
//  PetProject1
//
//  Created by Артём Тихоненко on 20.10.2021.
//

import SwiftUI

struct MainMenu: View {
    @State private var menuSelection: String?
    
    var mainMenuItemsDictionary: [String: AnyView] = ["Account": AnyView(AccountMainMenu()), "New Project": AnyView(NewProjectMenu()), "Open Existing Project": AnyView(OpenProjectMenu()), "Settings": AnyView(SettingsMenu())]
    
    var mainMenuItems = ["Account", "New Project", "Open Existing Project", "Settings"]
    
    var body: some View {
        NavigationView {
            List(selection: $menuSelection) {
                ForEach(mainMenuItemsDictionary.keys.compactMap({$0}), id: \.self) { item in
                    NavigationLink(destination: mainMenuItemsDictionary[item]) {
                        Text("\(item)")
                    }
                }
            }
        }
        .onAppear(perform: LoadData)
    }
    
    func LoadData() {
        let abc = 15
    }
}

struct AccountMainMenu: View {
    var body: some View {
        Text("Your account: pass")
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
