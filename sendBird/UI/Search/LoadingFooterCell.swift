//
//  LoadingFooterCell.swift
//  sendBird
//
//  Created by chiman song on 2021/04/07.
//

import Foundation
import UIKit

//typealias LoadingFooterEventHandler = () -> Void

class LoadingFooterCell: UICollectionViewCell {
    enum Status {
        case loading
        case done
        case noMore
    }
    
    static let identifier = "LoadingFooterCell"
    
    // MARK: - UI Component
    let spinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .gray)
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    let noMoreLabel: UILabel = {
        let n = UILabel()
        n.text = "no more search data"
        n.font = UIFont.systemFont(ofSize: 18)
        n.textColor = .darkGray
        n.isHidden = true
        n.translatesAutoresizingMaskIntoConstraints = false
        return n
    }()
    
    // MARK: - Property
    var loadingStatus: Status? {
        didSet {
            switch loadingStatus {
            case .loading:
                self.noMoreLabel.isHidden = true
                self.animateDots(isLoading: true)
            case .done:
                self.noMoreLabel.isHidden = true
                self.animateDots(isLoading: false)
            case .noMore:
                self.noMoreLabel.isHidden = false
                self.animateDots(isLoading: false)
            default:
                break
            }
        }
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    // MARK: - Setup UI
    private func setupView() {
        [spinner, noMoreLabel].forEach {
            self.contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            self.spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            self.spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            self.noMoreLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            self.noMoreLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    // MARK: - Action
    private func animateDots(isLoading: Bool) {
        if isLoading {
            self.spinner.startAnimating()
            self.spinner.isHidden = false
        } else {
            self.spinner.isHidden = true
            self.spinner.stopAnimating()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
