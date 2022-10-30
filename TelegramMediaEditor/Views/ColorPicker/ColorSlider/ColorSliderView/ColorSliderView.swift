//
//  ColorSliderView.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 19.10.22.
//

import UIKit

final class ColorSliderView: UIView {
    
    private let trackView = ColorSliderTrackView()
    private let cursorView = ColorSliderCursorView()
    
    var color: HSBColor = .black {
        didSet {
            trackView.colors = model.sliderColors(color)
            cursorView.color = color
            moveCursorView(progress: model.colorToProgress(color))
        }
    }
    
    var progress: Progress {
        get { model.colorToProgress(color) }
        set {
            color = model.progressToColor(color, newValue)
        }
    }
    
    var onColorChanged: Closure<HSBColor>?
    
    private let model: ColorSliderModel
    
    init(model: ColorSliderModel) {
        self.model = model
        super.init(frame: .zero)
        
        setupLayout()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let progress = model.colorToProgress(color)
        moveCursorView(progress: progress)
    }
}

private extension ColorSliderView {
    
    func setupLayout() {
        addSubview(trackView)
        addSubview(cursorView)
        
        trackView.translatesAutoresizingMaskIntoConstraints = false
        cursorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            trackView.topAnchor.constraint(equalTo: topAnchor),
            trackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            trackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            cursorView.heightAnchor.constraint(equalTo: trackView.heightAnchor),
            cursorView.widthAnchor.constraint(equalTo: cursorView.heightAnchor),
            cursorView.centerYAnchor.constraint(equalTo: trackView.centerYAnchor),
            cursorView.centerXAnchor.constraint(equalTo: trackView.centerXAnchor)
        ])
    }
    
    func setupViews() {
        setupTrackView()
        setupCursorView()
        addGestureRecognizers()
    }
    
    func setupTrackView() {
        trackView.backgroundColor = .clear
    }
    
    func setupCursorView() {
        cursorView.backgroundColor = .clear
        cursorView.isUserInteractionEnabled = false
    }
    
    func addGestureRecognizers() {
        trackView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(handleTapGesture)
        ))
        trackView.addGestureRecognizer(UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePanGesture)
        ))
    }
    
    func moveCursorView(progress: Progress) {
        let trackBounds = trackView.bounds
        let cursorRadius = cursorView.bounds.size.width/2
        cursorView.center.x = (trackBounds.maxX * progress.value).clamped(
            minValue: cursorRadius,
            maxValue: trackBounds.maxX - cursorRadius
        )
    }
}

private extension ColorSliderView {
    
    @objc func handleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .ended else { return }
        handleGestureChange(gestureRecognizer)
    }
    
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        handleGestureChange(gestureRecognizer)
    }
    
    func handleGestureChange(_ gestureRecognizer: UIGestureRecognizer) {
        let location = gestureRecognizer.location(in: trackView)
        let maxX = trackView.bounds.maxX
        let progress = Progress(location.x / maxX)
        
        color = model.progressToColor(color, progress)
        onColorChanged?(color)
    }
}
