//
//  ApiRequest.swift
//  sendBird
//
//  Created by chiman song on 2021/04/04.
//

import Foundation

class ApiRequest {
        
    static func request<T: Codable>(url: String, method: ApiMethod, params: [Dictionary<String, String>]? = nil, completion: @escaping (Bool, T?) -> Void) {
        guard let urlString = URL(string: url) else { return }
        
        var request = URLRequest(url: urlString)
        request.httpMethod = method.rawValue
        if let parameters = params {
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print("response", response!)
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            if httpResponse.statusCode == 200 {
                do {
                    let jsonDecode = try JSONDecoder().decode(T.self, from: data!)
                    completion(true, jsonDecode)
                } catch {
                    print("error", error)
                    completion(false, nil)
                }
            } else {
                completion(false, nil)
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
