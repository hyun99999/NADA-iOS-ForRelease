//
//  UserTokenReissueRequset.swift
//  NADA-iOS-forRelease
//
//  Created by 민 on 2021/12/21.
//

import Foundation

struct UserTokenReissueRequset: Codable {
    var accessToken: String
    var refreshToken: String
}
