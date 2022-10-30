//
//  Line.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/24/22.
//

import UIKit

struct StrokeSegment {
    let a: CGPoint
    let b: CGPoint
    let c: CGPoint
    let d: CGPoint
    let abWidth: CGFloat
    let cdWidth: CGFloat
}

final class Line {
    
    private(set) var points = [LinePoint]()
    private var smoothPoints = [LinePoint]()
    private var segments = [StrokeSegment]()
    
    private var velocities = [CGFloat]()
    
    private let minLineWidth = 1.0
    private let maxLinewidth = 10.0
    
    var lineWidth = Progress.mid
    
    let color: UIColor
    
    init(color: UIColor = .white) {
        self.color = color
    }
    
    func draw(
        atLocation location: CGPoint,
        velocity: CGPoint,
        color: UIColor
    ) -> CGRect {
        let width = extractLineWidth(from: velocity)
        velocities.append(width)
        
        let point = LinePoint(position: location, width: width)
        return appendPoint(point)
    }
    
    func drawInContext(_ context: CGContext) {
        var segments = segments
        
        guard segments.count > 2 else { return }
        
        // leaving last 2 segments for next draw
        segments.removeLast(2)
        
        for segment in segments {
            context.beginPath()
            context.setStrokeColor(color.cgColor)
            context.setFillColor(color.cgColor)

            context.move(to: segment.b)
            let abStartAngle = atan2(segment.b.y - segment.a.y, segment.b.x - segment.a.x)
            context.addArc(
                center: (segment.a + segment.b)/2,
                radius: segment.abWidth/2,
                startAngle: abStartAngle,
                endAngle: abStartAngle + .pi,
                clockwise: true
            )
            context.addLine(to: segment.c)
            let cdStartAngle = atan2(segment.c.y - segment.d.y, segment.c.x - segment.d.x)
            context.addArc(
                center: (segment.c + segment.d)/2,
                radius: segment.cdWidth/2,
                startAngle: cdStartAngle,
                endAngle: cdStartAngle + .pi,
                clockwise: true
            )
            context.closePath()
            
            context.fillPath()
            context.strokePath()
        }
    }
}

private extension Line {
    
    func extractLineWidth(from velocity: CGPoint) -> CGFloat {
        let length = velocity.length
        var size = (length / 166).clamped(minValue: 1, maxValue: 40)
        
        if let lastVelocity = velocities.last {
            size = size*0.2 + lastVelocity*0.8;
        }
        
        return size
    }
    
    func appendPoint(_ point: LinePoint) -> CGRect {
        points.append(point)
        
        guard points.count > 2 else { return .null }
        
        let index = points.count - 1
        let point0 = points[index - 2]
        let point1 = points[index - 1]
        let point2 = points[index]
        
        let newSmoothPoints = smoothPoints(
            fromPoint0: point0,
            point1: point1,
            point2: point2
        )
        
        let lastOldSmoothPoint = smoothPoints.last
        smoothPoints.append(contentsOf: newSmoothPoints)
        
        guard smoothPoints.count > 1 else { return .null }
        
        let newSegments: ([StrokeSegment], CGRect) = {
            guard let lastOldSmoothPoint = lastOldSmoothPoint else {
                return segments(fromSmoothPoints: newSmoothPoints)
            }
            return segments(fromSmoothPoints: [lastOldSmoothPoint] + newSmoothPoints)
        }()
        segments.append(contentsOf: newSegments.0)
        
        return newSegments.1
    }
    
    func smoothPoints(
        fromPoint0 point0: LinePoint,
        point1: LinePoint,
        point2: LinePoint
    ) -> [LinePoint] {
        var smoothPoints = [LinePoint]()
        
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
            smoothPoints.append(point)
        }
        
        let finalPoint = LinePoint(
            position: midPoint2,
            width: (point1.width + point2.width) * 0.5
        )
        smoothPoints.append(finalPoint)
        
        return smoothPoints
    }
    
    func segments(
        fromSmoothPoints smoothPoints: [LinePoint]
    ) -> ([StrokeSegment], CGRect) {
        var segments = [StrokeSegment]()
        var updateRect = CGRect.null
        for i in 1..<smoothPoints.count {
            let previousPoint = smoothPoints[i - 1].position
            let previousWidth = smoothPoints[i - 1].width
            let currentPoint = smoothPoints[i].position
            let currentWidth = smoothPoints[i].width
            let direction = currentPoint - previousPoint
            
            guard !currentPoint.fuzzyEqual(to: previousPoint, value: 0.0001) else {
                continue
            }
            
            let perpendicular = direction.perpendicular.normalized

            let a = previousPoint + perpendicular * previousWidth / 2
            let b = previousPoint - perpendicular * previousWidth / 2
            let c = currentPoint + perpendicular * currentWidth / 2
            let d = currentPoint - perpendicular * currentWidth / 2
            
            let ab: CGPoint = {
                let center = (b + a)/2
                let radius = center - b
                return .init(x: center.x - radius.y, y: center.y + radius.x)
            }()
            let cd: CGPoint = {
                let center = (c + d)/2
                let radius = center - c
                return .init(x: center.x + radius.y, y: center.y - radius.x)
            }()
            
            let minX = min(a.x, b.x, c.x, d.x, ab.x, cd.x)
            let minY = min(a.y, b.y, c.y, d.y, ab.y, cd.y)
            let maxX = max(a.x, b.x, c.x, d.x, ab.x, cd.x)
            let maxY = max(a.y, b.y, c.y, d.y, ab.y, cd.y)
            
            updateRect = updateRect.union(.init(
                x: minX,
                y: minY,
                width: maxX - minX,
                height: maxY - minY
            ))
            
            segments.append(.init(
                a: a, b: b, c: c, d: d,
                abWidth: previousWidth, cdWidth: currentWidth
            ))
        }
        return (segments, updateRect)
    }
}
