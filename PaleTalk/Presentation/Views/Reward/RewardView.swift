//
//  RewardView.swift
//  PaleTalk
//
//  Created by 이인호 on 10/20/25.
//

import SwiftUI

struct RewardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var rewardViewModel: RewardViewModel
    @State var selectedReward: Reward = Reward(id: "", type: .firstDrawing, name: "", description: "", imageName: "")
    @State private var isPresented = false
    @State private var isMainReward = false
    @Binding var theme: Theme
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ScrollView {
            if let mainReward = authViewModel.mainReward {
                VStack(spacing: 16) {
                    Image(systemName: "\(mainReward.imageName)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding()
                        .foregroundStyle(Color.reward)
                        .background(Color.complementary)
                        .clipShape(Circle())
                    
                    Text("\(mainReward.name)")
                        .font(.nanumPenScriptRegular(size: 24))
                        .foregroundStyle(Color.text)
                }
                .onTapGesture {
                    isPresented = true
                    isMainReward = true
                    selectedReward = mainReward
                }
                
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "lock.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding()
                        .foregroundStyle(Color.gray)
                        .background(Color.complementary)
                        .clipShape(Circle())
                    
                    Text("아직 메인 리워드를 설정하지 않았어요")
                        .font(.nanumPenScriptRegular(size: 24))
                        .foregroundStyle(Color.text)
                }
            }
            
            Rectangle()
                .foregroundStyle(Color.border)
                .frame(height: 2)
                .padding(.vertical, 16)
            
            LazyVGrid(columns: columns, spacing: 36) {
                ForEach(Reward.rewards, id: \.self) { reward in
                    let isEarned = rewardViewModel.rewards.contains(reward)
                    
                    VStack(spacing: 16) {
                        Image(systemName: "\(reward.imageName)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .padding()
                            .foregroundStyle(isEarned ? Color.reward : Color.gray)
                            .background(Color.complementary)
                            .clipShape(Circle())
                        
                        Text("\(reward.name)")
                            .font(.pretendardRegular(size: 14))
                            .foregroundStyle(Color.text)
                    }
                    .onTapGesture {
                        if isEarned {
                            isPresented = true
                            isMainReward = false
                            selectedReward = reward
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isPresented) {
            RewardDetailView(rewardViewModel: rewardViewModel, reward: $selectedReward, isMainReward: $isMainReward, theme: $theme)
                .presentationDragIndicator(.hidden) // default
                .presentationDetents([.fraction(0.4)])
        }
        .navigationTitle("활동 리워드")
        .background(theme.mainColor)
    }
}

#Preview {
    RewardView(rewardViewModel: RewardViewModel(usecase: RewardRepository()), theme: .constant(.summer))
}
