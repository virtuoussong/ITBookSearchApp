//
//  UIImageView+Extention.swift
//  sendBird
//
//  Created by chiman song on 2021/04/04.
//

import Foundation
import UIKit


class ImageCache {
    static let imageCache = NSCache<NSString, UIImage>()
}

extension UIImageView {
    func loadImageFromUrl(urlString: String) -> URLSessionDataTask? {
        guard let url = URL(string: urlString) else { return nil }
        
        self.image = nil
        
        if let imageInCache = ImageCache.imageCache.object(forKey: urlString as NSString) {
            self.image = imageInCache
            return nil
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error as Any)
                return
            }
    
            if let imageData = data {
                DispatchQueue.main.async {
                    if let imageForCache = UIImage(data: imageData) {
                        ImageCache.imageCache.setObject(imageForCache, forKey: urlString as NSString)
                        self.image = imageForCache
                    }
                }
            }
        }
        
        task.resume()
        
        return task
    }
}
