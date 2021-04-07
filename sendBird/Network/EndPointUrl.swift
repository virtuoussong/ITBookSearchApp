//
//  EndPointUrl.swift
//  sendBird
//
//  Created by chiman song on 2021/04/07.
//

import Foundation

enum ApiMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

enum ApiEndPoint {
    case getSearchResult(String, Int)
    case getBookDetail(String)
}

enum Version {
    case v1
}

extension Version {
    var version: String {
        switch self {
        case .v1:
            return "1.0"
        }
    }
}

extension ApiEndPoint {
    var address: String {
        switch self {
        case .getSearchResult(let keyWord, let page):
            return "\(ApiManager.hostStore)/\(Version.v1.version)/search/\(keyWord)/\(page)"
        case .getBookDetail(let id):
            return "\(ApiManager.hostStore)/\(Version.v1.version)/books/\(id)"
        }
    }
}

class ApiManager {
    static let hostStore = "https://api.itbook.store"
}
