//
//  SearchViewController.swift
//  sendBird
//
//  Created by chiman song on 2021/03/31.
//

import Foundation
import UIKit

final class SearchViewController: UIViewController {
    
    //MARK: - UI Component
    private lazy var searchBar: UISearchBar = {
        let s = UISearchBar()
        s.placeholder = "Search by keyword"
        s.delegate = self
        s.backgroundColor = .white
        s.searchBarStyle = .default
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let c = UICollectionView(frame: .zero, collectionViewLayout: layout)
        c.register(BookItemView.self, forCellWithReuseIdentifier: "BookItemView")
        c.register(LoadingFooterCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: LoadingFooterCell.identifier)
        c.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        c.backgroundColor = .white
        c.delegate = self
        c.dataSource = self
        c.translatesAutoresizingMaskIntoConstraints = false
        return c
    }()
    
    private let noResultLabel: UILabel = {
        let n = UILabel()
        n.text = "Search books by keyword"
        n.numberOfLines = 0
        n.font = UIFont.systemFont(ofSize: 18)
        n.textColor = .darkGray
        n.translatesAutoresizingMaskIntoConstraints = false
        return n
    }()
    
    //MARK: - Properties
    private var viewModel = BookSearchViewModel()
    private var currentPage = "1"
    private var searchedWord = ""
    private var cellHeightCache: [String: CGSize] = [:]
    private var searchDataFetchSession: URLSessionDataTask?
    private var availableBookCount: Int?
    //MARK: - Life cycle
    override func viewDidLoad() {
        self.view.backgroundColor = .white
        self.addSubViews()
        self.makeConstrains()
        self.bindViewModel()
    }
}

//MARK: - Setup Views
private extension SearchViewController {
    func addSubViews() {
        [self.searchBar, self.collectionView, self.noResultLabel].forEach({ view.addSubview($0) })
    }
    
    func makeConstrains() {
        let viewGuide: UILayoutGuide
        if #available(iOS 11.0, *) {
            viewGuide = view.safeAreaLayoutGuide
        } else {
            viewGuide = view.readableContentGuide
        }
        
        NSLayoutConstraint.activate([
            self.searchBar.topAnchor.constraint(equalTo: viewGuide.topAnchor),
            self.searchBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            self.searchBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            self.searchBar.heightAnchor.constraint(equalToConstant: 50),
            
            self.collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0),
            self.collectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            self.collectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            self.collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            
            self.noResultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.noResultLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

//MARK: - Bind ViewModel
private extension SearchViewController {
    func bindViewModel() {
        self.viewModel.data.bind { [unowned self] data in
            self.collectionView.isHidden = !(data?.count ?? 0 > 0)
            self.noResultLabel.isHidden = data?.count ?? 0 > 0
            self.collectionView.reloadData()
        }
    }
}

//MARK: - Actions
private extension SearchViewController {
    func updateLoadingFooterCell(loading status: LoadingFooterCell.Status) {
        if let footerView = collectionView.subviews.first(where: {$0 is LoadingFooterCell}) as? LoadingFooterCell {
            footerView.loadingStatus = status
        }
    }
    
    func isAllResultsFetched() -> Bool {
        guard availableBookCount != nil else { return false }
        if self.viewModel.data.value?.count == self.availableBookCount {
            self.updateLoadingFooterCell(loading: .noMore)
            return true
        } else {
            return false
        }
    }
    
    func setNewKeyWordSearch() {
        self.currentPage = "1"
        self.availableBookCount = nil
    }
}

//MARK: - CollectionView Datasource delegate
extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.data.value?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookItemView", for: indexPath) as! BookItemView
        let item = self.viewModel.data.value?[indexPath.item]
        cell.dataSet = item
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let index = Double(indexPath.item)
        if index > Double(self.viewModel.data.value?.count ?? 0) * 0.7 {
            guard let page = Int(self.currentPage) else { return }
            self.searchBooksByKeyword(text: searchedWord, page: page + 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let id = self.viewModel.data.value?[indexPath.item].isbn13 {
            let viewController = BookDetailViewController(id: id)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LoadingFooterCell.identifier, for: indexPath)
            return footerCell
        }
        fatalError()
    }
}

//MARK: - CollectionView flowlayout delegate
extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let data = self.viewModel.data.value?[indexPath.item]
        if let id = data?.isbn13, let size = self.cellHeightCache[id] {
            return size
        }
        
        let width = view.frame.width - 32
        let imageHeight = width + 8
        let titleHeight = TextHeight.textHeightForView(text: data?.title ?? "", font: UIFont.boldSystemFont(ofSize: 18), width: width) + 8
        let subTitleHeight = data?.title == nil ? 0 : TextHeight.textHeightForView(text: data?.subtitle ?? "", font: UIFont.boldSystemFont(ofSize: 18), width: width) + 8
        let subInfo: CGFloat = 24
        let bottomLine: CGFloat = 24
        
        let total = imageHeight + titleHeight + subTitleHeight + subInfo + bottomLine
        
        let size = CGSize(width: view.frame.width, height: total)
        if let id = data?.isbn13 {
            self.cellHeightCache[id] = size
        }
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
}

//MARK: - Scrollview delegate
extension SearchViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
        self.searchBar.setShowsCancelButton(false, animated: true)
    }
}

//MARK: - SearchBar delegate
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
            self.setNewKeyWordSearch()
            self.searchBooksByKeyword(text: text, page: 1)
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

//MARK: - API Call
private extension SearchViewController {
    func searchBooksByKeyword(text: String, page: Int = 1) {
        guard !isAllResultsFetched() else { return }
        guard Int(currentPage) == 1 || Int(currentPage) != page else { return}
        
        self.searchDataFetchSession?.cancel()
        self.searchDataFetchSession = nil
        self.apiSearchRequestForBooks(text: text, page: page)
    }
    
    func apiSearchRequestForBooks(text: String, page: Int = 1) {
        self.updateLoadingFooterCell(loading: .loading)
        
        var url: String = ""
        url = ApiEndPoint.getSearchResult(text, page).address

        self.searchDataFetchSession = ApiRequest.shared.request(url: url, method: .get) { [weak self] (success, response: BookSearch?) in
            guard let self = self else { return }
            if success {
                if let total = response?.total {
                    self.availableBookCount = Int(total) ?? 0
                }
                
                if let books = response?.books {
                    if page == 1 { //New keyword search
                        if books.count == 0 {
                            self.noResultLabel.text = "0 items found.\nTry another search word"
                        }
                        
                        self.viewModel.data.value?.removeAll()
                        self.viewModel.data.value = books
                        
                        self.collectionView.reloadData()
                        self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
                        
                    } else { //scroll feed
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
            self.updateLoadingFooterCell(loading: .done)
        }
    }
}
