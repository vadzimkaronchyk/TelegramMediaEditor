//
//  PaddedTextField.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 20.10.22.
//

import UIKit

class PaddedTextField: UITextField {
    
    var textInsets = UIEdgeInsets.zero
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textInsets)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textInsets)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textInsets)
    }
}
