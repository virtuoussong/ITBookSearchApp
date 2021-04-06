//
//  Observable.swift
//  sendBird
//
//  Created by chiman song on 2021/04/06.
//

import Foundation

class Observable<T> {
    typealias Listener = (T) -> Void
    var listener : Listener?
    
    var value : T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}
