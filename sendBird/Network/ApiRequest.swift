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
        
    func request<T: Codable>(url: String, method: ApiMethod, params: [Dictionary<String, String>]? = nil, completion: @escaping (Bool, T?) -> Void) -> URLSessionDataTask? {
        
        if let searchCache = cacheData.object(forKey: url as NSString) {
            DispatchQueue.main.async {
                completion(true, searchCache.cacheData as? T)
            }
            return nil
        }

        guard let remoteURL = URL(string: url) else { return nil }
      
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
                    guard let unwrappedData = data else { return }
                    let json = try JSONSerialization.jsonObject(with: unwrappedData, options: [])
                    print("json: \(json)")
                    
                    let jsonDecode = try JSONDecoder().decode(T.self, from: unwrappedData)
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
        
        return task
    }
}


