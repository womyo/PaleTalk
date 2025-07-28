//
//  User.swift
//  PaleTalk
//
//  Created by 이인호 on 7/28/25.
//

import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    let profileImageUrl: String?
    let nickname: String
}
