//
//  BookItemView.swift
//  sendBird
//
//  Created by chiman song on 2021/04/04.
//

import Foundation
import UIKit

class BookItemView: UICollectionViewCell {
    
    //MARK: - UI Components
    static let identifier = "BookItemView"
    
    let bookImageView: UIImageView = {
        let b = UIImageView()
        b.contentMode = .scaleAspectFill
        b.translatesAutoresizingMaskIntoConstraints = false
        b.layer.cornerRadius = 8
        b.clipsToBounds = true
        b.backgroundColor = .yellow
        return b
    }()
    
    let stackView: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 8
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    let bookNameLabel: UILabel = {
        let b = UILabel()
        b.font = UIFont.boldSystemFont(ofSize: 16)
        b.textColor = .black
        b.numberOfLines = 2
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    let priceLabel: UILabel = {
        let b = UILabel()
        b.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        b.textColor = .darkGray
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    //MARK: - Properties
    var dataSet: Book? {
        didSet {
            if let bookName = dataSet?.title {
                bookNameLabel.text = bookName
            }
            
            if let imageUrl = dataSet?.image {
                bookImageView.loadImageFromUrl(urlString: imageUrl)
            }
            
            if let price = dataSet?.price {
                priceLabel.text = price
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews()
        setupView()
    }
    
    func addSubViews() {
        [bookImageView, stackView].forEach({ contentView.addSubview($0) })
        [bookNameLabel, priceLabel].forEach({ stackView.addArrangedSubview($0) })
    }
    
    func setupView() {
        NSLayoutConstraint.activate([
            bookImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bookImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            bookImageView.widthAnchor.constraint(equalToConstant: 100),
            bookImageView.heightAnchor.constraint(equalToConstant: 100),
            
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.leftAnchor.constraint(equalTo: bookImageView.rightAnchor, constant: 8),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
