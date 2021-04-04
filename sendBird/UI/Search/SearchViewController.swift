//
//  SearchViewController.swift
//  sendBird
//
//  Created by chiman song on 2021/03/31.
//

import Foundation
import UIKit

class SearchViewController: UIViewController {
    override func viewDidLoad() {
        setupView()
    }
    
    let blueView: UIView = {
        let b = UIView()
        b.backgroundColor = .blue
        return b
    }()
    
    func setupView() {
        view.backgroundColor = .red
//        view.addSubview(blueView)
        let url = "https://api.itbook.store/1.0/search/\("success")"
        ApiRequest.request(url: url, method: .get) { [weak self] (success, response: BookSearch?) in
            if success {
                print("data decoded", response)
            }
        }
        
    }
}

struct BookSearch: Codable {
    let books: [Book]?
    let total: String?
    let page: String?
    
    enum CodingKeys: String, CodingKey {
        case books = "books"
        case total = "total"
        case page = "page"
    }
}

struct Book: Codable {
    let image: String?
    let isbn13: String?
    let price: String?
    let subtitle: String?
    let title: String?
    let url: String?
}
