//
//  RewardRepository.swift
//  PaleTalk
//
//  Created by 이인호 on 10/1/25.
//

import Foundation
@preconcurrency import FirebaseFirestore

final class RewardRepository: RewardUsecase {
    private let db = Firestore.firestore()
    
    func saveRewards() throws {
        for reward in Reward.rewards {
            try db.collection("rewards")
                .document(reward.type.rawValue)
                .setData(from: reward)
        }
    }
    
    func getReward(id: String) async throws -> Reward {
        let reward = try await db.collection("rewards")
            .document(id)
            .getDocument(as: Reward.self)
        
        return reward
    }
    
    func grantReward(userId: String, type: RewardType) async throws {
        let rewardId = type.rawValue
        
        let earnedRewards = db.collection("users").document(userId)
            .collection("earnedRewards").document(rewardId)
        
        let rewardRef = db.collection("rewards").document(rewardId)
        
        let rewardData: [String: Any] = [
            "reward": rewardRef,
            "earnedAt": Date()
        ]
        
        try await earnedRewards.setData(rewardData)
    }
    
    func getRewards(userId: String) async throws -> [Reward] {
        let snapshot = try await db.collection("users").document(userId)
            .collection("earnedRewards")
            .getDocuments()
        
        let rewards = try await withThrowingTaskGroup(of: Reward.self) { group in
            var fetchedRewards: [Reward] = []
            
            for document in snapshot.documents {
                guard let rewardRef = document.get("reward") as? DocumentReference else { continue }
                
                group.addTask {
                    return try await rewardRef.getDocument(as: Reward.self)
                }
            }
            
            for try await reward in group {
                fetchedRewards.append(reward)
            }
            
            return fetchedRewards
        }
    
        return rewards
    }
}
