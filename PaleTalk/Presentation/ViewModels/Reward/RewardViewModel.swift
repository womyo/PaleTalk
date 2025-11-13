//
//  RewardViewModel.swift
//  PaleTalk
//
//  Created by 이인호 on 10/1/25.
//

import Foundation

@MainActor
final class RewardViewModel: ObservableObject {
    private let usecase: RewardUsecase
    @Published var rewards: [Reward] = []
    
    init(usecase: RewardUsecase) {
        self.usecase = usecase
    }
    
    func saveRewards() {
        do {
            try usecase.saveRewards()
        } catch {
            print("\(error)")
        }
    }
    
    func grantReward(userId: String, type: RewardType) async {
        do {
            try await usecase.grantReward(userId: userId, type: type)
        } catch {
            print("유저 리워드 업데이트 중 에러 \(error)")
        }
    }
    
    func getRewards(userId: String) async {
        do {
            rewards = try await usecase.getRewards(userId: userId)
        } catch {
            print("유저 리워드 fetch 중 에러: \(error)")
        }
    }
}
