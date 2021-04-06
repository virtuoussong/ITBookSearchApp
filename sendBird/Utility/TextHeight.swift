//
//  TextHeight.swift
//  sendBird
//
//  Created by chiman song on 2021/04/06.
//

import Foundation
import UIKit

class TextHeight {
    static func textHeightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat {
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        
        return label.frame.height
    }
}
