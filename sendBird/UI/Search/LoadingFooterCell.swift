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
    
    static let identifier = "LoadingFooterCell"
    
    // MARK: - UI Component
    let spinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .gray)
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    // MARK: - Property
    var isLoading: Bool? {
        didSet {
            if let boolValue = isLoading {
                self.animateDots(isLoading: boolValue)
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
        self.contentView.addSubview(spinner)
        NSLayoutConstraint.activate([
            self.spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            self.spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
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
