//
//  DrawingRepository.swift
//  PaleTalk
//
//  Created by 이인호 on 7/20/25.
//

import Foundation
@preconcurrency import FirebaseStorage
@preconcurrency import FirebaseFirestore

final class DrawingRepository: DrawingUsecase {
    private let storage = Storage.storage()
    private let db = Firestore.firestore()
    
    // MARK: - 이미지 Storage
    func uploadImage(data: Data) async throws -> URL {
        let path = "drawings/\(UUID().uuidString).png"
        let fileRef = storage.reference().child(path)
        
        let metadata = try await fileRef.putDataAsync(data)
        return try await fileRef.downloadURL()
    }
    
    func deleteImage(imageUrl: String) async throws {
        let imageRef = storage.reference(forURL: imageUrl)
        
        try await imageRef.delete()
    }
    
    // MARK: - Write
    func saveDrawing(userId: String, imageUrl: String) throws -> Drawing {
        var drawing = Drawing(userId: userId, imageUrl: imageUrl)
        let ref = try db.collection("drawings").addDocument(from: drawing)
        drawing.id = ref.documentID
        
        return drawing
    }
    
    // MARK: - Read
    /// 24시간 이내 다른 유저들의 드로잉 조회
    func getTodayDrawings(userId: String) async throws -> [Drawing] {
        let querySnapshot = try await db.collection("drawings")
            .whereField("createdAt", isGreaterThan: Calendar.current.date(byAdding: .hour, value: -24, to: Date())!)
            .getDocuments()
        
        var todayDrawings = try querySnapshot.documents.map { document in
            return try document.data(as: Drawing.self)
        }
        
        todayDrawings = todayDrawings.filter { $0.userId != userId }
        
        return todayDrawings
    }
    
    /// 24시간 이내 내 드로잉 조회
    func getMyDrawing(userId: String) async throws -> Drawing? {
        let querySnapshot = try await db.collection("drawings")
            .whereField("userId", isEqualTo: userId)
            .whereField("createdAt", isGreaterThan: Calendar.current.date(byAdding: .hour, value: -24, to: Date())!)
            .limit(to: 1)
            .getDocuments()
        
        guard let document = querySnapshot.documents.first else {
            return nil
        }
        
        return try document.data(as: Drawing.self)
    }
    
    // MARK: - Update
    /// 뷰어(드로잉 본 유저) 정보 업데이트
    func updateViews(userId: String, drawingId: String) async throws {
        let drawingRef = db.collection("drawings").document(drawingId)
        
        try await drawingRef.updateData([
            "viewers": FieldValue.arrayUnion([userId])
        ])
    }
    
    // MARK: - Delete
    func deleteDrawing(userId: String, drawingId: String) async throws {
        let drawingRef = db.collection("drawings").document(drawingId)
        let querySnapshot = try await drawingRef.getDocument()
        
        if let userId = querySnapshot.data()?["userId"] as? String, userId == userId {
            try await drawingRef.delete()
        } else {
            print("삭제 권한이 없습니다: 해당 유저의 드로잉이 아님")
        }
    }
    
    func reportDrawing(userId: String, drawingId: String, reason: String) async throws {
        let drawingRef = db.collection("drawings").document(drawingId)
        
        try await drawingRef.updateData([
            "reports.\(userId)": "\(reason)"
        ])
    }
    
    func toggleLike(userId: String, drawingId: String, isLiked: Bool) async throws {
        let drawingRef = db.collection("drawings").document(drawingId)
        let querySnapshot = try await drawingRef.getDocument()
        
        if isLiked {
            try await drawingRef.updateData([
                "likes": FieldValue.arrayRemove([userId])
            ])
        } else {
            try await drawingRef.updateData([
                "likes": FieldValue.arrayUnion([userId])
            ])
        }
//        if let likes = querySnapshot.data()?["likes"] as? [String], likes.contains(userId) {
//            try await drawingRef.updateData([
//                "likes": FieldValue.arrayRemove([userId])
//            ])
//        } else {
//            try await drawingRef.updateData([
//                "likes": FieldValue.arrayUnion([userId])
//            ])
//        }
//        try await db.collection("drawings")
//            .document(drawingId)
//            .collection("interactions")
//            .document(userId)
//            .setData([
//                "like": true
//            ])
        
    }
}
