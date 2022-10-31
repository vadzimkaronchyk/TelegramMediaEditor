//
//  CanvasCommitedTextView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/30/22.
//

import UIKit

final class CanvasCommitedTextView: UIView {
    
    private let textLabel = UILabel()
    private let leadingControlView = CircleTextControlView()
    private let trailingControlView = CircleTextControlView()
    
    private let borderDashLayer = CAShapeLayer()
    
    override var canBecomeFirstResponder: Bool {
        true
    }
    
    private(set) var text: Text
    
    init(text: Text) {
        self.text = text
        super.init(frame: .zero)
        
        setupLayout()
        setupViews()
        setupBorderDashLayer()
        addGestureRecognizers()
        updateText(text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        borderDashLayer.frame = bounds
        borderDashLayer.path = {
            let minX = bounds.minX
            let maxX = bounds.maxX
            let minY = bounds.minY
            let midY = bounds.midY
            let maxY = bounds.maxY
            let leadingControlHeight = leadingControlView.frame.height
            let trailingControlHeight = trailingControlView.frame.height
            let controlVerticalInset = 8.0
            let cornerRadius = 12.0
            let path = UIBezierPath()
            
            path.move(to: .init(x: minX, y: midY - leadingControlHeight/2 - controlVerticalInset))
            path.addLine(to: .init(x: minX, y: minY + cornerRadius))
            path.addArc(
                withCenter: .init(x: minX + cornerRadius, y: minY + cornerRadius),
                radius: cornerRadius,
                startAngle: -.pi,
                endAngle: -.pi/2,
                clockwise: true
            )
            path.addLine(to: .init(x: maxX - cornerRadius, y: minY))
            path.addArc(
                withCenter: .init(x: maxX - cornerRadius, y: minY + cornerRadius),
                radius: cornerRadius,
                startAngle: -.pi/2,
                endAngle: 0,
                clockwise: true
            )
            path.addLine(to: .init(x: maxX, y: midY - trailingControlHeight/2 - controlVerticalInset))
            
            path.move(to: .init(x: maxX, y: midY + trailingControlHeight/2 + controlVerticalInset))
            path.addLine(to: .init(x: maxX, y: maxY - cornerRadius))
            path.addArc(
                withCenter: .init(x: maxX - cornerRadius, y: maxY - cornerRadius),
                radius: cornerRadius,
                startAngle: 0,
                endAngle: .pi/2,
                clockwise: true
            )
            path.addLine(to: .init(x: minX + cornerRadius, y: maxY))
            path.addArc(
                withCenter: .init(x: minX + cornerRadius, y: maxY - cornerRadius),
                radius: cornerRadius,
                startAngle: .pi/2,
                endAngle: .pi,
                clockwise: true
            )
            path.addLine(to: .init(x: minX, y: midY + leadingControlHeight/2 + controlVerticalInset))
            
            return path.cgPath
        }()
    }
    
    func updateText(_ text: Text) {
        self.text = text
        textLabel.text = text.string
        textLabel.font = .systemFont(ofSize: text.fontSize, weight: .bold)
        textLabel.textColor = text.color
        textLabel.textAlignment = text.alignment
        borderDashLayer.strokeColor = text.color.cgColor
        leadingControlView.color = text.color
        trailingControlView.color = text.color
    }
    
    func setSelected(_ selected: Bool) {
        leadingControlView.isHidden = !selected
        trailingControlView.isHidden = !selected
        borderDashLayer.isHidden = !selected
    }
}

private extension CanvasCommitedTextView {
    
    func setupLayout() {
        addSubview(textLabel)
        addSubview(leadingControlView)
        addSubview(trailingControlView)
        
        layer.addSublayer(borderDashLayer)
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        leadingControlView.translatesAutoresizingMaskIntoConstraints = false
        trailingControlView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            leadingControlView.widthAnchor.constraint(equalToConstant: 11),
            leadingControlView.heightAnchor.constraint(equalTo: leadingControlView.widthAnchor),
            leadingControlView.centerXAnchor.constraint(equalTo: leadingAnchor),
            leadingControlView.centerYAnchor.constraint(equalTo: centerYAnchor),
            trailingControlView.widthAnchor.constraint(equalToConstant: 11),
            trailingControlView.heightAnchor.constraint(equalTo: trailingControlView.widthAnchor),
            trailingControlView.centerXAnchor.constraint(equalTo: trailingAnchor),
            trailingControlView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func setupViews() {
        setupView()
        setupTextLabel()
    }
    
    func setupView() {
        backgroundColor = .clear
    }
    
    func setupTextLabel() {
        textLabel.textColor = .white
        textLabel.numberOfLines = 0
    }
    
    func setupBorderDashLayer() {
        borderDashLayer.fillColor = nil
        borderDashLayer.lineWidth = 2
        borderDashLayer.lineDashPattern = [12, 9]
        borderDashLayer.lineCap = .round
    }
    
    func addGestureRecognizers() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(
            target: self,
            action: #selector(handlePinchGesture)
        )
        pinchGestureRecognizer.delegate = self
        addGestureRecognizer(pinchGestureRecognizer)
        
        let rotationGestureRecognizer = UIRotationGestureRecognizer(
            target: self,
            action: #selector(handleRotationGesture)
        )
        rotationGestureRecognizer.delegate = self
        addGestureRecognizer(rotationGestureRecognizer)
    }
}

private extension CanvasCommitedTextView {
    
    @objc func handlePinchGesture(_ gestureRecognizer: UIPinchGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }
        view.transform = view.transform.scaledBy(
            x: gestureRecognizer.scale,
            y: gestureRecognizer.scale
        )
        gestureRecognizer.scale = 1
    }
    
    @objc func handleRotationGesture(_ gestureRecognizer: UIRotationGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }
        view.transform = view.transform.rotated(by: gestureRecognizer.rotation)
        gestureRecognizer.rotation = 0
    }
}

extension CanvasCommitedTextView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}
