//
//  SearchViewController.swift
//  sendBird
//
//  Created by chiman song on 2021/03/31.
//

import Foundation
import UIKit

class SearchViewController: UIViewController {
    
    //MARK: - UI Component
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let c = UICollectionView(frame: .zero, collectionViewLayout: layout)
        c.register(BookItemView.self, forCellWithReuseIdentifier: BookItemView.identifier)
        c.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        c.backgroundColor = .white
        c.delegate = self
        c.dataSource = self
        c.translatesAutoresizingMaskIntoConstraints = false
        return c
    }()
    
    //MARK: - Properties
    var viewModel = BookSearchViewModel()
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        addSubViews()
        makeConstrains()
        searchBookAPIReqeust()
    }
    
    func addSubViews() {
        [collectionView].forEach({ view.addSubview($0) })
    }
    
    func makeConstrains() {
        let viewGuide: UILayoutGuide
        if #available(iOS 11.0, *) {
            viewGuide = view.safeAreaLayoutGuide
        } else {
            viewGuide = view.readableContentGuide
        }
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: viewGuide.topAnchor, constant: 0),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: viewGuide.bottomAnchor, constant: 0)
        ])
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookItemView.identifier, for: indexPath) as! BookItemView
        let data = viewModel.data[indexPath.item]
        cell.dataSet = data
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print(indexPath.item)
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}

private extension SearchViewController {
    
}

private extension SearchViewController {
    func searchBookAPIReqeust() {
        let url = "https://api.itbook.store/1.0/search/\("success")"
        ApiRequest.request(url: url, method: .get) { [weak self] (success, response: BookSearch?) in
            guard let self = self else { return }
            if success {
                if let books = response?.books {
                    self.viewModel.data = books
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
}
