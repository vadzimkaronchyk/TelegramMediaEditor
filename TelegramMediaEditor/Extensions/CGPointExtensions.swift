//
//  CGPointExtensions.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 19.10.22.
//

import CoreGraphics

extension CGPoint {
    
    static func single(location: CGFloat) -> Self {
        .init(x: location, y: location)
    }
}
