//
//  BookItemView.swift
//  sendBird
//
//  Created by chiman song on 2021/04/04.
//

import Foundation
import UIKit

final class BookItemView: UICollectionViewCell {
    
    //MARK: - UI Components
    static let identifier = "BookItemView"
    
    private let bookImageView: UIImageView = {
        let b = UIImageView()
        b.contentMode = .scaleAspectFill
        b.translatesAutoresizingMaskIntoConstraints = false
        b.layer.cornerRadius = 8
        b.clipsToBounds = true
        return b
    }()
    
    private let stackView: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 8
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    private let bookNameLabel: UILabel = {
        let b = UILabel()
        b.font = UIFont.boldSystemFont(ofSize: 18)
        b.textColor = .black
        b.numberOfLines = 0
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let subTitleLabel: UILabel = {
        let b = UILabel()
        b.numberOfLines = 0
        b.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        b.textColor = .darkGray
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let subInfoStackView: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.distribution = .fill
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    private let priceLabel: UILabel = {
        let b = UILabel()
        b.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        b.textColor = .darkGray
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let isbn13Label: UILabel = {
        let b = UILabel()
        b.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        b.textColor = .darkGray
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let grayLine: UIView = {
        let g = UIView()
        g.backgroundColor = .lightGray
        g.translatesAutoresizingMaskIntoConstraints = false
        return g
    }()
    
    //MARK: - Properties
    var dataSet: Book? {
        didSet {
            if let imageUrl = dataSet?.image {
                self.bookImageView.image = nil
                self.configureImageWith(urlString: imageUrl)
            }
            
            if let bookName = dataSet?.title {
                self.bookNameLabel.text = bookName
            }
            
            if let subTitle = dataSet?.subtitle {
                self.subTitleLabel.text = subTitle
            } else {
                self.subTitleLabel.isHidden = true
            }
            
            if let isbn13 = dataSet?.isbn13 {
                self.isbn13Label.text = isbn13
            }
            
            if let price = dataSet?.price {
                self.priceLabel.text = price
            }
        }
    }
    
    private var task: URLSessionDataTask?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubViews()
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Prepare to reuse
extension BookItemView {
    override func prepareForReuse() {
        self.task?.cancel()
        self.task = nil
        self.bookImageView.image = nil
    }
}

//MARK: - Setup view
private extension BookItemView {
    func addSubViews() {
        [bookImageView, stackView, grayLine].forEach({ contentView.addSubview($0) })
        [bookNameLabel, subTitleLabel, subInfoStackView].forEach({ stackView.addArrangedSubview($0) })
        [priceLabel, isbn13Label].forEach({ subInfoStackView.addArrangedSubview($0) })
    }
    
    func setupView() {
        NSLayoutConstraint.activate([
            self.bookImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            self.bookImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            self.bookImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            self.bookImageView.heightAnchor.constraint(equalToConstant: frame.size.width - 32),
            
            self.stackView.topAnchor.constraint(equalTo: bookImageView.bottomAnchor, constant: 8),
            self.stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            self.stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            
            self.subInfoStackView.widthAnchor.constraint(equalToConstant: frame.size.width - 32),
            self.subInfoStackView.heightAnchor.constraint(equalToConstant: 16),
            
            self.grayLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            self.grayLine.heightAnchor.constraint(equalToConstant: 1),
            self.grayLine.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            self.grayLine.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
        ])
    }
    
    func configureImageWith(urlString: String) {
        if self.task == nil {
            self.task = self.bookImageView.loadImageFromUrl(urlString: urlString)
        }
    }

}
