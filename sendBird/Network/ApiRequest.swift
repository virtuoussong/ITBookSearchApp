//
//  ApiRequest.swift
//  sendBird
//
//  Created by chiman song on 2021/04/04.
//

import Foundation

class ApiCache<T>{
    let cacheData: T
    
    init(data: T) {
        cacheData = data
    }
}

class ApiRequest {
    
    static let shared = ApiRequest()
    
    var cacheData = NSCache<NSString, ApiCache<Any>>()
        
    func request<T: Codable>(url: String, method: ApiMethod, params: [Dictionary<String, String>]? = nil, completion: @escaping (Bool, T?) -> Void) {
        
        if let searchCache = cacheData.object(forKey: url as NSString) {
            DispatchQueue.main.async {
                completion(true, searchCache.cacheData as? T)
            }
            
            return
        }

        guard let remoteURL = URL(string: url) else { return }
      
        var request = URLRequest(url: remoteURL)
        request.httpMethod = method.rawValue
        if let parameters = params {
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            switch httpResponse.statusCode {
            case 200..<300:
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    print("json: \(json)")
                    
                    let jsonDecode = try JSONDecoder().decode(T.self, from: data!)
                    self.cacheData.setObject(ApiCache(data: jsonDecode), forKey: url as NSString)
                    DispatchQueue.main.async {
                        completion(true, jsonDecode)
                    }
                    
                } catch {
                    print("error", error)
                    completion(false, nil)
                }
            case 400:
                print("error", error as Any)
                completion(false, nil)
            case 500:
                print("error", error as Any)
                completion(false, nil)
            default:
                break
            }
        })
        
        task.resume()
    }
    
}

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
