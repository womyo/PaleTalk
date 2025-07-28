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
    private let usecase: DrawingUsecase
    
    @Published var showStar = UUID() // Shooting Star Trigger
    @Published var starAnimationCompleted = false
    
    @Published var drawings: [Drawing] = [] // 다른 유저들의 드로잉
    @Published var pagedDrawings: [[Drawing]] = []
    
    @Published var myDrawing: Drawing?
    @Published var selectedDrawing: Drawing = Drawing(userId: "", imageUrl: "")
    
    var topic: String = "없음"
    
    /// 각 별의 고정 위치 좌표
    let fixedOffsets: [CGPoint] = [
        CGPoint(x: -120, y: -120),
        CGPoint(x: 80,   y: -200),
        CGPoint(x: -60,  y: 100),
        CGPoint(x: 140,  y: 130),
        CGPoint(x: 0,  y: 0),
    ]
    
    init(usecase: DrawingUsecase) {
        self.usecase = usecase
    }
    
    // MARK: - FireStore
    func saveDrawing(userId: String, drawing: PKDrawing) async {
        let bounds = drawing.bounds
        let image = drawing.image(from: bounds, scale: UIScreen.main.scale)
        
        guard let imageData = image.pngData() else { return }
        
        do {
            let url = try await usecase.uploadImage(data: imageData)
            myDrawing =  try usecase.saveDrawing(userId: userId, imageUrl: url.absoluteString)
        } catch {
            print("드로잉 저장 중 에러: \(error)")
        }
    }
    
    func getTodayDrawings(userId: String) async {
        do {
            drawings = try await usecase.getTodayDrawings(userId: userId)
            prefetchImages()
            paginateDrawings()
//            print(pagedDrawings)
        } catch {
            print("오늘 드로잉 리스트 조회 중 에러: \(error)")
        }
    }
    
    private func paginateDrawings() {
        var start = 0
        var arraySize = 4
        
        while start < drawings.count {
            let end = min(start + arraySize, drawings.count)
            pagedDrawings.append(Array(drawings[start..<end]))
            
            start = end
            arraySize = 5
        }
    }
    
    func getMyDrawing(userId: String) async {
        do {
            myDrawing = try await usecase.getMyDrawing(userId: userId)
            
            if let myDrawing = myDrawing {
                let prefetcher = ImagePrefetcher(
                    urls: [URL(string: myDrawing.imageUrl)!],
                    options: [.cacheMemoryOnly]
                )
                
                prefetcher.start()
            }
//            print(myDrawing)
        } catch {
            print("유저 오늘 드로잉 조회 중 에러: \(error)")
        }
    }
    
    func updateViewers(userId: String, drawingId: String?) async {
        guard let drawingId = drawingId else { return }
        
        do {
            try await usecase.updateViews(userId: userId, drawingId: drawingId)
        } catch {
            print("드로잉 뷰어 업데이트 중 에러: \(error)")
        }
    }
    
    func deleteDrawing(userId: String) async {
        guard let drawingId = selectedDrawing.id else { return }
        
        do {
            try await usecase.deleteDrawing(userId: userId, drawingId: drawingId)
            myDrawing = nil
            
            do {
                try await usecase.deleteImage(imageUrl: selectedDrawing.imageUrl)
            } catch {
                print("스토리지에서 이미지 삭제 중 에러: \(error)")
                // 로그 남기기 필요
            }
        } catch {
            print("드로잉 삭제 중 에러: \(error)")
        }
    }
    
    func reportDrawing(userId: String, reason: String) async {
        guard let drawingId = selectedDrawing.id else { return }
        
        do {
            try await usecase.reportDrawing(userId: userId, drawingId: drawingId, reason: reason)
        } catch {
            print("드로잉 신고 중 에러: \(error)")
        }
    }
    
    func toggleLike(userId: String) async {
        guard let drawingId = selectedDrawing.id,
              let (pageIndex, drawingIndex) = pagedDrawings
                  .enumerated()
                  .compactMap({ (pageIdx, drawings) in
                      if let innerIdx = drawings.firstIndex(where: { $0.id == drawingId }) {
                          return (pageIdx, innerIdx)
                      }
                      return nil
                  })
                  .first
        else { return }
    
        do {
            var drawing = pagedDrawings[pageIndex][drawingIndex]
            var isLiked = false
            
            if drawing.likes.contains(userId) {
                drawing.likes.remove(at: drawing.likes.firstIndex(of: userId)!)
                isLiked = true
            } else {
                drawing.likes.append(userId)
            }
            
            pagedDrawings[pageIndex][drawingIndex] = drawing
            selectedDrawing = drawing
            
            try await usecase.toggleLike(userId: userId, drawingId: drawingId, isLiked: isLiked)
        } catch {
            print("드로잉 좋아요 토클 중 에러: \(error)")
        }
    }
    
    // MARK: - KingFisher
    /// 이미지 로딩 지연 최소화를 위한 프리페치
    private func prefetchImages() {
        let urls = drawings.map { URL(string: $0.imageUrl)! }
        
        let prefetcher = ImagePrefetcher(
            urls: urls,
            options: [.cacheMemoryOnly]
        )
        
        prefetcher.start()
    }
    
    // MARK: - PencilKit
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
