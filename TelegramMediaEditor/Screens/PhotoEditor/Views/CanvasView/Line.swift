//
//  Line.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/24/22.
//

import UIKit

struct LineSegment {
    let firstPoint: CGPoint
    let secondPoint: CGPoint
}

struct LinePoint {
    
    let point: CGPoint
    let velocity: CGFloat
    
    var x: CGFloat { point.x }
    var y: CGFloat { point.y }
}

final class Line {
    
    let color: UIColor
    var points: [LinePoint]
    
    var currentPoint: LinePoint {
        points.last!
    }
    
    var lineWidth = 10.0
    
    init(color: UIColor = .white, point: LinePoint) {
        self.color = color
        self.points = [point]
    }
    
    func appendPoint(_ point: LinePoint) {
        points.append(point)
    }
    
    func appendPoints(_ points: [LinePoint]) {
        self.points.append(contentsOf: points)
    }
    
    func drawInContext(_ context: CGContext) {
    }
}
