//
//  AuthViewModel.swift
//  PaleTalk
//
//  Created by 이인호 on 7/20/25.
//

import AuthenticationServices
import FirebaseCore
@preconcurrency import FirebaseAuth
@preconcurrency import GoogleSignIn

enum LoginStatus {
    case googleSignedIn
    case appleSignedIn
    case signedOut
    case initializing
}

@MainActor
final class AuthViewModel: NSObject, ObservableObject, ASAuthorizationControllerDelegate {
    fileprivate var currentNonce: String?
    @Published var loginStatus: LoginStatus = .initializing
    
    var currentUser: User? {
        Auth.auth().currentUser
    }
    
    func googleSignIn() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        let googleSignIn = GIDSignIn.sharedInstance
        var googleUser: GIDGoogleUser
        
        
//        if googleSignIn.hasPreviousSignIn() {
//            googleUser = try await googleSignIn.restorePreviousSignIn()
//        } else {
//            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
//            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
//
//            let result = try await googleSignIn.signIn(withPresenting: rootViewController)
//            googleUser = result.user
//        }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let rootViewController = windowScene.windows.first?.rootViewController else { return }

        let result = try await googleSignIn.signIn(withPresenting: rootViewController)
        googleUser = result.user
        
        guard let idToken = googleUser.idToken else { return }
        let accessToken = googleUser.accessToken
        let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                       accessToken: accessToken.tokenString)
        
        try await authenticateWithFirebase(credential: credential)
        
        loginStatus = .googleSignedIn
    }
    
    private func googleSignOut() {
        GIDSignIn.sharedInstance.signOut()
    }
    
    func appleSignIn() {
        let nonce = AuthCryptoService.randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = AuthCryptoService.sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    func signOut() async throws {
        do {
            try Auth.auth().signOut()
            loginStatus = .signedOut
        } catch {
            print("Error when signing out")
        }
    }
    
    private func authenticateWithFirebase(credential: AuthCredential) async throws {
        try await Auth.auth().signIn(with: credential)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: appleIDCredential.fullName)
            
            Task {
                do {
                    try await authenticateWithFirebase(credential: credential)
                    loginStatus = .appleSignedIn
                } catch {
                    print(error.localizedDescription)
                }
            }
//            Auth.auth().signIn(with: credential) { (authResult, error) in
//                if let error = error {
//                    print(error.localizedDescription)
//                    return
//                }
//            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
    }
    
    func restore() {
        if let user = Auth.auth().currentUser {
            loginStatus = .appleSignedIn
        } else {
            loginStatus = .signedOut
        }
    }
}

