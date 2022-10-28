import UIKit
import PlaygroundSupport

protocol LineDrawerAlgorithm {
    func draw(in context: CGContext, canvas: Canvas)
}

struct Canvas {
    let lineWidth: CGFloat
    let color: UIColor
    let points: [CGPoint]
}

final class PlaygroundCanvasView: UIView {
    
    var canvas: Canvas!
    var algorithm: LineDrawerAlgorithm!
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let point0 = CGPoint(x: 70, y: 50)
        let point1 = CGPoint(x: 100, y: 100)
        let point2 = CGPoint(x: 150, y: 50)
        let startAngle = atan2(point2.y - point1.y, point2.x - point1.x)
        context.setFillColor(UIColor.red.cgColor)
        context.move(to: point0)
        context.addLine(to: point2)
        context.addArc(
            center: (point1+point2)/2,
            radius: abs(point1.distance(to: point2))/2,
            startAngle: startAngle,
            endAngle: startAngle + .pi,
            clockwise: false
        )
        context.closePath()
        context.fillPath()
        context.strokePath()
    }
}

let points: [CGPoint] = (0...30).map { index in
    CGPoint(
        x: .random(in: 10...390),
        y: .random(in: 50...950)
    )
}
let canvas = Canvas(lineWidth: 1, color: .black, points: points)
let algorithm = Algorithm1()

let canvasView = PlaygroundCanvasView(frame: .init(
    x: 0, y: 0,
    width: 200, height: 400
))
canvasView.canvas = canvas
canvasView.algorithm = algorithm

struct Algorithm1: LineDrawerAlgorithm {
    
    func draw(in context: CGContext, canvas: Canvas) {
//        let points = canvas.points
//        for (index, point) in points[0..<points.count-1].enumerated() {
//            let nextPoint = points[index+1]
//            let direction = nextPoint - point
//            let perpendicular = direction.perpendicular.normalized
//            let a = point + perpendicular * point / 2.0
//        }
    }
}

PlaygroundPage.current.liveView = canvasView

