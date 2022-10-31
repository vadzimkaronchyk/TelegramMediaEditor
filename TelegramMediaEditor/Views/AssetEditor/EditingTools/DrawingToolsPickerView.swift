//
//  DrawingToolsPickerView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/11/22.
//

import UIKit

// TODO: Enum { selected, highlighted } ???

protocol DrawingToolView: UIView {
    var tool: Tool.Drawing { get }
}

final class DrawingToolsPickerView: UIControl {
    
    private let toolsStackView = UIStackView()
    private let penView = PenView()
    private let brushView = BrushView()
    private let neonBrushView = NeonBrushView()
    private let pencilView = PencilView()
    private let lassoView = LassoView()
    private let eraserView = EraserView()
    private let shadowView = DrawingToolsPickerShadowView()
    
    private var highlightedToolView: DrawingToolView?
    private lazy var selectedToolView: DrawingToolView = penView
    
    private var toolViews: [DrawingToolView] {
        [penView, brushView, neonBrushView, pencilView, lassoView, eraserView]
    }
    
    var selectedTool: Tool.Drawing {
        selectedToolView.tool
    }
    
    var onToolSelected: Closure<Tool.Drawing>?
    var onToolHighlighted: Closure<Tool.Drawing>?
    var onToolDehighlighted: VoidClosure?
    
    private var runningAnimators = [UIViewPropertyAnimator]()
    private var highlightedToolOffset: Double { 0 }
    private var selectedToolOffset: Double { 16 }
    private var deselectedToolOffset: Double { 32 }
    
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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let horizontalMaskSize = 20.0
        
        let height = 16.0
        shadowView.frame = .init(
            x: bounds.minX - horizontalMaskSize,
            y: bounds.maxY - height,
            width: bounds.width + 2*horizontalMaskSize,
            height: height
        )
        
        // to avoid clipping tool views when animating
        let maskLayer = CALayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.frame = bounds.insetBy(dx: -2*horizontalMaskSize, dy: 0)
        layer.mask = maskLayer
    }
    
    func dehighlight() {
        guard let highlightedToolView = highlightedToolView else { return }
        dehighlightView(highlightedToolView)
    }
}

// MARK: - Setup methods

private extension DrawingToolsPickerView {
    
    func setupLayout() {
        addSubview(toolsStackView)
        addSubview(shadowView)
        
        toolsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [toolsStackView.heightAnchor.constraint(equalToConstant: 88),
             toolsStackView.topAnchor.constraint(equalTo: topAnchor),
             toolsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
             toolsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
             toolsStackView.bottomAnchor.constraint(equalTo: bottomAnchor)] +
            toolViews.map { $0.widthAnchor.constraint(equalToConstant: 20) }
        )
    }
    
    func setupViews() {
        setupToolsStackView()
        setupToolViews()
    }
    
    func setupToolsStackView() {
        toolsStackView.axis = .horizontal
        toolsStackView.distribution = .equalSpacing
    }
    
    func setupToolViews() {
        let selectedToolIndex = 0
        toolViews.enumerated().forEach {
            $1.transform = .init(
                translationX: 0,
                y: $0 == selectedToolIndex ? selectedToolOffset : deselectedToolOffset
            )
            $1.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(handleToolViewTapGesture)
            ))
        }
        toolsStackView.addArrangedSubviews(toolViews)
    }
}

// MARK: - Actions

private extension DrawingToolsPickerView {
    
    @objc func handleToolViewTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        guard
            runningAnimators.isEmpty,
            let toolView = gestureRecognizer.view as? DrawingToolView
        else { return }
        
        if selectedToolView !== toolView {
            selectView(toolView)
        } else if let highlightedToolView = highlightedToolView {
            dehighlightView(highlightedToolView)
            onToolDehighlighted?()
        } else {
            highlightView(toolView)
            onToolHighlighted?(toolView.tool)
        }
    }
    
    func selectView(_ toolView: DrawingToolView) {
        let hideAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeIn) {
            self.selectedToolView.transform = .init(translationX: 0, y: self.deselectedToolOffset)
        }
        let showAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) {
            toolView.transform = .init(translationX: 0, y: self.selectedToolOffset)
        }
        showAnimator.addCompletion { _ in
            self.selectedToolView = toolView
            self.runningAnimators.removeAll()
        }
        
        runningAnimators.append(contentsOf: [
            hideAnimator,
            showAnimator
        ])
        
        hideAnimator.startAnimation()
        showAnimator.startAnimation()
    }
    
    func highlightView(_ toolView: DrawingToolView) {
        UIView.animateKeyframes(
            withDuration: 0.3,
            delay: 0,
            animations: {
                let highlightedTranslationX = self.bounds.midX - toolView.frame.midX
                UIView.addKeyframe(
                    withRelativeStartTime: 0.0,
                    relativeDuration: 0.25
                ) {
                    for view in self.toolViews where view !== toolView {
                        let width = view.frame.width
                        view.transform = .init(
                            translationX: highlightedTranslationX > 0 ? width : -width,
                            y: view.frame.height
                        )
                    }
                }
                UIView.addKeyframe(
                    withRelativeStartTime: 0,
                    relativeDuration: 1
                ) {
                    toolView.transform = .init(
                        translationX: highlightedTranslationX,
                        y: self.highlightedToolOffset
                    )
                }
            },
            completion: { _ in
                self.highlightedToolView = toolView
            }
        )
    }
    
    func dehighlightView(_ toolView: DrawingToolView) {
        UIView.animateKeyframes(
            withDuration: 0.3,
            delay: 0,
            animations: {
                UIView.addKeyframe(
                    withRelativeStartTime: 0.75,
                    relativeDuration: 1
                ) {
                    for view in self.toolViews where view !== toolView {
                        view.transform = .init(
                            translationX: 0,
                            y: self.deselectedToolOffset
                        )
                    }
                }
                UIView.addKeyframe(
                    withRelativeStartTime: 0,
                    relativeDuration: 1
                ) {
                    toolView.transform = .init(
                        translationX: 0,
                        y: self.selectedToolOffset
                    )
                }
            },
            completion: { _ in
                self.highlightedToolView = nil
            }
        )
    }
}

private final class DrawingToolsPickerShadowView: UIView {
    
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let layer = layer as? CAGradientLayer
        layer?.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        layer?.locations = [0.0, 1.0]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
