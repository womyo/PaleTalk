//
//  RewardUsecase.swift
//  PaleTalk
//
//  Created by 이인호 on 10/1/25.
//

import Foundation

protocol RewardUsecase: Sendable {
    func saveRewards() throws
    func grantReward(userId: String, type: RewardType) async throws
    func getRewards(userId: String) async throws -> [Reward]
}
