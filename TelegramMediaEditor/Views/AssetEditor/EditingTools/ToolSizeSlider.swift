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
        let trackFrame = trackView.frame
        thumbView.frame = .init(
            origin: .init(
                x: value.value(min: trackFrame.minX, max: trackFrame.maxX) - thumbSize/2,
                y: 0
            ),
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
        let trackFrame = trackView.frame
        let locationX = location.x.clamped(
            minValue: trackFrame.minX,
            maxValue: trackFrame.maxX
        )
        thumbView.center.x = locationX
        value = .init((locationX - trackFrame.minX)/(trackFrame.maxX - trackFrame.minX))
        
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
        
        let thickness = min(rect.width, rect.height)
        let length = max(rect.width, rect.height)
        
        let fromWidth = thickness*0.14
        let toWidth = thickness*0.82
        let centerY = thickness/2
        
        context.setFillColor(UIColor.secondarySystemBackground.cgColor)
        context.setAlpha(0.7)
        
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
            x: length - toWidth/2,
            y: centerY - toWidth/2)
        )
        context.addArc(
            center: .init(x: length - toWidth/2, y: centerY),
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
