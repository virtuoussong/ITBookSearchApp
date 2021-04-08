//
//  Book.swift
//  sendBird
//
//  Created by chiman song on 2021/04/04.
//

import Foundation

struct BookSearch: Codable {
    let books: [Book]?
    let total: String?
    let page: String?
}

struct Book: Codable {
    let image: String?
    let isbn13: String?
    let price: String?
    let subtitle: String?
    let title: String?
    let url: String?
}
