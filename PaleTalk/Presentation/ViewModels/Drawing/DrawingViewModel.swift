//
//  DrawingViewModel.swift
//  PaleTalk
//
//  Created by 이인호 on 7/20/25.
//

import Foundation
import SwiftUI
import FirebaseStorage
import PencilKit
import Kingfisher

@MainActor
final class DrawingViewModel: ObservableObject {
    var canvasView: PKCanvasView?
    var toolPicker: PKToolPicker?
    @Published var showStar = UUID()
    @Published var starAnimationCompleted = false
    @Published var drawingList: [Drawing] = []
    @Published var myDrawing: Drawing?
    @Published var selectedDrawing: Drawing = Drawing(userId: "", imageUrl: "")
    
    let fixedOffsets: [CGPoint] = [
        CGPoint(x: -120, y: -200), // 왼쪽 상단
        CGPoint(x: 80,   y: -180), // 오른쪽 상단
        CGPoint(x: -60,  y: -110),  // 왼쪽 중상단
        CGPoint(x: 140,  y: -130), // 오른쪽 중상단
    ]
    
    private let usecase: DrawingUsecase
    
    init(usecase: DrawingUsecase) {
        self.usecase = usecase
    }
    
    func saveDrawing(userId: String?, drawing: PKDrawing) async {
        let bounds = drawing.bounds
        let image = drawing.image(from: bounds, scale: UIScreen.main.scale)
        
        guard let imageData = image.pngData(), let userId = userId else { return }
        
        do {
            let url = try await usecase.imageUpload(data: imageData)
            try usecase.saveDrawing(userId: userId, imageUrl: url.absoluteString)
        } catch {
            print("드로잉 저장 중 에러: \(error)")
        }
    }
    
    func getTodayDrawings(userId: String?) async {
        guard let userId = userId else { return }
        
        do {
            drawingList = try await usecase.getTodayDrawings(userId: userId)
            prefetchImages()
//            print(drawingList)
        } catch {
            print("오늘 드로잉 리스트 조회 중 에러: \(error)")
        }
    }
    
    func getMyDrawing(userId: String?) async {
        guard let userId = userId else { return }
        
        do {
            myDrawing = try await usecase.getMyDrawing(userId: userId)
            print(myDrawing)
        } catch {
            print("유저 오늘 드로잉 조회 중 에러: \(error)")
        }
    }
    
    private func prefetchImages() {
        let urls = drawingList.map { URL(string: $0.imageUrl)! }
        
        let prefetcher = ImagePrefetcher(
            urls: urls,
            options: [.cacheMemoryOnly]
        )
        
        prefetcher.start()
    }
    
    func undo() {
        canvasView?.undoManager?.undo()
    }
    
    func redo() {
        canvasView?.undoManager?.redo()
    }
    
    func toggleToolPicker(show: Bool) {
        toolPicker?.setVisible(show, forFirstResponder: canvasView!)
        toolPicker?.addObserver(canvasView!)
        
        if show {
            canvasView?.becomeFirstResponder()
        }
    }
}
