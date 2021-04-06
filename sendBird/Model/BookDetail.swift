//
//  BookDetail.swift
//  sendBird
//
//  Created by chiman song on 2021/04/06.
//

import Foundation

struct BookDetail: Codable {
    let authors: String?
    let desc: String?
    let error: String?
    let image: String?
    let isbn10: String?
    let isbn13: String?
    let language: String?
    let page: Int?
    let price: String?
    let publisher: String?
    let rating: String?
    let subtitle: String?
    let title: String?
    let url: String?
    let year: String?
}
