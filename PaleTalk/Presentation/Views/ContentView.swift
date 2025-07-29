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
        Group {
            switch authViewModel.loginStatus {
            case .signedOut:
                NavigationStack {
                    SignInView()
                }
            case .googleSignedIn, .appleSignedIn:
                CustomTabView()
                    .transition(.move(edge: .trailing))
            case .initializing:
                EmptyView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authViewModel.loginStatus)
    }
}

struct CustomTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var drawingViewModel: DrawingViewModel
    @State private var selection = 0
    @State private var isReady = false
    
    init() {
        let appearence = UITabBarAppearance()
        appearence.configureWithOpaqueBackground()
        appearence.backgroundColor = UIColor.darkGray.withAlphaComponent(0.1)
        
        UITabBar.appearance().standardAppearance = appearence
        UITabBar.appearance().scrollEdgeAppearance = appearence
    }
    var body: some View {
        if isReady {
            TabView(selection: $selection) {
                HomeView()
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
        } else {
            Color.clear // splashview
                .task {
                    await authViewModel.getUser()
                    
                    await drawingViewModel.getTodayDrawings(userId: authViewModel.currentUserId)
                    await drawingViewModel.getMyDrawing(userId: authViewModel.currentUserId)
                    isReady = true
                }
        }
    }
}

#Preview {
    ContentView()
}
