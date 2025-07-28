//
//  UserUsecase.swift
//  PaleTalk
//
//  Created by 이인호 on 7/28/25.
//

import Foundation

protocol UserUsecase: Sendable {
    func uploadProfileImage(data: Data) async throws -> URL
    func saveUser(userId: String, profileImageUrl: String?, nickname: String) throws
    func getUser(userId: String) async throws -> User?
    func updateUser(userId: String, profileImageUrl: String?, nickname: String?) async throws
    func deleteUser(userId: String) async throws
}
