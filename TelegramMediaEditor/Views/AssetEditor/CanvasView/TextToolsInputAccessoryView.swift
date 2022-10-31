//
//  TextToolsInputAccessoryView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/31/22.
//

import UIKit

final class TextToolsInputAccessoryView: UIInputView {
    
    private let colorsCircleView = ColorsCircleView()
    private let textToolsView = TextToolsView()
    private let spectrumView = ColorSpectrumView()
    private let spectrumCursorView = ColorSliderCursorView()
    
    private var color = HSBColor.white
    
    var onColorsCircleTapped: VoidClosure?
    var onColorSelected: Closure<HSBColor>?
    var onTextAlignmentChanged: Closure<NSTextAlignment>?
    
    init() {
        super.init(frame: .zero, inputViewStyle: .keyboard)
        
        setupLayout()
        setupViews()
        addGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateCursorViewLocation(color: color)
    }
    
    func updateDrawingColor(_ color: HSBColor) {
        self.color = color
        colorsCircleView.color = color
        spectrumCursorView.color = color
        spectrumCursorView.outlineColor = color
        updateCursorViewLocation(color: color)
    }
    
    func updateTextAlignment(_ alignment: NSTextAlignment) {
        textToolsView.updateTextAlignment(alignment)
    }
}

private extension TextToolsInputAccessoryView {
    
    func setupLayout() {
        addSubview(colorsCircleView)
        addSubview(textToolsView)
        
        colorsCircleView.translatesAutoresizingMaskIntoConstraints = false
        textToolsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorsCircleView.heightAnchor.constraint(equalToConstant: 33),
            colorsCircleView.widthAnchor.constraint(equalTo: colorsCircleView.heightAnchor),
            colorsCircleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            colorsCircleView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            colorsCircleView.trailingAnchor.constraint(equalTo: textToolsView.leadingAnchor, constant: -14),
            colorsCircleView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            textToolsView.centerYAnchor.constraint(equalTo: colorsCircleView.centerYAnchor),
            textToolsView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func setupViews() {
        setupTextToolsView()
        setupSpectrumView()
    }
    
    func setupTextToolsView() {
        textToolsView.onTextAlignmentChanged = { [weak self] alignment in
            self?.onTextAlignmentChanged?(alignment)
        }
    }
    
    func setupSpectrumView() {
        spectrumView.cornerRadius = 16
        spectrumCursorView.frame.size = .square(size: 36)
    }
    
    func addGestureRecognizers() {
        colorsCircleView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(handleColorCircleViewTapGesture)
        ))
        colorsCircleView.addGestureRecognizer(UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleColorCircleViewLongPressGesture)
        ))
    }
    
    func showSpectrumView() {
        if spectrumView.superview == nil {
            addSubview(spectrumView)
            spectrumView.addSubview(spectrumCursorView)
            
            spectrumView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                spectrumView.widthAnchor.constraint(equalTo: spectrumView.heightAnchor, multiplier: 12/10),
                spectrumView.leadingAnchor.constraint(equalTo: colorsCircleView.leadingAnchor),
                spectrumView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
                spectrumView.bottomAnchor.constraint(equalTo: colorsCircleView.bottomAnchor)
            ])
        }
        spectrumView.isHidden = false
    }
    
    func hideSpectrumView() {
        spectrumView.isHidden = true
    }
    
    func updateCursorViewLocation(color: HSBColor) {
        if let location = spectrumView.location(forColor: color) {
            spectrumCursorView.center = .init(
                x: spectrumView.bounds.minX + location.x,
                y: spectrumView.bounds.minY + location.y
            )
            spectrumCursorView.isHidden = false
        } else {
            spectrumCursorView.isHidden = true
        }
    }
}

private extension TextToolsInputAccessoryView {
    
    @objc func handleColorCircleViewTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        onColorsCircleTapped?()
    }
    
    @objc func handleColorCircleViewLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            showSpectrumView()
        case .changed:
            let location = gestureRecognizer.location(in: spectrumView)
            let clampedLocation = CGPoint(
                x: location.x.clamped(
                    minValue: spectrumView.bounds.minX,
                    maxValue: spectrumView.bounds.maxX
                ),
                y: location.y.clamped(
                    minValue: spectrumView.bounds.minY,
                    maxValue: spectrumView.bounds.maxY
                )
            )
            let color = spectrumView.color(atLocation: clampedLocation)

            self.color = color
            colorsCircleView.color = color
            spectrumCursorView.isHidden = false
            spectrumCursorView.center = clampedLocation
            spectrumCursorView.color = color
            spectrumCursorView.outlineColor = color

            onColorSelected?(color)
        case .ended, .cancelled, .failed:
            hideSpectrumView()
        default:
            break
        }
    }
}
