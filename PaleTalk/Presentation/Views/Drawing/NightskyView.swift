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
    @EnvironmentObject var drawingViewModel: DrawingViewModel
    @Binding var whichView: Bool
    @State var isSheetPresented: Bool = false
    
    var body: some View {
        VStack {
            ZStack {
                ForEach(Array(drawingViewModel.drawingList.enumerated()), id: \.element) { index, drawing in
                    let offset = drawingViewModel.fixedOffsets[index]
                    
                    Button {
                        isSheetPresented = true
                        drawingViewModel.selectedDrawing = drawing
                    } label: {
                        Image("Star")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }
                    .offset(x: offset.x, y: offset.y)
                }
                
                ShootingStarView()
                
                if let myDrawing = drawingViewModel.myDrawing {
                    Button {
                        isSheetPresented = true
                        drawingViewModel.selectedDrawing = myDrawing
                    } label: {
                        Image("Star")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }
                    .offset(y: -300)
                }
            }
            
            Button {
                whichView = false
            } label: {
                Text("이동")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Image("Home")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
//        .onAppear {
//            Task {
//                await drawingViewModel.getTodayDrawings()
//            }
//        }
        .sheet(isPresented: $isSheetPresented) {
            DrawingImageView()
        }
    }
}

struct ShootingStarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var drawingViewModel: DrawingViewModel
    
    var body: some View {
        Image("Star")
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
            .foregroundStyle(.yellow)
            .keyframeAnimator(initialValue: StarAnimValues(), trigger: drawingViewModel.showStar) { content, value in
                content
                    .scaleEffect(value.scale)
                    .opacity(value.opacity)
                    .offset(y: value.yOffset)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    LinearKeyframe(0.5, duration: 0.1)
                    SpringKeyframe(1.0, duration: 2.4, spring: .bouncy)
                    SpringKeyframe(2.0, duration: 0.5, spring: .bouncy)
                    SpringKeyframe(1.0, duration: 0.3, spring: .bouncy)
                }
                KeyframeTrack(\.opacity) {
                    LinearKeyframe(0.0, duration: 0.0)
                    LinearKeyframe(1.0, duration: 0.8)
                }
                KeyframeTrack(\.yOffset) {
                    LinearKeyframe(0, duration: 0.0)
                    LinearKeyframe(-150, duration: 2.0)
                    SpringKeyframe(-300, duration: 1.0)
                }
            }
//            .onChange(of: drawingViewModel.showStar) {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
//                    Task {
//                        await drawingViewModel.getMyDrawing(userId: authViewModel.currentUser?.uid)
//                    }
//                }
//            }
    }
}

//#Preview {
//    NightskyView()
//}

