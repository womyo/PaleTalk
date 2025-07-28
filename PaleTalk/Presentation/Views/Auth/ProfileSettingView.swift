//
//  ProfileSettingView.swift
//  PaleTalk
//
//  Created by 이인호 on 7/28/25.
//

import SwiftUI
import PhotosUI

struct ProfileSettingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var userViewModel = UserViewModel(usecase: UserRepository())
    @State var selectedPhotos: [PhotosPickerItem] = []
    @State var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Spacer()
            
            PhotosPicker(
                selection: $selectedPhotos,
                maxSelectionCount: 1,
                matching: .images
            ) {
                ZStack(alignment: .bottomTrailing) {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .padding(6)
                        .frame(width: 20, height: 20)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                        .offset(x: -5, y: -2)
                }
            }
            .onChange(of: selectedPhotos) { _, newValue in
                if let firstItem = newValue.first {
                    firstItem.loadTransferable(type: Data.self) { result in
                        switch result {
                        case .success(let data):
                            if let data = data, let newImage = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    selectedImage = newImage
                                    userViewModel.selectedImageData = data
                                }
                            }
                        case .failure:
                            print("Error")
                        }
                    }
                    
                    selectedPhotos.removeAll()
                }
            }
            .padding(.bottom)
            
            Text("별을 그리는 공간에 오신걸 환영해요")
                .font(.system(size: 24))
                .fontWeight(.semibold)
            
            Text("그림을 남기기 전에 나를 소개해봐요")
                .font(.system(size: 16))
                .foregroundStyle(Color.gray)
                .padding(.bottom, 48)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("닉네임")
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
                
                TextField("닉네임을 입력해주세요", text: $userViewModel.nickname)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
//                if !userViewModel.isNicknameValid {
//                    Text("닉네임을 입력해주세요.")
//                        .foregroundStyle(.red)
//                        .font(.system(size: 12))
//                        .multilineTextAlignment(.leading)
//                }
            }
            .padding()
            
            Spacer()
            
            Button {
                Task {
                    await userViewModel.saveUser(userId: authViewModel.currentUserId)
                    
                    switch authViewModel.platform {
                    case .apple:
                        authViewModel.loginStatus = .appleSignedIn
                    case .google:
                        authViewModel.loginStatus = .googleSignedIn
                    }
                    
                    dismiss()
                }
            } label: {
                // 버튼은 label에 준 영역만 tappable함. 따라서 frame을 Text에다 줌
                Text("계속하기")
                    .frame(maxWidth: .infinity)
                    .padding() // 안쪽 패딩(margin)
                    .foregroundStyle(.white)
                    .background(.purple)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding() // 바깥쪽 패딩
            }
            .buttonStyle(PlainButtonStyle()) // 기본은 automatic으로 opacity, scale효과가 주어짐
            .disabled(!userViewModel.isNicknameValid)
        }
    }
}

#Preview {
    ProfileSettingView()
}
