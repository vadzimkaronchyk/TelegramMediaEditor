//
//  ToolSizeSlider.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/26/22.
//

import UIKit

final class ToolSizeSlider: UIControl {
    
    private let trackView = ToolSizeSliderTrackView()
    private let thumbView = ToolSizeSliderThumbView()
    
    var value: Progress = .init(0.5)
    
    private var trackInsets: UIEdgeInsets {
        .init(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(trackView)
        addSubview(thumbView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        trackView.frame = bounds.inset(by: trackInsets)
        let thumbSize = trackView.bounds.height
        thumbView.frame = .init(
            origin: .init(x: trackView.frame.minX + trackView.frame.maxX*value.value, y: 0),
            size: .square(size: thumbSize)
        )
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        updateThumbViewLocation(touch: touch)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        updateThumbViewLocation(touch: touch)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        updateThumbViewLocation(touch: touch)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        updateThumbViewLocation(touch: touch)
    }
    
    private func updateThumbViewLocation(touch: UITouch) {
        let location = touch.location(in: self)
        let locationX = location.x.clamped(minValue: frame.minX, maxValue: trackView.frame.maxX)
        thumbView.center.x = locationX
        
        let progress = locationX / (bounds.width - trackInsets.left - trackInsets.right)
        value = .init(progress)
        
        sendActions(for: .valueChanged)
    }
}

private final class ToolSizeSliderTrackView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let fromWidth = rect.height*0.14
        let toWidth = rect.height*0.82
        let centerY = rect.height/2
        
        context.setFillColor(UIColor.secondarySystemBackground.cgColor)
        context.move(to: .init(
            x: fromWidth/2,
            y: centerY + fromWidth/2
        ))
        context.addArc(
            center: .init(x: fromWidth/2, y: centerY),
            radius: fromWidth/2,
            startAngle: -.pi*1.5,
            endAngle: -.pi/2,
            clockwise: false
        )
        context.addLine(to: .init(
            x: rect.width - toWidth/2,
            y: centerY - toWidth/2)
        )
        context.addArc(
            center: .init(x: rect.width - toWidth/2, y: centerY),
            radius: toWidth/2,
            startAngle: -.pi/2,
            endAngle: -.pi*1.5,
            clockwise: false
        )
        context.closePath()
        context.fillPath()
    }
}

private final class ToolSizeSliderThumbView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: rect)
    }
}
