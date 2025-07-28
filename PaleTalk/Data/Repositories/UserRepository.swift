//
//  UserRepository.swift
//  PaleTalk
//
//  Created by 이인호 on 7/28/25.
//

import Foundation
@preconcurrency import FirebaseStorage
@preconcurrency import FirebaseFirestore

final class UserRepository: UserUsecase {
    private let storage = Storage.storage()
    private let db = Firestore.firestore()
    
    func uploadProfileImage(data: Data) async throws -> URL {
        let path = "profiles/\(UUID().uuidString).png"
        let fileRef = storage.reference().child(path)
        
        let metadata = try await fileRef.putDataAsync(data)
        return try await fileRef.downloadURL()
    }
    
    func saveUser(userId: String, profileImageUrl: String?, nickname: String) throws {
        let user = User(profileImageUrl: profileImageUrl, nickname: nickname)
        
        try db.collection("users").document(userId).setData(from: user)
    }
    
    func getUser(userId: String) async throws -> User? {
        let userRef = db.collection("users").document(userId)
        let querySnapshot = try await userRef.getDocument()
        
        return try querySnapshot.data(as: User.self)
    }
    
    func updateUser(userId: String, profileImageUrl: String?, nickname: String?) async throws {
        let userRef = db.collection("users").document(userId)
        
        if let profileImageUrl = profileImageUrl {
            try await userRef.setData(["profileImageUrl": profileImageUrl])
        }
        
        if let nickname = nickname {
            try await userRef.setData(["nickname": nickname])
        }
    }
    
    func deleteUser(userId: String) async throws {
        let userRef = db.collection("users").document(userId)
        
        try await userRef.delete()
    }
}
