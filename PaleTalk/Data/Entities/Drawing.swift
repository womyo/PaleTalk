//
//  Drawing.swift
//  PaleTalk
//
//  Created by 이인호 on 7/20/25.
//

import Foundation

struct Drawing: Codable, Identifiable, Hashable {
    let id: String
    let userId: String
    let imageUrl: String
    let createdAt: Date
    
    init(userId: String, imageUrl: String) {
        self.id = UUID().uuidString
        self.userId = userId
        self.imageUrl = imageUrl
        self.createdAt = Date()
    }
}
