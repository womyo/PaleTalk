//
//  DrawingImageView.swift
//  PaleTalk
//
//  Created by 이인호 on 7/20/25.
//

import SwiftUI
import Kingfisher

struct DrawingImageView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var drawingViewModel: DrawingViewModel
    @Environment(\.dismiss) var dismiss
    @State private var isShowDialog = false
    
    var body: some View {
        NavigationStack {
            VStack {
                KFImage(URL(string: drawingViewModel.selectedDrawing.imageUrl))
                    .loadDiskFileSynchronously(true)
                    .cacheMemoryOnly()
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: .infinity)
                    .background(
                        Image("Sketchbook")
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                    )
                
                Color.white
                    .frame(height: 40)
                    .overlay(
                        Button {
                            Task {
                                await drawingViewModel.toggleLike(userId: authViewModel.currentUserId)
                            }
                        } label: {
                            Image(
                                systemName: drawingViewModel.selectedDrawing.likes.contains(authViewModel.currentUserId) ? "hands.and.sparkles.fill" : "hands.and.sparkles"
                            )
                                .resizable()
                                .scaledToFit()
                                .opacity(drawingViewModel.selectedDrawing.userId != authViewModel.currentUserId ? 1 : 0)
                                .padding(.vertical, 8)
                                .padding(.trailing, 12)
                        },
                        alignment: .bottomTrailing
                    )
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button {
                            isShowDialog = true
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                        .confirmationDialog("", isPresented: $isShowDialog, actions: {
                            if authViewModel.currentUserId == drawingViewModel.selectedDrawing.userId {
                                Button("삭제") {
                                    Task {
                                        await drawingViewModel.deleteDrawing(userId: authViewModel.currentUserId)
                                        dismiss()
                                    }
                                }
                            } else {
                                Button("신고", role: .destructive) {
                                    Task {
                                        await drawingViewModel.reportDrawing(userId: authViewModel.currentUserId, reason: "아무이유")
                                        dismiss()
                                    }
                                }
                            }
                            
                            Button("취소", role: .cancel) {
                                isShowDialog = false
                            }
                        })
                        
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    DrawingImageView()
}
