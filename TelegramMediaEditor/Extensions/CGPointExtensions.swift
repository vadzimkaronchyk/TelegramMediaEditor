//
//  CGPointExtensions.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 19.10.22.
//

import CoreGraphics

extension CGPoint {
    
    func distance(to point: CGPoint) -> CGFloat {
        sqrt(squaredDistance(to: point))
    }
    
    func squaredDistance(to point: CGPoint) -> CGFloat {
        pow(x - point.x, 2) + pow(y - point.y, 2)
    }
    
    static func single(location: CGFloat) -> Self {
        .init(x: location, y: location)
    }
}

// Some functions to make the Catmull-Rom splice code a little more readable.
// These multiply/divide a `CGPoint` by a scalar and add/subtract one `CGPoint`
// from another.

func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    .init(x: lhs.x * rhs, y: lhs.y * rhs)
}

func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    .init(x: lhs.x / rhs, y: lhs.y / rhs)
}

func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}
