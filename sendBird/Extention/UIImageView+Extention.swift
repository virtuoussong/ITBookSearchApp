//
//  UIImageView+Extention.swift
//  sendBird
//
//  Created by chiman song on 2021/04/04.
//

import Foundation
import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func loadImageFromUrl(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        self.image = nil
        
        if let imageInCache = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = imageInCache
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error)
                return
            }
    
            if let imageData = data {
                DispatchQueue.main.async {
                    if let imageForCache = UIImage(data: imageData) {
                        imageCache.setObject(imageForCache, forKey: urlString as NSString)
                        self.image = imageForCache
                    }
                }
            }
        }
        
        task.resume()
    }
}
