//
//  Drawing.swift
//  PaleTalk
//
//  Created by 이인호 on 7/20/25.
//

import Foundation
import FirebaseFirestore

// TODO: - report 후 filter
struct Drawing: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    let userId: String
    let imageUrl: String
    var viewers: [String]
    var likes: [String]
    var reports: [String: String]
    let createdAt: Date
    
    init(userId: String, imageUrl: String) {
        self.userId = userId
        self.imageUrl = imageUrl
        self.viewers = []
        self.likes = []
        self.reports = [:]
        self.createdAt = Date()
    }
}
