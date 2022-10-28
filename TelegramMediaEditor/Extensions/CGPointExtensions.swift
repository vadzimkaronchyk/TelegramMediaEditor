//
//  CGPointExtensions.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 19.10.22.
//

import CoreGraphics

extension CGPoint {
    
    var length: CGFloat {
        sqrt(x*x + y*y)
    }
    
    var normalized: CGPoint {
        let length = length
        return length > 0 ? self / length : .zero
    }
    
    var perpendicular: CGPoint {
        .init(x: -y, y: x)
    }
    
    func distance(to point: CGPoint) -> CGFloat {
        sqrt(squaredDistance(to: point))
    }
    
    func squaredDistance(to point: CGPoint) -> CGFloat {
        pow(x - point.x, 2) + pow(y - point.y, 2)
    }
    
    func fuzzyEqual(to point: CGPoint, value: CGFloat) -> Bool {
        if x - value <= point.x && point.x <= x + value {
            if y - value <= point.y && point.y <= y + value {
                return true
            }
        }
        return false
    }
    
    static func single(location: CGFloat) -> Self {
        .init(x: location, y: location)
    }
}

func * (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    .init(x: lhs.x * rhs.x, y: lhs.y * rhs.x)
}

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
