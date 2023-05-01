//
//  UserSevice.swift
//  NADA-iOS-forRelease
//
//  Created by kimhyungyu on 2021/11/01.
//

import Foundation
import Moya

enum UserSevice {
    case userDelete
    case userSocialSignUp(socialID: String, socialType: String)
}

extension UserSevice: TargetType {

    var baseURL: URL {
        return URL(string: Const.URL.baseURL)!
    }
    
    var path: String {
        switch self {
        case .userDelete:
            return "/member"
        case .userSocialSignUp:
            return "/auth/signup"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .userSocialSignUp:
            return .post
        case .userDelete:
            return .delete
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .userDelete:
            return .requestPlain
        case .userSocialSignUp(let socialID, let socialType):
            return .requestParameters(parameters: ["socialId": socialID,
                                                   "socialType": socialType],
                                      encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .userSocialSignUp:
            return Const.Header.applicationJsonHeader()
        case .userDelete:
            return Const.Header.bearerHeader()
        }
    }
}
