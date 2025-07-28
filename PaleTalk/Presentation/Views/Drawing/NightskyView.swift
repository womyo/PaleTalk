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
    @State var isInAnimation: Bool? = nil
    var pageIndex: Int
    
    var body: some View {
        let array = drawingViewModel.pagedDrawings.isEmpty ? [] : Array(drawingViewModel.pagedDrawings[pageIndex].enumerated())
        let planets = ["Planet1", "Planet2", "Planet3", "Planet4", "Planet5"]
        
        VStack {
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
                        Image(planets[index])
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    }
                    .offset(x: offset.x, y: offset.y)
                }
                
                // 홈 화면 맨 처음일때만
                if pageIndex == 0 {
                    shootingStarView
                    
                    if let myDrawing = drawingViewModel.myDrawing, (isInAnimation == nil || isInAnimation == false) {
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
            
            if pageIndex == 0 && isInAnimation == nil && drawingViewModel.myDrawing == nil {
                Button {
                    whichView = false
                } label: {
                    Text("이동")
                }
            }
        }
//        .onAppear {
//            Task {
//                await drawingViewModel.getTodayDrawings()
//            }
//        }
        .fullScreenCover(isPresented: $isSheetPresented) {
            DrawingImageView()
        }
    }
    
    private var shootingStarView: some View {
        Image("Planet5")
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
            .keyframeAnimator(initialValue: StarAnimValues(), trigger: drawingViewModel.showStar) { content, value in
                content
                    .scaleEffect(value.scale)
                    .opacity(value.opacity)
                    .offset(y: value.yOffset)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    LinearKeyframe(0.5, duration: 0.1)
                    SpringKeyframe(1.0, duration: 2.0, spring: .bouncy)
                    SpringKeyframe(2.0, duration: 0.6, spring: .bouncy)
                    SpringKeyframe(1.0, duration: 0.3, spring: .bouncy)
                }
                KeyframeTrack(\.opacity) {
                    LinearKeyframe(0.0, duration: 0.1)
                    LinearKeyframe(1.0, duration: 0.8)
                    LinearKeyframe(1.0, duration: 2.0)
                    LinearKeyframe(0.0, duration: 0.1)
                }
                KeyframeTrack(\.yOffset) {
                    LinearKeyframe(0, duration: 0.1)
                    LinearKeyframe(-150, duration: 1.9)
                    SpringKeyframe(-300, duration: 1.0)
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
