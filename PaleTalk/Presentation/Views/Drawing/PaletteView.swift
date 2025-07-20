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
    
    @State private var drawing = PKDrawing()
    @State private var toolBarShows = false
    @State private var isCanvasEmpty = true
    @State private var visible = true
    @State private var canUndo = false
    @State private var canRedo = false
    @State private var isFadingOut = false
    @Binding var whichView: Bool
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                DrawingCanvasView(
                    drawing: $drawing,
                    toolPickerShows: $toolBarShows,
                    viewModel: drawingViewModel,
                    onDrawingChanged: { canvasView in
                    DispatchQueue.main.async {
                        if isCanvasEmpty && !canvasView.drawing.strokes.isEmpty {
                            isCanvasEmpty = false
                        }
                        canUndo = canvasView.undoManager?.canUndo ?? false
                        canRedo = canvasView.undoManager?.canRedo ?? false
                    }
                })
            
                DailyTopicView(visible: $visible, topic: "없음!")
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    toolBarShows = true
                    drawingViewModel.toggleToolPicker(show: toolBarShows)
                }
            }
            .toolbar {
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
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            // progressview로 저장중..
//                            await drawingViewModel.saveDrawing(userId: authViewModel.currentUser?.uid, drawing: drawing)
//                            await drawingViewModel.getMyDrawing(userId: authViewModel.currentUser?.uid)
                        }
                        
                        isFadingOut = true
                        toolBarShows = false
                        drawingViewModel.toggleToolPicker(show: toolBarShows)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            whichView = true

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                drawingViewModel.showStar = UUID()
                            }
                        }
                    } label: {
                        Text("저장")
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        drawingViewModel.toggleToolPicker(show: false)
                        whichView = true
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                }
            }
        }
        .opacity(isFadingOut ? 0 : 1)
        .scaleEffect(isFadingOut ? 0.7 : 1)
        .animation(.easeInOut(duration: 0.5), value: isFadingOut)
    }
}
