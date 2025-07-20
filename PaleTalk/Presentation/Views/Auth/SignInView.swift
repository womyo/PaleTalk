//
//  SignInView.swift
//  PaleTalk
//
//  Created by 이인호 on 7/20/25.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            googleLogin
            appleLogin
        }
    }
    
    private var googleLogin: some View {
        Button {
            Task {
                do {
                    try await viewModel.googleSignIn()
                } catch {
                    print(error)
                }
            }
        } label: {
            Image(systemName: "g.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.bottom)
    }
    
    private var appleLogin: some View {
        Button {
            viewModel.appleSignIn()
        } label: {
            Image(systemName: "apple.logo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    SignInView()
}

