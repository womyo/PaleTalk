//
//  SettingView.swift
//  PaleTalk
//
//  Created by 이인호 on 7/20/25.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State var showLogoutAlert = false
    
    var body: some View {
        Button {
            showLogoutAlert = true
        } label: {
            Text("로그아웃")
        }
        .alert("로그아웃 하시겠습니까?", isPresented: $showLogoutAlert) {
            Button("로그아웃") {
                Task {
                    try await authViewModel.signOut()
                }
            }
            Button("취소", role: .cancel) {}
        }
    }
}

#Preview {
    SettingView()
}
