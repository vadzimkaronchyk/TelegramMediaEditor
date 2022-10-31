//
//  ColorPickerSpectrumView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/13/22.
//

import UIKit

final class ColorPickerSpectrumView: UIView, ColorPicker {
    
    private let spectrumView = ColorSpectrumView()
    private let cursorView = ColorSliderCursorView()
    
    var cornerRadius: Double {
        get { spectrumView.layer.cornerRadius }
        set { spectrumView.layer.cornerRadius = newValue }
    }
    
    var onColorSelected: Closure<HSBColor>?
    
    private var color: HSBColor = .black
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateCursorViewLocation(color: color)
    }
    
    func updateColor(_ color: HSBColor) {
        self.color = color
        cursorView.color = color
        cursorView.outlineColor = color
        updateCursorViewLocation(color: color)
    }
}

private extension ColorPickerSpectrumView {
    
    func setupLayout() {
        addSubview(spectrumView)
        addSubview(cursorView)
        
        spectrumView.translatesAutoresizingMaskIntoConstraints = false
        cursorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            spectrumView.widthAnchor.constraint(equalTo: spectrumView.heightAnchor, multiplier: 12/10),
            spectrumView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            spectrumView.leadingAnchor.constraint(equalTo: leadingAnchor),
            spectrumView.trailingAnchor.constraint(equalTo: trailingAnchor),
            spectrumView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            cursorView.heightAnchor.constraint(equalToConstant: 36),
            cursorView.widthAnchor.constraint(equalTo: cursorView.heightAnchor),
            cursorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            cursorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func setupViews() {
        backgroundColor = .clear
        cursorView.backgroundColor = .clear
        cursorView.isUserInteractionEnabled = false
        addGestureRecognizers()
    }
    
    func addGestureRecognizers() {
        addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(handleTapGesture)
        ))
        addGestureRecognizer(UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePanGesture)
        ))
    }
}

private extension ColorPickerSpectrumView {
    
    @objc func handleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .ended else { return }
        handleGestureChange(gestureRecognizer)
    }
    
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        handleGestureChange(gestureRecognizer)
    }
    
    func handleGestureChange(_ gestureRecognizer: UIGestureRecognizer) {
        let location = gestureRecognizer.location(in: gestureRecognizer.view)
        let clampedLocation = CGPoint(
            x: location.x.clamped(
                minValue: spectrumView.frame.minX,
                maxValue: spectrumView.frame.maxX
            ),
            y: location.y.clamped(
                minValue: spectrumView.frame.minY,
                maxValue: spectrumView.frame.maxY
            )
        )
        let color = spectrumView.color(atLocation: convert(location, to: spectrumView))
        
        cursorView.isHidden = false
        cursorView.center = clampedLocation
        cursorView.color = color
        cursorView.outlineColor = color
        
        onColorSelected?(color)
    }
    
    func updateCursorViewLocation(color: HSBColor) {
        if let location = spectrumView.location(forColor: color) {
            cursorView.center = .init(
                x: spectrumView.frame.minX + location.x,
                y: spectrumView.frame.minY + location.y
            )
            cursorView.isHidden = false
        } else {
            cursorView.isHidden = true
        }
    }
}
