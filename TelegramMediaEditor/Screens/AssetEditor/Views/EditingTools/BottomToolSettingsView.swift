//
//  BottomToolSettingsView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/27/22.
//

import UIKit

final class BottomToolSettingsView: UIView {
    
    private let backButton = UIButton(type: .system)
    private let sizeSlider = ToolSizeSlider()
    private let strokeShapeButton = TitleImageButton(type: .system)
    private let contentStackView = UIStackView()
    
    var onBackTapped: VoidClosure?
    var onStrokeShapeTapped: Closure<UIView>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateStrokeShape(_ strokeShape: StrokeShape) {
        strokeShapeButton.setTitle(strokeShape.title, for: .normal)
        strokeShapeButton.setImage(.init(named: strokeShape.imageName), for: .normal)
    }
}

private extension BottomToolSettingsView {
    
    func setupLayout() {
        addSubview(contentStackView)
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        sizeSlider.translatesAutoresizingMaskIntoConstraints = false
        strokeShapeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [backButton.heightAnchor.constraint(equalTo: backButton.widthAnchor),
             sizeSlider.heightAnchor.constraint(equalToConstant: 28),
             strokeShapeButton.widthAnchor.constraint(equalToConstant: 74),
             contentStackView.heightAnchor.constraint(equalToConstant: 33)] +
            NSLayoutConstraint.pinViewToSuperviewConstraints(
                view: contentStackView,
                superview: self
            )
        )
    }
    
    func setupViews() {
        setupBackButton()
        setupContentStackView()
        setupStrokeShapeButton()
        updateStrokeShape(.arrow)
    }
    
    func setupBackButton() {
        backButton.tintColor = .white
        backButton.setImage(.init(named: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    func setupStrokeShapeButton() {
        strokeShapeButton.tintColor = .white
        strokeShapeButton.titleLabel?.textColor = .white
        strokeShapeButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        strokeShapeButton.addTarget(self, action: #selector(strokeShapeButtonTapped), for: .touchUpInside)
    }
    
    func setupContentStackView() {
        contentStackView.alignment = .center
        contentStackView.axis = .horizontal
        contentStackView.distribution = .fill
        contentStackView.spacing = 8
        contentStackView.addArrangedSubviews([
            backButton,
            sizeSlider,
            strokeShapeButton
        ])
    }
}

private extension BottomToolSettingsView {
    
    @objc func backButtonTapped(_ button: UIButton) {
        onBackTapped?()
    }
    
    @objc func strokeShapeButtonTapped(_ button: UIButton) {
        onStrokeShapeTapped?(button)
    }
}
