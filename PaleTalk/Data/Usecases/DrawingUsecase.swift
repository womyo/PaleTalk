//
//  DrawingUsecase.swift
//  PaleTalk
//
//  Created by 이인호 on 7/20/25.
//

import Foundation

protocol DrawingUsecase: Sendable {
    func uploadImage(data: Data) async throws -> URL
    func deleteImage(imageUrl: String) async throws
    func saveDrawing(userId: String, imageUrl: String) throws -> Drawing
    func getTodayDrawings(userId: String) async throws -> [Drawing]
    func getMyDrawing(userId: String) async throws -> Drawing?
    func updateViews(userId: String, drawingId: String) async throws
    func deleteDrawing(userId: String, drawingId: String) async throws
    func reportDrawing(userId: String, drawingId: String, reason: String) async throws
    func toggleLike(userId: String, drawingId: String, isLiked: Bool) async throws
}
