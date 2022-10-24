//
//  CGRectExtensions.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/24/22.
//

import CoreGraphics

extension CGRect {
    
    init(p1: LinePoint, p2: LinePoint) {
        let p1 = p1.point
        let p2 = p2.point
        self.init(x: min(p1.x, p2.x),
                  y: min(p1.y, p2.y),
                  width: abs(p1.x - p2.x),
                  height: abs(p1.y - p2.y))
    }
}
