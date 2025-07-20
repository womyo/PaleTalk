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
    
    func imageUpload(data: Data) async throws -> URL {
        let path = "images/\(UUID().uuidString).png"
        let fileRef = storage.reference().child(path)
        
        let metadata = try await fileRef.putDataAsync(data)
        return try await fileRef.downloadURL()
    }
    
    func saveDrawing(userId: String, imageUrl: String) throws {
        let drawing = Drawing(userId: userId, imageUrl: imageUrl)
        
        try db.collection("Drawings")
            .addDocument(from: drawing) { error in
                if let error = error {
                    print("Error when add document: \(error)")
                    return
                }
            }
    }
    
    func getTodayDrawings(userId: String) async throws -> [Drawing] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let querySnapshot = try await db.collection("Drawings")
            .whereField("createdAt", isGreaterThan: today)
            .whereField("createdAt", isLessThan: tomorrow)
            .getDocuments()
        
        var todayDrawings = try querySnapshot.documents.map { document in
            return try document.data(as: Drawing.self)
        }
        
        todayDrawings = todayDrawings.filter { $0.userId != userId }
        
        return todayDrawings
    }
    
    func getMyDrawing(userId: String) async throws -> Drawing? {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let querySnapshot = try await db.collection("Drawings")
            .whereField("userId", isEqualTo: userId)
            .whereField("createdAt", isGreaterThan: today)
            .whereField("createdAt", isLessThan: tomorrow)
            .limit(to: 1)
            .getDocuments()
        
        guard let document = querySnapshot.documents.first else {
            return nil
        }
        
        return try document.data(as: Drawing.self)
    }
}
