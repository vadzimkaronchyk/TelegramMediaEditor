//
//  ColorPickerGridView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/13/22.
//

import UIKit

final class ColorPickerGridView: UIView, ColorPicker {
    
    private let gridView = ColorGridView()
    private let cursorView = ColorGridCursorView()
    
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
        
        cursorView.frame.size = .square(size: gridView.tileSize+cursorView.lineWidth)
        updateCursorViewLocation(color: color)
    }
    
    func updateColor(_ color: HSBColor) {
        self.color = color
        updateCursorViewLocation(color: color)
    }
}

private extension ColorPickerGridView {
    
    func setupLayout() {
        addSubview(gridView)
        addSubview(cursorView)
        
        gridView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            gridView.widthAnchor.constraint(equalTo: gridView.heightAnchor, multiplier: 12/10),
            gridView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            gridView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gridView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gridView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])
    }
    
    func setupViews() {
        backgroundColor = .clear
        gridView.backgroundColor = .clear
        cursorView.isUserInteractionEnabled = false
        
        addGestureRecognizers()
    }
    
    func addGestureRecognizers() {
        gridView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(handleTapGesture)
        ))
        gridView.addGestureRecognizer(UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePanGesture)
        ))
    }
}

private extension ColorPickerGridView {
    
    @objc func handleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .ended else { return }
        handleGestureChange(gestureRecognizer)
    }
    
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        handleGestureChange(gestureRecognizer)
    }
    
    func handleGestureChange(_ gestureRecognizer: UIGestureRecognizer) {
        let location = gestureRecognizer.location(in: gestureRecognizer.view)
        let color = gridView.color(atLocation: location)
        updateCursorViewLocation(color: color)
        
        onColorSelected?(color)
    }
    
    func updateCursorViewLocation(color: HSBColor) {
        if let location = gridView.location(forColor: color) {
            cursorView.frame.origin = .init(
                x: gridView.frame.minX + location.x - cursorView.lineWidth/2,
                y: gridView.frame.minY + location.y - cursorView.lineWidth/2
            )
            cursorView.isHidden = false
        } else {
            cursorView.isHidden = true
        }
    }
}
