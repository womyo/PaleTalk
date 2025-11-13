//
//  Reward.swift
//  PaleTalk
//
//  Created by 이인호 on 10/1/25.
//

import Foundation
import FirebaseFirestore

enum RewardType: String, CaseIterable, Codable {
    case firstDrawing
    case sevenDayStreak
    case shareFirstArt
    case hundredthDrawing
}

struct Reward: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    let type: RewardType
    let name: String
    let description: String
    let imageName: String
    
    static let rewards: [Reward] = [
        // 리워드 9개로 늘리기
        Reward(
            id: RewardType.firstDrawing.rawValue,
            type: .firstDrawing,
            name: "위대한 첫걸음",
            description: "첫 번째 그림을 완성하여 드로잉 여정을 시작했습니다.",
            imageName: "sparkles"
        ),
        Reward(
            id: RewardType.sevenDayStreak.rawValue,
            type: .sevenDayStreak,
            name: "꾸준함의 증표",
            description: "일주일 동안 매일 그림을 그리는 습관을 들였습니다.",
            imageName: "flame.fill"
        ),
        Reward(
            id: RewardType.shareFirstArt.rawValue,
            type: .shareFirstArt,
            name: "세상에 알리기",
            description: "자신의 작품을 처음으로 다른 사람에게 공유했습니다.",
            imageName: "square.and.arrow.up.fill"
        ),
        Reward(
            id: RewardType.hundredthDrawing.rawValue,
            type: .hundredthDrawing,
            name: "드로잉 장인",
            description: "100번째 작품을 완성하며 실력을 증명했습니다.",
            imageName: "crown.fill"
        )
    ]
}
