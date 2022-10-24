//
//  Line.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/24/22.
//

import UIKit

struct LinePoint {
    let point: CGPoint
}

final class Line {
    
    let color: UIColor
    var points: [LinePoint]
    
    var currentPoint: LinePoint {
        points.last!
    }
    
    var lineWidth: Double {
        6
    }
    
    var path: UIBezierPath {
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        
        guard let firstPoint = points.first else {
            return path
        }
        
        path.move(to: firstPoint.point)
        for i in 1..<points.count {
            path.addLine(to: points[i].point)
        }
        
        return path
    }
    
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
}
