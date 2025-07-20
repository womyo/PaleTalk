//
//  DrawingUsecase.swift
//  PaleTalk
//
//  Created by 이인호 on 7/20/25.
//

import Foundation

protocol DrawingUsecase: Sendable {
    func imageUpload(data: Data) async throws -> URL
    func saveDrawing(userId: String, imageUrl: String) throws
    func getTodayDrawings(userId: String) async throws -> [Drawing]
    func getMyDrawing(userId: String) async throws -> Drawing?
}
