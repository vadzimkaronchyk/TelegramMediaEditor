//
//  CGSizeExtensions.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 19.10.22.
//

import CoreGraphics

extension CGSize {
    
    static func square(size: CGFloat) -> Self {
        .init(width: size, height: size)
    }
    
    static func square(size: Int) -> Self {
        .init(width: size, height: size)
    }
}
