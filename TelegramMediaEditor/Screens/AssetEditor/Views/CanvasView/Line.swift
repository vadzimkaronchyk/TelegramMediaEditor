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
    
    let position: CGPoint
    let width: CGFloat
    
    var x: CGFloat { position.x }
    var y: CGFloat { position.y }
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
        let points = calculateSmoothPoints(from: points)
        
        guard !points.isEmpty else { return }
        
        for i in 1..<points.count {
            let previousPoint = points[i - 1].position
            let previousWidth = points[i - 1].width
            let currentPoint = points[i].position
            let currentWidth = points[i].width
            let direction = currentPoint - previousPoint
            
            guard !currentPoint.fuzzyEqual(to: previousPoint, value: 0.0001) else {
                continue
            }
            
            let perpendicular = direction.perpendicular.normalized

            let a = previousPoint + perpendicular * previousWidth / 2
            let b = previousPoint - perpendicular * previousWidth / 2
            let c = currentPoint + perpendicular * currentWidth / 2
            let d = currentPoint - perpendicular * currentWidth / 2
            
            context.beginPath()
            context.setStrokeColor(color.cgColor)
            context.setFillColor(color.cgColor)

            context.move(to: b)
            let abStartAngle = atan2(b.y - a.y, b.x - a.x)
            context.addArc(
                center: (a + b)/2,
                radius: previousWidth/2,
                startAngle: abStartAngle,
                endAngle: abStartAngle + .pi,
                clockwise: true
            )
            context.addLine(to: c)
            let cdStartAngle = atan2(c.y - d.y, c.x - d.x)
            context.addArc(
                center: (c + d)/2,
                radius: currentWidth/2,
                startAngle: cdStartAngle,
                endAngle: cdStartAngle + .pi,
                clockwise: true
            )
            context.closePath()
            
            context.fillPath()
            context.strokePath()
        }
    }
    
    private func calculateSmoothPoints(from points: [LinePoint]) -> [LinePoint] {
        guard points.count > 2 else { return [] }
        
        var smoothedPoints = [LinePoint]()
        for i in 2..<points.count {
            let point0 = points[i - 2]
            let point1 = points[i - 1]
            let point2 = points[i]
            
            let midPoint1 = (point0.position + point1.position) * 0.5
            let midPoint2 = (point1.position + point2.position) * 0.5
            
            let segmentDistance = 2.0
            let distance = midPoint1.distance(to: midPoint2)
            let numberOfSegments = min(128, max(floor(distance/segmentDistance), 32))
            
            let step = 1.0 / numberOfSegments
            for t in stride(from: 0, to: 1, by: step) {
                let position = midPoint1 * pow(1 - t, 2) + point1.position * 2 * (1 - t) * t + midPoint2 * t * t
                let size = pow(1 - t, 2) * ((point0.width + point1.width) * 0.5) + 2 * (1 - t) * t * point1.width + t * t * ((point1.width + point2.width) * 0.5)
                let point = LinePoint(position: position, width: size)
                smoothedPoints.append(point)
            }
            
            let finalPoint = LinePoint(
                position: midPoint2,
                width: (point1.width + point2.width) * 0.5
            )
            smoothedPoints.append(finalPoint)
        }
        
        // leaving last 2 points for next draw
        smoothedPoints.removeLast(2)
        
        return smoothedPoints
    }
}
