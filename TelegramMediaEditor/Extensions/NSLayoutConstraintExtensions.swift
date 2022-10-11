//
//  NSLayoutConstraintExtensions.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/11/22.
//

import UIKit

extension NSLayoutConstraint {
    
    static func pinViewToSuperviewConstraints(view: UIView, superview: UIView) -> [NSLayoutConstraint] {
        [view.topAnchor.constraint(equalTo: superview.topAnchor),
         view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
         view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
         view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)]
    }
}
