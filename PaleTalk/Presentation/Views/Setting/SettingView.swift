//
//  SettingView.swift
//  PaleTalk
//
//  Created by 이인호 on 7/20/25.
//

import SwiftUI
import Kingfisher

struct SettingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State var showLogoutAlert = false
    
    var body: some View {
        VStack {
            VStack {
                KFImage(URL(string: authViewModel.currentUser?.profileImageUrl ?? ""))
                    .loadDiskFileSynchronously(true)
                    .placeholder {
                        Image(systemName: "photo")
                    }
                    .cacheMemoryOnly()
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(Circle())
                
                Text(authViewModel.currentUser?.nickname ?? "")
            }
            
            Button {
                showLogoutAlert = true
            } label: {
                Text("로그아웃")
            }
            .alert("로그아웃 하시겠습니까?", isPresented: $showLogoutAlert) {
                Button("로그아웃") {
                    Task {
                        await authViewModel.signOut()
                    }
                }
                Button("취소", role: .cancel) {}
            }
        }
    }
}

#Preview {
    SettingView()
}
