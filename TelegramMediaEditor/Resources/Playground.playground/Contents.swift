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
        algorithm.draw(in: context, canvas: canvas)
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

//let canvasView = PlaygroundCanvasView(frame: .init(
//    x: 0, y: 0,
//    width: 400, height: 1000
//))
//canvasView.canvas = canvas
//canvasView.algorithm = algorithm

struct Algorithm1: LineDrawerAlgorithm {
    
    func draw(in context: CGContext, canvas: Canvas) {
        
    }
}

//PlaygroundPage.current.liveView = canvasView

