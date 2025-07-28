//
//  AuthCryptoService.swift
//  PaleTalk
//
//  Created by 이인호 on 7/20/25.
//

import Foundation
import CryptoKit

class AuthCryptoService {
    
    // MARK: - 애플 로그인용 nonce 생성 및 SHA256 해시
    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 8, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError()
        }
        
        let charset: [Character] =  Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { charset[Int($0) % charset.count ]}
        
        return String(nonce)
    }
    
    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        
        return hashString
    }
}
