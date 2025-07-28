//
//  UserViewModel.swift
//  PaleTalk
//
//  Created by 이인호 on 7/28/25.
//

import Foundation
import Combine

@MainActor
final class UserViewModel: ObservableObject {
    private let usecase: UserUsecase
    @Published var selectedImageData: Data?
    @Published var nickname: String = ""
    @Published var isNicknameValid = false
    private var cancellable = Set<AnyCancellable>()
    
    init(usecase: UserUsecase) {
        self.usecase = usecase
        bind()
    }
    
    func bind() {
        $nickname
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .assign(to: \.isNicknameValid, on: self)
            .store(in: &cancellable)
    }
    
    func saveUser(userId: String) async {
        do {
            if let selectedImageData = selectedImageData {
                let url = try await usecase.uploadProfileImage(data: selectedImageData)
                try usecase.saveUser(userId: userId, profileImageUrl: url.absoluteString, nickname: nickname)
            } else {
                try usecase.saveUser(userId: userId, profileImageUrl: nil, nickname: nickname)
            }
        } catch {
            print("유저 저장 중 에러: \(error)")
        }
    }
}
