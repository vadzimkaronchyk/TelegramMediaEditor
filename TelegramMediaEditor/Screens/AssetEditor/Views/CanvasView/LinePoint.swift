//
//  LinePoint.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/30/22.
//

import CoreGraphics

struct LinePoint {
    
    var x: CGFloat { position.x }
    var y: CGFloat { position.y }
    
    let position: CGPoint
    let width: CGFloat
    
    init(position: CGPoint, width: CGFloat) {
        self.position = position
        self.width = width
    }
}
