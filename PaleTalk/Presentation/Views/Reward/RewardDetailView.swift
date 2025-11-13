//
//  RewardDetailView.swift
//  PaleTalk
//
//  Created by 이인호 on 10/29/25.
//

import SwiftUI

struct RewardDetailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var rewardViewModel: RewardViewModel
    @Binding var reward: Reward
    @Binding var isMainReward: Bool
    @Binding var theme: Theme
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "\(reward.imageName)")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .padding()
                .foregroundStyle(Color.reward)
                .background(Color.complementary)
                .clipShape(Circle())
            
            Text("\(reward.name)")
                .font(.pretendardBold(size: 16))
                .foregroundStyle(Color.text)
            
            Text("\(reward.description)")
                .font(.pretendardRegular(size: 14))
                .foregroundStyle(Color.text)
            
            Spacer()
            
            if reward != authViewModel.mainReward || isMainReward {
                Button {
                    if isMainReward {
                        Task {
                            await authViewModel.updateMainReward(userId: authViewModel.currentUserId, reward: nil)
                            dismiss()
                        }
                    } else {
                        Task {
                            await authViewModel.updateMainReward(userId: authViewModel.currentUserId, reward: reward)
                            dismiss()
                        }
                    }
                } label: {
                    Text(isMainReward ? "메인 리워드 설정 해제하기" : "변경하기")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Color.text)
                        .background(theme.subColor)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding()
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}
