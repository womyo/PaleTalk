//
//  PaletteView.swift
//  PaleTalk
//
//  Created by 이인호 on 7/20/25.
//

import SwiftUI
import PencilKit

struct PaletteView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var drawingViewModel: DrawingViewModel
    @Environment(\.dismiss) var dismiss
    
    // MARK: - View State
    @State private var drawing = PKDrawing()
    @State private var toolBarShows = false
    @State private var isCanvasEmpty = true
    @State private var visible = true
    @State private var canUndo = false
    @State private var canRedo = false
    @State private var isFadingOut = false
    @State private var isLoading = false
    @State private var animate = false
    @Binding var whichView: Bool
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                DrawingCanvasView(
                    viewModel: drawingViewModel,
                    drawing: $drawing,
                    toolPickerShows: $toolBarShows,
                    onDrawingChanged: { canvasView in
                    DispatchQueue.main.async {
                        if isCanvasEmpty && !canvasView.drawing.strokes.isEmpty {
                            isCanvasEmpty = false
                        }
                        canUndo = canvasView.undoManager?.canUndo ?? false
                        canRedo = canvasView.undoManager?.canRedo ?? false
                    }
                })
            
                dailyTopic
//                DailyTopicView(visible: $visible, topic: "없음!")
                
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        Spacer()
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    toolBarShows = true
                    drawingViewModel.toggleToolPicker(show: toolBarShows)
                }
            }
            .toolbar {
                // MARK: - Back Button
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        drawingViewModel.toggleToolPicker(show: false)
                        whichView = true
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                }
                
                // MARK: - PencilKit Options
                if (!isCanvasEmpty) {
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack {
                            Button {
                                drawingViewModel.undo()
                            } label: {
                                Image(systemName: "arrow.uturn.backward.circle")
                            }
                            .disabled(canUndo ? false : true)
                            
                            Button {
                                drawingViewModel.redo()
                            } label: {
                                Image(systemName: "arrow.uturn.forward.circle")
                            }
                            .disabled(canRedo ? false : true)
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu(content: {
                        Button {
                            toolBarShows.toggle()
                            drawingViewModel.toggleToolPicker(show: toolBarShows)
                        } label: {
                            HStack {
                                Text("도구 켜기/끄기")
                                Image(systemName: "pencil.tip")
                            }
                        }
                    }, label: {
                        Image(systemName: "ellipsis.circle")
                    })
                }
                
                // MARK: - 드로잉 저장
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            // progressview로 저장중..
                            await drawingViewModel.saveDrawing(userId: authViewModel.currentUserId, drawing: drawing)
                        }
                        
                        isLoading = true
                        Task {
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            isLoading = false
                            
                            isFadingOut = true
                            toolBarShows = false
                            drawingViewModel.toggleToolPicker(show: toolBarShows)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                whichView = true

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                    drawingViewModel.showStar = UUID()
                                }
                            }
                        }
                    } label: {
                        Text("저장")
                    }
                }
            }
        }
        .opacity(isFadingOut ? 0 : 1)
        .scaleEffect(isFadingOut ? 0.7 : 1)
        .animation(.easeInOut(duration: 0.5), value: isFadingOut)
    }
    
    private var dailyTopic: some View {
        ZStack {
            if visible {
                Text("오늘의 주제: \(drawingViewModel.topic)")
                    .font(.subheadline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(14)
                    .shadow(radius: 6)
                    .opacity(animate ? 1 : 0)
                    .task {
                        withAnimation(.easeInOut(duration: 2.0)) {
                            animate = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            withAnimation(.easeInOut(duration: 2.0)) {
                                visible = false
                            }
                        }
                    }
            }
        }
    }
}
