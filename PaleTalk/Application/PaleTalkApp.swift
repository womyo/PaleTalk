//
//  PaleTalkApp.swift
//  PaleTalk
//
//  Created by 이인호 on 7/20/25.
//

import SwiftUI

@main
struct PaleTalkApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel = AuthViewModel(usecase: UserRepository())
    @StateObject var drawingViewModel = DrawingViewModel(usecase: DrawingRepository())
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(drawingViewModel)
                .task {
                    authViewModel.restore()
                }
        }
    }
}
