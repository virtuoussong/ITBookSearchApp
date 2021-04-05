//
//  BookDetailViewController.swift
//  sendBird
//
//  Created by chiman song on 2021/04/05.
//

import Foundation
import UIKit

class BookDetailViewController: UIViewController {
    
    //MARK: - UI Components
    let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    let stackView: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 8
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    let bookImageView: UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFit
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    let bookTitleLabel: UILabel = {
        let i = UILabel()
        i.numberOfLines = 0
        i.font = UIFont.boldSystemFont(ofSize: 20)
        i.textColor = .darkGray
        return i
    }()
    
    let subTitleLabel: UILabel = {
        let i = UILabel()
        i.numberOfLines = 0
        i.font = UIFont.systemFont(ofSize: 14)
        i.textColor = .gray
        return i
    }()
    
    let priceLabel: UILabel = {
        let i = UILabel()
        i.font = UIFont.systemFont(ofSize: 14)
        i.textColor = .gray
        return i
    }()
    
    let languageLabel: UILabel = {
        let i = UILabel()
        i.font = UIFont.systemFont(ofSize: 14)
        i.textColor = .gray
        return i
    }()
    
    let pageLabel: UILabel = {
        let i = UILabel()
        i.font = UIFont.systemFont(ofSize: 14)
        i.textColor = .gray
        return i
    }()
    
    let publisherLabel: UILabel = {
        let i = UILabel()
        i.font = UIFont.systemFont(ofSize: 14)
        i.textColor = .gray
        return i
    }()
    
    let ratingLabel: UILabel = {
        let i = UILabel()
        i.font = UIFont.systemFont(ofSize: 14)
        i.textColor = .gray
        return i
    }()
    
    let yearLabel: UILabel = {
        let i = UILabel()
        i.font = UIFont.systemFont(ofSize: 14)
        i.textColor = .gray
        return i
    }()
    
    let isbn10Label: UILabel = {
        let i = UILabel()
        i.font = UIFont.systemFont(ofSize: 14)
        i.textColor = .gray
        return i
    }()
    
    let isbn13Label: UILabel = {
        let i = UILabel()
        i.font = UIFont.systemFont(ofSize: 14)
        i.textColor = .gray
        return i
    }()
    
    let descriptionLabel: UILabel = {
        let i = UILabel()
        i.numberOfLines = 0
        i.font = UIFont.systemFont(ofSize: 18)
        i.textColor = .darkGray
        return i
    }()
    
    lazy var purchButton: UIButton = {
        let p = UIButton()
        p.addTarget(self, action: #selector(didTapPurchaseButton), for: .touchUpInside)
        p.setTitle("Purchase", for: .normal)
        p.setTitleColor(.white, for: .normal)
        p.backgroundColor = .darkGray
        p.layer.cornerRadius = 8
        p.clipsToBounds = true
        p.translatesAutoresizingMaskIntoConstraints = false
        return p
    }()
    
    @objc private func didTapPurchaseButton() {
        if let urlString = dataSet?.url {
            if let url = URL(string: urlString) {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    //MARK: - Properties
    var dataSet: BookDetail? {
        didSet {
            if let imageUrl = dataSet?.image {
                bookImageView.loadImageFromUrl(urlString: imageUrl)
            }
            
            if let title = dataSet?.title {
                bookTitleLabel.text = title
            }
            
            if let subTitle = dataSet?.subtitle {
                subTitleLabel.text = subTitle
            }
            
            if let description = dataSet?.desc {
                descriptionLabel.text = description
            }
            
            
            if let price = dataSet?.price {
                priceLabel.text = "price: \(price)"
            }
            
            if let rating = dataSet?.rating {
                ratingLabel.text = "rating: \(rating)"
            }
            
            if let language = dataSet?.language {
                languageLabel.text = "language: \(language)"
            }
            
            if let page = dataSet?.page {
                pageLabel.text = "\(page)pages"
            }
            
            if let publisher = dataSet?.publisher {
                publisherLabel.text = "publisher: \(publisher)"
            }
            
            if let year = dataSet?.year {
                yearLabel.text = "year: \(year)"
            }
            
            if let isbn10 = dataSet?.isbn10 {
                isbn10Label.text = "isbn10: \(isbn10)"
            }
            
            if let isbn13 = dataSet?.isbn13 {
                isbn13Label.text = "isbn13: \(isbn13)"
            }
            
            setupScrollViewContents()
        }
    }
    
    convenience init(id: String) {
        self.init()
        getBookDetailData(id: id)
    }
    
}

extension BookDetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubViews()
        makeConstraints()
        makeScrollView()
    }
}


private extension BookDetailViewController {
    func addSubViews() {
        [scrollView, purchButton].forEach({ view.addSubview($0) })
        scrollView.addSubview(stackView)
        [bookImageView, bookTitleLabel, subTitleLabel, priceLabel, ratingLabel, languageLabel, descriptionLabel, pageLabel, publisherLabel, yearLabel, isbn10Label, isbn13Label].forEach({ stackView.addArrangedSubview($0) })
    }
    
    func makeScrollView() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupScrollViewContents() {
        stackView.layoutIfNeeded()
        scrollView.contentSize = CGSize(width: view.frame.width, height: stackView.frame.height)
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 98, right: 0)
    }
    
    func makeConstraints() {
        let viewGuide: UILayoutGuide
        if #available(iOS 11.0, *) {
            viewGuide = view.safeAreaLayoutGuide
        } else {
            viewGuide = view.readableContentGuide
        }

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24),
            
            purchButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            purchButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24),
            purchButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24),
            purchButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func getBookDetailData(id: String) {
        ApiRequest.shared.request(url: ApiEndPoint.getBookDetail(id).address, method: .get) { [weak self] (isSuccessful, response: BookDetail?) in
            if let data = response {
                DispatchQueue.main.async {
                    self?.dataSet = data
                }
            }
        }
    }
}

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

