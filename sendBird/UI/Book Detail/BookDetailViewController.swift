//
//  BookDetailViewController.swift
//  sendBird
//
//  Created by chiman song on 2021/04/05.
//

import Foundation
import UIKit

final class BookDetailViewController: UIViewController {
    
    //MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let s = UIScrollView()
        s.delegate = self
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    private let stackView: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 8
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    private let bookImageView: UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFit
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    private let bookTitleLabel: UILabel = {
        let i = UILabel()
        i.numberOfLines = 0
        i.font = UIFont.boldSystemFont(ofSize: 20)
        i.textColor = .darkGray
        return i
    }()
    
    private let subTitleLabel: UILabel = {
        let i = UILabel()
        i.numberOfLines = 0
        i.font = UIFont.systemFont(ofSize: 14)
        i.textColor = .gray
        return i
    }()
    
    private let priceLabel: UILabel = {
        let i = UILabel()
        i.font = UIFont.systemFont(ofSize: 14)
        i.textColor = .gray
        return i
    }()
    
    private let languageLabel: UILabel = {
        let i = UILabel()
        i.font = UIFont.systemFont(ofSize: 14)
        i.textColor = .gray
        return i
    }()
    
    private let pageLabel: UILabel = {
        let i = UILabel()
        i.font = UIFont.systemFont(ofSize: 14)
        i.textColor = .gray
        return i
    }()
    
    private let publisherLabel: UILabel = {
        let i = UILabel()
        i.font = UIFont.systemFont(ofSize: 14)
        i.textColor = .gray
        return i
    }()
    
    private let ratingLabel: UILabel = {
        let i = UILabel()
        i.font = UIFont.systemFont(ofSize: 14)
        i.textColor = .gray
        return i
    }()
    
    private let yearLabel: UILabel = {
        let i = UILabel()
        i.font = UIFont.systemFont(ofSize: 14)
        i.textColor = .gray
        return i
    }()
    
    private let isbn10Label: UILabel = {
        let i = UILabel()
        i.font = UIFont.systemFont(ofSize: 14)
        i.textColor = .gray
        return i
    }()
    
    private let isbn13Label: UILabel = {
        let i = UILabel()
        i.font = UIFont.systemFont(ofSize: 14)
        i.textColor = .gray
        return i
    }()
    
    private let descriptionLabel: UILabel = {
        let i = UILabel()
        i.numberOfLines = 0
        i.font = UIFont.systemFont(ofSize: 18)
        i.textColor = .darkGray
        return i
    }()
    
    private lazy var purchButton: UIButton = {
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
    
    private let noteTitleLabel: UILabel = {
        let i = UILabel()
        i.text = "Note"
        i.numberOfLines = 0
        i.font = UIFont.systemFont(ofSize: 18)
        i.textColor = .darkGray
        return i
    }()
    
    private lazy var noteTextView: UITextView = {
        let t = UITextView()
        t.textColor = .darkGray
        t.font = UIFont.systemFont(ofSize: 16)
        t.layer.borderWidth = 1
        t.layer.borderColor = UIColor.lightGray.cgColor
        t.layer.cornerRadius = 8
        t.backgroundColor = .white
        t.delegate = self
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
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
                if let noteSaved = UserDefaults.standard.value(forKey: isbn13) as? String {
                    noteTextView.text = noteSaved
                    updateTextViewHeight()
                }
            }
            updateScrollViewContentSize()
        }
    }
    
    private var scrollPosition: CGPoint = CGPoint(x: 0, y: 0)
    
    private var keyBoardHeight: CGFloat = 0
        
    private lazy var noteTextViewHeight: NSLayoutConstraint = {
        let n = noteTextView.heightAnchor.constraint(equalToConstant: 100)
        return n
    }()
        
    convenience init(id: String) {
        self.init()
        fetchBookDetailData(id: id)
    }
    
    deinit {
        print("Book Detail denit successful")
    }
    
}

//MARK: - life cycle
extension BookDetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubViews()
        makeConstraints()
        makeScrollView()
        setNotification()
        addDoneButtonOnKeyboard()
    }
}

//MARK: - UI Setup
private extension BookDetailViewController {
    func addSubViews() {
        [scrollView, purchButton].forEach({ view.addSubview($0) })
        scrollView.addSubview(stackView)
        [bookImageView, bookTitleLabel, subTitleLabel, priceLabel, ratingLabel, languageLabel, descriptionLabel, pageLabel, publisherLabel, yearLabel, isbn10Label, isbn13Label, noteTitleLabel, noteTextView].forEach({ stackView.addArrangedSubview($0) })
        if #available(iOS 11.0, *) {
            stackView.setCustomSpacing(16, after: isbn13Label)
        } else {
            let space = UIView()
            space.translatesAutoresizingMaskIntoConstraints = false
            space.heightAnchor.constraint(equalToConstant: 16).isActive = true
            stackView.addArrangedSubview(space)
        }
    }
    
    func makeScrollView() {
        let viewGuide: UILayoutGuide
        if #available(iOS 11.0, *) {
            viewGuide = view.safeAreaLayoutGuide
        } else {
            viewGuide = view.readableContentGuide
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: viewGuide.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: viewGuide.bottomAnchor)
        ])
    }
    
    func updateScrollViewContentSize() {
        
        DispatchQueue.main.async {
            self.stackView.layoutIfNeeded()
            self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.stackView.frame.height)
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 98, right: 0)
        }
    }
    
    func makeConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24),
            
            noteTextViewHeight,
            
            purchButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            purchButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24),
            purchButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24),
            purchButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        noteTextView.inputAccessoryView = doneToolbar
    }
    
    func updateTextViewHeight() {
        let size = CGSize(width: view.frame.width - 48, height: .infinity)
        let estimatedSize = noteTextView.sizeThatFits(size)
        print(estimatedSize.height)
        let height: CGFloat = estimatedSize.height > 100 ? estimatedSize.height : 100
        noteTextView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = height
            }
        }
    }
    
    private func findParentScrollView(of view: UIView) -> UIScrollView? {
        var current = view
        while let superview = current.superview {
            if let scrollView = superview as? UIScrollView {
                return scrollView
            } else {
                current = superview
            }
        }
        return nil
    }
    
    func scrollViewToMakeKeyboardVisible() {
        DispatchQueue.main.async {
            if let range = self.noteTextView.selectedTextRange?.start {
                let cursurPosition = self.noteTextView.caretRect(for: range).origin.y
                print("cursurPosition", cursurPosition)
                let keyboardY = self.view.frame.height - self.keyBoardHeight
                if let element = self.noteTextView.superview?.convert((self.noteTextView.frame.origin), to: self.view) {
                    if keyboardY < (element.y + cursurPosition + 200) {
                        let scrollAmount = keyboardY + 200 + cursurPosition
                        let scrollPont = CGPoint(x: 0, y: scrollAmount)
                        self.scrollView.setContentOffset(scrollPont, animated: true)
                    }
                }
            }
        }
    }
}

//MARK: - API Call
private extension BookDetailViewController {
    func fetchBookDetailData(id: String) {
        ApiRequest.shared.request(url: ApiEndPoint.getBookDetail(id).address, method: .get) { [weak self] (isSuccessful, response: BookDetail?) in
            if let data = response {
                self?.dataSet = data
            }
        }
    }
}

//MARK: - Keyboard Notification
private extension BookDetailViewController {
    func setNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(keyboardShowNotification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(keyboardShowNotification notification: Notification) {
        
        scrollPosition = scrollView.contentOffset
        
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardRectangle = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return  }
        keyBoardHeight = keyboardRectangle.height
        scrollViewToMakeKeyboardVisible()
    }
    
    @objc func keyboardwillHide(keyboardShowNotification notification: Notification) {
        self.scrollView.setContentOffset(scrollPosition, animated: true)
    }
}

//MARK: - Action
private extension BookDetailViewController {
    @objc private func didTapPurchaseButton() {
        if let urlString = dataSet?.url {
            if let url = URL(string: urlString) {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @objc func doneButtonAction(){
        if let id = dataSet?.isbn13, let text = noteTextView.text {
            UserDefaults.standard.setValue(text, forKey: id)
        }
        noteTextView.resignFirstResponder()
    }
    
    @objc func endEdit() {
        noteTextView.resignFirstResponder()
    }
}

//MARK: - ScrollView Delegate
extension BookDetailViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

//MARK: - TextView Delegate
extension BookDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        scrollViewToMakeKeyboardVisible()
        updateTextViewHeight()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        updateScrollViewContentSize()
    }
}

