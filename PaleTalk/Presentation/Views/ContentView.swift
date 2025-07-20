//
//  ContentView.swift
//  PaleTalk
//
//  Created by 이인호 on 7/20/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        switch authViewModel.loginStatus {
        case .googleSignedIn, .appleSignedIn:
            CustomTabView()
        case .signedOut:
            SignInView()
        case .initializing:
            EmptyView()
        }
    }
}

struct CustomTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            EmptyView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)
            
            SettingView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Setting")
                }
                .tag(1)
        }
    }
}

#Preview {
    ContentView()
}

