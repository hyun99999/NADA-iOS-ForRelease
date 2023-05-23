//
//  Screen.swift
//  NADA-iOS-forRelease
//
//  Created by kimhyungyu on 2023/05/18.
//

import Foundation

extension Tracking {
    struct Screen {
        private init() { }
        static let splash = "A1 스플래시"
        static let onboarding = "A2 온보딩"
        static let login = "A3 로그인"
        static let myCard = "C1 내 명함"
        static let cardShareBottomSheet = "C2 명함공유 모달"
        static let createCardCategory = "C3 명함만들기"
        static let createBasicCard = "C4 명함만들기_기본"
        static let createBasicCardPreview = "C5 명함만들기_기본_미리보기"
        static let createFanCard = "C6 명함만들기_덕질"
        static let createFanCardPreview = "C7 명함만들기_덕질_미리보기"
        static let createCompanyCard = "C8 명함만들기_직장"
        static let createCompanyCardPreview = "C9 명함만들기_직장_미리보기"
        static let cardList = "C10 명함리스트"
        static let more = "E1 설정"
        static let myCardWidget = "F1 명함 위젯"
        static let qrcodeWidget = "F2 QR 위젯"
    }
}