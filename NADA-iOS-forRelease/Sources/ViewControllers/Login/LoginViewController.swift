//
//  LoginViewController.swift
//  NADA-iOS-forRelease
//
//  Created by 민 on 2021/09/21.
//

import UIKit
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import AuthenticationServices

class LoginViewController: UIViewController {
    
    // MARK: - IBOutlet Properties
    @IBOutlet weak var loginProviderStackView: UIStackView!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        // FIXME: - 서버 연결 테스트, 추후 위치 수정 필요
        // getUserIDFetchWithAPI(userID: "nada")
        // getUserTokenFetchWithAPI(userID: "nada")
    }
    
    // MARK: - Functions
    func setUI() {
        let kakaoButton = UIButton()
        kakaoButton.setImage(UIImage(named: "kakao_login_large_wide"), for: .normal)
        kakaoButton.addTarget(self, action: #selector(kakaoSignInButtonPress), for: .touchUpInside)
        loginProviderStackView.addSubview(kakaoButton)
        
        kakaoButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            kakaoButton.topAnchor.constraint(equalTo: loginProviderStackView.topAnchor),
            kakaoButton.leadingAnchor.constraint(equalTo: loginProviderStackView.leadingAnchor),
            kakaoButton.trailingAnchor.constraint(equalTo: loginProviderStackView.trailingAnchor),
            kakaoButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        let authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        authorizationButton.addTarget(self, action: #selector(appleSignInButtonPress), for: .touchUpInside)
        loginProviderStackView.addSubview(authorizationButton)
        
        authorizationButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            authorizationButton.leadingAnchor.constraint(equalTo: loginProviderStackView.leadingAnchor),
            authorizationButton.trailingAnchor.constraint(equalTo: loginProviderStackView.trailingAnchor),
            authorizationButton.bottomAnchor.constraint(equalTo: loginProviderStackView.bottomAnchor),
            authorizationButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    // 메인 화면으로 전환 함수
    func presentToMain() {
        let nextVC = UIStoryboard(name: Const.Storyboard.Name.tabBar, bundle: nil).instantiateViewController(withIdentifier: Const.ViewController.Identifier.tabBarViewController)
        nextVC.modalPresentationStyle = .overFullScreen
        self.present(nextVC, animated: true, completion: nil)
    }
    
    // 카카오 로그인 버튼 클릭 시
    @objc
    func kakaoSignInButtonPress() {
        if AuthApi.hasToken() {     // 유효한 토큰 존재
            UserApi.shared.accessTokenInfo { (_, error) in
                if let error = error {
                    if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true {
                        // 로그인 필요
                        self.signUp()
                    }
                } else {
                    // 토큰 유효성 체크 성공(필요 시 토큰 갱신됨)
                    self.signUp()
                }
            }
        } else {
            // 카카오 토큰 없음 -> 로그인 필요
            self.signUp()
        }
    }
    
    // 애플 로그인 버튼 클릭 시
    @objc
    func appleSignInButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
}

// MARK: - KakaoSignIn
extension LoginViewController {
    func loginWithApp() {
        UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
            if let error = error {
                print(error)
            } else {
                print("loginWithKakaoTalk() success.")
                
                UserApi.shared.me {(user, error) in
                    if let error = error {
                        print(error)
                    } else {
                        if let email = user?.kakaoAccount?.email {
                            self.postUserSignUpWithAPI(request: email)
                        }
                    }
                }
                
                self.presentToMain()
            }
        }
        
    }
    
    func loginWithWeb() {
        UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
            if let error = error {
                print(error)
            } else {
                print("loginWithKakaoAccount() success.")
                
                UserApi.shared.me {(user, error) in
                    if let error = error {
                        print(error)
                    } else {
                        if let email = user?.kakaoAccount?.email {
                            self.postUserSignUpWithAPI(request: email)
                        }
                    }
                }
                
                self.presentToMain()
            }
        }
    }
    
    // 카카오 로그인 표출 함수
    func signUp() {
        // 카카오톡 설치 여부 확인
        if UserApi.isKakaoTalkLoginAvailable() {
            // 카카오톡 로그인. api 호출 결과를 클로저로 전달.
            loginWithApp()
        } else {
            // 만약, 카카오톡이 깔려있지 않을 경우에는 웹 브라우저로 카카오 로그인함.
            loginWithWeb()
        }
    }
}

// MARK: - AppleSignIn
extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    // Apple ID 연동 성공 시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
            // Apple ID
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // 계정 정보 가져오기
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            print("User ID : \(userIdentifier)")
            print("User Email : \(email ?? "")")
            print("User Name : \((fullName?.givenName ?? "") + (fullName?.familyName ?? ""))")
            postUserSignUpWithAPI(request: userIdentifier)
            presentToMain()
            
        default:
            break
        }
    }
    
    // Apple ID 연동 실패 시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}

// MARK: - Network
extension LoginViewController {
    func getUserIDFetchWithAPI(userID: String) {
        UserAPI.shared.userIDFetch(userID: userID) { response in
            switch response {
            case .success(let data):
                print(data)
            case .requestErr(let message):
                print("getUserIDFetchWithAPI - requestErr", message)
            case .pathErr:
                print("getUserIDFetchWithAPI - pathErr")
            case .serverErr:
                print("getUserIDFetchWithAPI - serverErr")
            case .networkFail:
                print("getUserIDFetchWithAPI - networkFail")
            }
        }
    }
    
    func getUserTokenFetchWithAPI(userID: String) {
        UserAPI.shared.userTokenFetch(userID: userID) { response in
            switch response {
            case .success(let data):
                print(data)
            case .requestErr(let message):
                print("getUserTokenFetchWithAPI - requestErr", message)
            case .pathErr:
                print("getUserTokenFetchWithAPI - pathErr")
            case .serverErr:
                print("getUserTokenFetchWithAPI - serverErr")
            case .networkFail:
                print("getUserTokenFetchWithAPI - networkFail")
            }
        }
    }
    
    func postUserSignUpWithAPI(request: String) {
        UserAPI.shared.userSocialSignUp(request: request) { response in
            switch response {
            case .success(let loginData):
                print("postUserSignUpWithAPI - success")
                if let userData = loginData as? UserWithTokenRequest {
                    print(userData.user.userID, "⭐️")
                    UserDefaults.standard.set(userData.user.userID, forKey: Const.UserDefaults.userID)
                    if let tokenData = userData.user.token as? Token {
                        UserDefaults.standard.set(tokenData.accessToken, forKey: Const.UserDefaults.accessToken)
                        UserDefaults.standard.set(tokenData.refreshToken, forKey: Const.UserDefaults.refreshToken)
                    }
                }
            case .requestErr(let message):
                print("postUserSignUpWithAPI - requestErr: \(message)")
            case .pathErr:
                print("postUserSignUpWithAPI - pathErr")
            case .serverErr:
                print("postUserSignUpWithAPI - serverErr")
            case .networkFail:
                print("postUserSignUpWithAPI - networkFail")
            }
        }
    }
    
}
