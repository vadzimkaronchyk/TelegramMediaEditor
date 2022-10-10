//
//  EditingToolsView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/10/22.
//

import UIKit

final class EditingToolsView: UIView {
    
    private let toolsStackView = UIStackView()
    private let penView = PenView()
    private let brushView = BrushView()
    private let neonBrushView = NeonBrushView()
    private let pencilView = PencilView()
    private let lassoView = LassoView()
    private let eraserView = EraserView()
    
    private let bottomControlsStackView = UIStackView()
    private let toolsSegmentedControl = UISegmentedControl()
    private let cancelButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    
    var onCancel: (() -> Void)?
    var onSave: (() -> Void)?
    
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
        addSubview(toolsStackView)
        addSubview(bottomControlsStackView)
        
        toolsStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomControlsStackView.translatesAutoresizingMaskIntoConstraints = false
        toolsSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toolsStackView.heightAnchor.constraint(equalToConstant: 88),
            toolsStackView.widthAnchor.constraint(equalToConstant: 240),
            toolsStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            toolsStackView.topAnchor.constraint(equalTo: topAnchor, constant: 33),
            toolsStackView.bottomAnchor.constraint(equalTo: bottomControlsStackView.topAnchor),
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
        setupToolsStackView()
        setupBottomControlsStackView()
        setupToolsSegmentedControl()
        setupCancelButton()
        setupSaveButton()
    }
    
    func setupView() {
        backgroundColor = .black
    }
    
    func setupToolsStackView() {
        toolsStackView.axis = .horizontal
        toolsStackView.distribution = .fillEqually
        toolsStackView.spacing = 24
        toolsStackView.addArrangedSubview(penView)
        toolsStackView.addArrangedSubview(brushView)
        toolsStackView.addArrangedSubview(neonBrushView)
        toolsStackView.addArrangedSubview(pencilView)
        toolsStackView.addArrangedSubview(lassoView)
        toolsStackView.addArrangedSubview(eraserView)
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
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        onCancel?()
    }
    
    @objc private func saveButtonTapped(_ sender: UIButton) {
        onSave?()
    }
}
