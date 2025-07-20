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
    @EnvironmentObject var drawingViewModel: DrawingViewModel
    @State private var selection = 0
    @State private var isReady = false
    
    init() {
        let appearence = UITabBarAppearance()
        appearence.configureWithOpaqueBackground()
        appearence.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        
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
                    await drawingViewModel.getTodayDrawings(userId: authViewModel.currentUser?.uid)
                    await drawingViewModel.getMyDrawing(userId: authViewModel.currentUser?.uid)
                    isReady = true
                }
        }
    }
}

#Preview {
    ContentView()
}

