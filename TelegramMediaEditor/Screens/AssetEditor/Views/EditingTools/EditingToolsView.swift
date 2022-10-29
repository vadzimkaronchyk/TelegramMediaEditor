//
//  EditingToolsView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/10/22.
//

import UIKit

final class EditingToolsView: UIView {
    
    private let colorsCircleView = ColorsCircleView()
    private let drawingToolsPickerView = DrawingToolsPickerView()
    private let addShapeButton = UIButton(type: .system)
    private let bottomView = EditingToolsBottomView()
    private let spectrumView = ColorSpectrumView()
    private let spectrumCursorView = ColorSliderCursorView()
    
    var onColorsCircleTapped: VoidClosure?
    var onToolSelected: Closure<Tool>?
    var onAddShapeTapped: Closure<UIView>?
    var onCancelTapped: VoidClosure?
    var onSaveTapped: VoidClosure?
    var onStrokeShapeTapped: Closure<UIView>?
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
    
    func updateDrawingColor(_ color: HSBColor) {
        self.color = color
        colorsCircleView.color = color
        spectrumCursorView.color = color
        spectrumCursorView.outlineColor = color
        updateCursorViewLocation(color: color)
    }
    
    func updateStrokeShape(_ strokeShape: StrokeShape) {
        bottomView.updateStrokeShape(strokeShape)
    }
    
    func setSaveButtonEnabled(_ enabled: Bool) {
        bottomView.setSaveButtonEnabled(enabled)
    }
    
    func setLoadingActive(_ active: Bool) {
        bottomView.setLoadingActive(active)
    }
}

// MARK: - Setup methods

private extension EditingToolsView {
    
    func setupLayout() {
        addSubview(colorsCircleView)
        addSubview(drawingToolsPickerView)
        addSubview(addShapeButton)
        addSubview(bottomView)
        addSubview(spectrumView)
        spectrumView.addSubview(spectrumCursorView)
        
        colorsCircleView.translatesAutoresizingMaskIntoConstraints = false
        drawingToolsPickerView.translatesAutoresizingMaskIntoConstraints = false
        addShapeButton.translatesAutoresizingMaskIntoConstraints = false
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        spectrumView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorsCircleView.heightAnchor.constraint(equalToConstant: 33),
            colorsCircleView.widthAnchor.constraint(equalTo: colorsCircleView.heightAnchor),
            colorsCircleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            colorsCircleView.bottomAnchor.constraint(equalTo: bottomView.topAnchor, constant: -8),
            drawingToolsPickerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            drawingToolsPickerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 240/390),
            drawingToolsPickerView.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            drawingToolsPickerView.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
            addShapeButton.heightAnchor.constraint(equalToConstant: 33),
            addShapeButton.widthAnchor.constraint(equalTo: addShapeButton.heightAnchor),
            addShapeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            addShapeButton.bottomAnchor.constraint(equalTo: bottomView.topAnchor, constant: -8),
            bottomView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: bottomAnchor),
            spectrumView.widthAnchor.constraint(equalTo: spectrumView.heightAnchor, multiplier: 12/10),
            spectrumView.leadingAnchor.constraint(equalTo: colorsCircleView.leadingAnchor),
            spectrumView.trailingAnchor.constraint(equalTo: addShapeButton.centerXAnchor),
            spectrumView.bottomAnchor.constraint(equalTo: colorsCircleView.bottomAnchor),
        ])
    }
    
    func setupViews() {
        setupView()
        setupDrawingToolsPickerView()
        setupAddShapeButton()
        setupBottomView()
        setupSpectrumView()
        addGestureRecognizers()
        
        spectrumView.isHidden = true
    }
    
    func setupView() {
        backgroundColor = .clear
    }
    
    func setupDrawingToolsPickerView() {
        drawingToolsPickerView.onToolSelected = { [weak self] tool in
            self?.onToolSelected?(.drawing(tool))
        }
        drawingToolsPickerView.onToolHighlighted = { [weak self] tool in
            self?.bottomView.showBottomToolSettingsView()
        }
        drawingToolsPickerView.onToolDehighlighted = { [weak self] in
            self?.bottomView.showBottomControlsView()
        }
    }
    
    func setupAddShapeButton() {
        addShapeButton.tintColor = .white
        addShapeButton.backgroundColor = .white.withAlphaComponent(0.1)
        addShapeButton.layer.cornerRadius = 16.5
        addShapeButton.setImage(.init(named: "add"), for: .normal)
        addShapeButton.addTarget(self, action: #selector(addShapeButtonTapped), for: .touchUpInside)
    }
    
    func setupBottomView() {
        bottomView.onCancelTapped = { [weak self] in
            self?.onCancelTapped?()
        }
        bottomView.onSaveTapped = { [weak self] in
            self?.onSaveTapped?()
        }
        bottomView.onBackTapped = { [weak self] in
            self?.drawingToolsPickerView.dehighlight()
        }
        bottomView.onStrokeShapeTapped = { [weak self] view in
            self?.onStrokeShapeTapped?(view)
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

// MARK: - Action methods

private extension EditingToolsView {
    
    @objc func addShapeButtonTapped(_ button: UIButton) {
        onAddShapeTapped?(button)
    }
    
    @objc func handleColorCircleViewTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        onColorsCircleTapped?()
    }
    
    @objc func handleColorCircleViewLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            spectrumView.isHidden = false
        case .ended, .cancelled, .failed:
            spectrumView.isHidden = true
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
        default:
            break
        }
    }
}
