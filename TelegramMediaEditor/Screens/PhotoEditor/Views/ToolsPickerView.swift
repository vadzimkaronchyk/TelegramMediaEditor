//
//  ToolsPickerView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/11/22.
//

import UIKit

final class ToolsPickerView: UIView {
    
    private let toolsStackView = UIStackView()
    private let penView = PenView()
    private let brushView = BrushView()
    private let neonBrushView = NeonBrushView()
    private let pencilView = PencilView()
    private let lassoView = LassoView()
    private let eraserView = EraserView()
    private let bottomGradientLayer = CAGradientLayer()
    
    private lazy var selectedToolView: UIView = penView
    
    private var runningAnimators = [UIViewPropertyAnimator]()
    
    private let selectedPenOffset = 16.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupLayout()
        setupViews()
        setupLayers()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let height = 16.0
        bottomGradientLayer.frame = .init(
            x: toolsStackView.frame.minX,
            y: toolsStackView.frame.maxY - height,
            width: toolsStackView.frame.width,
            height: height
        )
    }
}

// MARK: - Setup methods

private extension ToolsPickerView {
    
    func setupLayout() {
        addSubview(toolsStackView)
        
        toolsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toolsStackView.heightAnchor.constraint(equalToConstant: 88),
            toolsStackView.widthAnchor.constraint(equalToConstant: 240),
            toolsStackView.topAnchor.constraint(equalTo: topAnchor),
            toolsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            toolsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            toolsStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func setupViews() {
        setupView()
        setupToolsStackView()
        setupToolViews()
    }
    
    func setupView() {
        clipsToBounds = true
    }
    
    func setupToolsStackView() {
        toolsStackView.axis = .horizontal
        toolsStackView.distribution = .fillEqually
        toolsStackView.spacing = 24
    }
    
    func setupToolViews() {
        toolsStackView.addArrangedSubview(penView)
        penView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(toolViewTapped)
        ))
        [brushView, neonBrushView, pencilView, lassoView, eraserView].forEach {
            toolsStackView.addArrangedSubview($0)
            $0.transform = .init(translationX: 0, y: selectedPenOffset)
            $0.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(toolViewTapped)
            ))
        }
    }
    
    func setupLayers() {
        layer.addSublayer(bottomGradientLayer)
        bottomGradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        bottomGradientLayer.locations = [0.0, 1.0]
    }
}

// MARK: - Actions

private extension ToolsPickerView {
    
    @objc func toolViewTapped(_ sender: UITapGestureRecognizer) {
        guard
            runningAnimators.isEmpty,
            let view = sender.view,
            selectedToolView != view
        else { return }
        
        let hideAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeIn) {
            self.selectedToolView.transform = .init(translationX: 0, y: self.selectedPenOffset)
        }
        let showAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) {
            view.transform = .init(translationX: 0, y: 0)
        }
        showAnimator.addCompletion { _ in
            self.selectedToolView = view
            self.runningAnimators.removeAll()
        }
        
        runningAnimators.append(contentsOf: [
            hideAnimator,
            showAnimator
        ])
        
        hideAnimator.startAnimation()
        showAnimator.startAnimation()
    }
}
