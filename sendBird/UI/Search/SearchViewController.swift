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
    lazy var searchBar: UISearchBar = {
        let s = UISearchBar()
        s.placeholder = "Search by keyword"
        s.delegate = self
        s.backgroundColor = .white
        s.searchBarStyle = .default
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
//        layout.estimatedItemSize = CGSize(width: view.frame.width, height: 400)
        
        let c = UICollectionView(frame: .zero, collectionViewLayout: layout)
        c.register(BookItemView.self, forCellWithReuseIdentifier: "BookItemView")
        c.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        c.backgroundColor = .white
        c.delegate = self
        c.dataSource = self
        c.translatesAutoresizingMaskIntoConstraints = false
        return c
    }()
    
    //MARK: - Properties
    var viewModel = BookSearchViewModel()
    var currentPage = "1"
    var searchedWord = ""
    var cellHeightCache: [String: CGSize] = [:]
}

private extension SearchViewController {
    func addSubViews() {
        [searchBar, collectionView].forEach({ view.addSubview($0) })
    }
    
    func makeConstrains() {
        let viewGuide: UILayoutGuide
        if #available(iOS 11.0, *) {
            viewGuide = view.safeAreaLayoutGuide
        } else {
            viewGuide = view.readableContentGuide
        }
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: viewGuide.topAnchor),
            searchBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            searchBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
    
    func bindViewModel() {
        viewModel.data.bind { [unowned self] _ in
            self.collectionView.reloadData()
        }
    }
}

extension SearchViewController {
    override func viewDidLoad() {
        view.backgroundColor = .white
        addSubViews()
        makeConstrains()
        bindViewModel()
    }
}



extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.data.value?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookItemView", for: indexPath) as! BookItemView
        let item = viewModel.data.value?[indexPath.item]
        cell.dataSet = item
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let index = Double(indexPath.item)
        if index > Double(viewModel.data.value?.count ?? 0) * 0.7 {
            guard let page = Int(currentPage) else { return }
            searchBookAPIReqeust(text: searchedWord, page: page + 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let id = viewModel.data.value?[indexPath.item].isbn13 {
            let viewController = BookDetailViewController(id: id)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let data = viewModel.data.value?[indexPath.item]
        if let id = data?.isbn13, let size = cellHeightCache[id] {
            return size
        }
        
        let width = view.frame.width - 32
        let titleHeight = TextHeight.textHeightForView(text: data?.title ?? "", font: UIFont.boldSystemFont(ofSize: 18), width: width) + 8
        let subTitleHeight = data?.title == nil ? 0 : TextHeight.textHeightForView(text: data?.subtitle ?? "", font: UIFont.boldSystemFont(ofSize: 18), width: width) + 8
        let subInfo: CGFloat = 24
        let bottomLine: CGFloat = 24
        
        let total = width + titleHeight + subTitleHeight + subInfo + bottomLine
        
        let size = CGSize(width: view.frame.width, height: total)
        if let id = data?.isbn13 {
            cellHeightCache[id] = size
        }
        
        return size
    }
}

extension SearchViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
        self.searchBar.setShowsCancelButton(false, animated: true)
    }
}


extension SearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        self.searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        if text != searchedWord {
            self.searchBookAPIReqeust(text: text, page: 1)
        }
        self.searchedWord = text
        
        self.searchBar.resignFirstResponder()
        self.searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == " " {
            return false
        }
        return true
    }
}

private extension SearchViewController {
    func searchBookAPIReqeust(text: String, page: Int = 1) {
        var url: String = ""
        url = ApiEndPoint.getSearchResult(text, page).address
        
        if page == 1 {
            self.viewModel.data.value?.removeAll()
            self.collectionView.reloadData()
        }
        
        ApiRequest.shared.request(url: url, method: .get) { [weak self] (success, response: BookSearch?) in
            guard let self = self else { return }
            if success {
                print(response)
                if let books = response?.books {
                    if page == 1 {
                        self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
                        self.viewModel.data.value = books
                    } else {
                        var copy = self.viewModel.data.value
                        books.enumerated().forEach({ (index, item) in
                            if !(self.viewModel.data.value?.contains(where: { (data) -> Bool in
                                data.isbn13 == item.isbn13
                            }) ?? true ) {
                                copy?.append(item)
                                self.viewModel.data.value = copy
                            }
                        })
                    }
                }
                
                if let pageNumResponse = response?.page {
                    self.currentPage = pageNumResponse
                }
            }
        }
    }
}
