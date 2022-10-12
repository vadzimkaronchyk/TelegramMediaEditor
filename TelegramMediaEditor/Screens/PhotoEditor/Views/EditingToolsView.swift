//
//  EditingToolsView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/10/22.
//

import UIKit

final class EditingToolsView: UIView {
    
    private let toolsPickerView = ToolsPickerView()
    private let addShapeButton = UIButton(type: .system)
    private let bottomControlsStackView = UIStackView()
    private let toolsSegmentedControl = UISegmentedControl()
    private let cancelButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    
    var onAddShapeTapped: Closure<UIView>?
    var onCancelTapped: VoidClosure?
    var onSaveTapped: VoidClosure?
    
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
}

// MARK: - Setup methods

private extension EditingToolsView {
    
    func setupLayout() {
        addSubview(toolsPickerView)
        addSubview(addShapeButton)
        addSubview(bottomControlsStackView)
        
        toolsPickerView.translatesAutoresizingMaskIntoConstraints = false
        addShapeButton.translatesAutoresizingMaskIntoConstraints = false
        bottomControlsStackView.translatesAutoresizingMaskIntoConstraints = false
        toolsSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toolsPickerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            toolsPickerView.topAnchor.constraint(equalTo: topAnchor, constant: 33),
            toolsPickerView.bottomAnchor.constraint(equalTo: bottomControlsStackView.topAnchor),
            addShapeButton.heightAnchor.constraint(equalToConstant: 33),
            addShapeButton.widthAnchor.constraint(equalTo: addShapeButton.heightAnchor),
            addShapeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            addShapeButton.bottomAnchor.constraint(equalTo: bottomControlsStackView.topAnchor, constant: -8),
            bottomControlsStackView.heightAnchor.constraint(equalToConstant: 33),
            bottomControlsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            bottomControlsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            bottomControlsStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            cancelButton.heightAnchor.constraint(equalTo: cancelButton.widthAnchor),
            saveButton.heightAnchor.constraint(equalTo: saveButton.widthAnchor),
        ])
    }
    
    func setupViews() {
        setupView()
        setupAddShapeButton()
        setupBottomControlsStackView()
        setupToolsSegmentedControl()
        setupCancelButton()
        setupSaveButton()
    }
    
    func setupView() {
        backgroundColor = .black
    }
    
    func setupAddShapeButton() {
        addShapeButton.tintColor = .white
        addShapeButton.backgroundColor = .white.withAlphaComponent(0.1)
        addShapeButton.layer.cornerRadius = 16.5
        addShapeButton.setImage(.init(named: "add"), for: .normal)
        addShapeButton.addTarget(self, action: #selector(addShapeButtonTapped), for: .touchUpInside)
    }
    
    func setupBottomControlsStackView() {
        bottomControlsStackView.alignment = .center
        bottomControlsStackView.axis = .horizontal
        bottomControlsStackView.distribution = .fill
        bottomControlsStackView.spacing = 16
        bottomControlsStackView.addArrangedSubview(cancelButton)
        bottomControlsStackView.addArrangedSubview(toolsSegmentedControl)
        bottomControlsStackView.addArrangedSubview(saveButton)
    }
    
    func setupToolsSegmentedControl() {
        let normalTextAttributes: [NSAttributedString.Key: AnyObject] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 13, weight: .medium),
        ]
        let selectedTextAttributes: [NSAttributedString.Key: AnyObject] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
        ]
        toolsSegmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        toolsSegmentedControl.setTitleTextAttributes(normalTextAttributes, for: .highlighted)
        toolsSegmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        toolsSegmentedControl.insertSegment(withTitle: "Draw", at: 0, animated: false)
        toolsSegmentedControl.insertSegment(withTitle: "Text", at: 1, animated: false)
        toolsSegmentedControl.backgroundColor = .secondaryLabel
        toolsSegmentedControl.selectedSegmentTintColor = .darkGray
        toolsSegmentedControl.selectedSegmentIndex = 0
    }
    
    func setupCancelButton() {
        cancelButton.tintColor = .white
        cancelButton.setImage(.init(named: "cancel"), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    func setupSaveButton() {
        saveButton.tintColor = .white
        saveButton.setImage(.init(named: "download"), for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
}

// MARK: - Action methods

private extension EditingToolsView {
    
    @objc func addShapeButtonTapped(_ sender: UIButton) {
        onAddShapeTapped?(sender)
    }
    
    @objc func cancelButtonTapped(_ sender: UIButton) {
        onCancelTapped?()
    }
    
    @objc func saveButtonTapped(_ sender: UIButton) {
        onSaveTapped?()
    }
}
