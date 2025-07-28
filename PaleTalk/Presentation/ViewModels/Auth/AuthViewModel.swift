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
import Kingfisher

// MARK: - 로그인 상태
enum LoginStatus {
    case appleSignedIn
    case googleSignedIn
    case signedOut
    case initializing
}

enum Platform {
    case apple
    case google
}

@MainActor
final class AuthViewModel: NSObject, ObservableObject, ASAuthorizationControllerDelegate {
    private let usecase: UserUsecase
    @Published var loginStatus: LoginStatus = .initializing
    @Published var shouldNavigate: Bool = false
    @Published var currentUser: User?
    @Published var platform: Platform = .apple
    fileprivate var currentNonce: String?
    
    // issue
    var currentUserId: String {
        guard let userId = Auth.auth().currentUser?.uid else {
            return ""
//            fatalError("현재 유저에 접근하기 위해선 로그인 상태여야 합니다.")
        }
        
        return userId
    }
    
    init(usecase: UserUsecase) {
        self.usecase = usecase
    }
    
    // MARK: - 구글 로그인
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
        platform = .google
    }
    
    private func googleSignOut() {
        GIDSignIn.sharedInstance.signOut()
    }
    
    // MARK: - 애플 로그인
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
                    platform = .apple
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
    
    // MARK: - Firebase Auth 소셜로그인 인증
    private func authenticateWithFirebase(credential: AuthCredential) async throws {
        let result = try await Auth.auth().signIn(with: credential)
        
        if result.additionalUserInfo?.isNewUser == true {
            shouldNavigate = true
        } else {
            switch platform {
            case .apple:
                loginStatus = .appleSignedIn
            case .google:
                loginStatus = .googleSignedIn
            }
        }
    }
    
    // MARK: - 로그아웃
    func signOut() async {
        do {
            try Auth.auth().signOut()
            loginStatus = .signedOut
        } catch {
            print("Error when signing out")
        }
    }
    
    // MARK: - 로그인 유지
    func restore() {
        if Auth.auth().currentUser != nil {
            loginStatus = .appleSignedIn
        } else {
            loginStatus = .signedOut
        }
    }
    
    func getUser() async {
        do {
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
            currentUser = try await usecase.getUser(userId: userId)
            
            if let profileImageUrl = currentUser?.profileImageUrl {
                let prefetcher = ImagePrefetcher(
                    urls: [URL(string: profileImageUrl)!],
                    options: [.cacheMemoryOnly]
                )
                
                prefetcher.start()
            }
        } catch {
            print("Error when getting user: \(error)")
        }
    }
}

