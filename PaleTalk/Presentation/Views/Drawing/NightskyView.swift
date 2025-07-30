//
//  NightskyView.swift
//  PaleTalk
//
//  Created by 이인호 on 7/20/25.
//

import SwiftUI

struct StarAnimValues {
    var scale: CGFloat = 0.5
    var opacity: Double = 0
    var yOffset: CGFloat = 10
}

struct NightskyView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var drawingViewModel: DrawingViewModel
    @Binding var whichView: Bool
    @State var isSheetPresented: Bool = false
    @State var isInAnimation: Bool = false
    var pageIndex: Int
    
    var body: some View {
        let array = drawingViewModel.pagedDrawings.isEmpty ? [] : Array(drawingViewModel.pagedDrawings[pageIndex].enumerated())
        
        ZStack {
            ZStack {
                ForEach(array, id: \.element) { index, drawing in
                    let offset = drawingViewModel.fixedOffsets[index]
                    
                    Button {
                        isSheetPresented = true
                        drawingViewModel.selectedDrawing = drawing
                        
                        Task {
                            await drawingViewModel.updateViewers(userId: authViewModel.currentUserId, drawingId: drawing.id)
                            drawingViewModel.pagedDrawings[pageIndex][index].viewers.append(authViewModel.currentUserId)
                        }
                    } label: {
                        Image(drawingViewModel.planets[index])
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    }
                    .offset(x: offset.x, y: offset.y)
                }
                
                // 홈 화면 맨 처음일때만
                if pageIndex == 0 {
                    shootingStarView
                    
                    if let myDrawing = drawingViewModel.myDrawing, isInAnimation == false {
                        Button {
                            isSheetPresented = true
                            drawingViewModel.selectedDrawing = myDrawing
                            
                            Task {
                                await drawingViewModel.updateViewers(userId: authViewModel.currentUserId, drawingId: myDrawing.id)
                                drawingViewModel.myDrawing?.viewers.append(authViewModel.currentUserId)
                            }
                        } label: {
                            Image("Planet5")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        }
                        .offset(y: 0)
                    }
                }
            }
            
            VStack(alignment: .trailing) {
                Spacer()
                
                if pageIndex == 0 && isInAnimation == false && drawingViewModel.myDrawing == nil {
                    HStack {
                        Spacer()
                        Button {
                            whichView = false
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("그리기")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.7))
                            .padding()
                        }
                        .background(Color(.main))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding([.bottom, .trailing], 16)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $isSheetPresented) {
            DrawingImageView()
        }
    }
    
    private var shootingStarView: some View {
        Image("Planet5")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .keyframeAnimator(initialValue: StarAnimValues(), trigger: drawingViewModel.showStar) { content, value in
                content
                    .scaleEffect(value.scale)
                    .opacity(value.opacity)
                    .offset(y: value.yOffset)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    LinearKeyframe(0.5, duration: 0.1)
                    SpringKeyframe(0.8, duration: 2.0, spring: .bouncy)
                    SpringKeyframe(1.2, duration: 0.5, spring: .bouncy)
                    SpringKeyframe(1.0, duration: 0.3, spring: .bouncy)
                }
                KeyframeTrack(\.opacity) {
                    LinearKeyframe(0.0, duration: 0.1)
                    LinearKeyframe(1.0, duration: 0.7)
                    LinearKeyframe(1.0, duration: 2.0)
                }
                KeyframeTrack(\.yOffset) {
                    LinearKeyframe(300, duration: 0.1)
                    LinearKeyframe(150, duration: 1.8)
                    SpringKeyframe(0, duration: 1.0)
                }
            }
            .onChange(of: drawingViewModel.showStar) {
                isInAnimation = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                    isInAnimation = false
                }
            }
    }
}

//#Preview {
//    NightskyView()
//}
