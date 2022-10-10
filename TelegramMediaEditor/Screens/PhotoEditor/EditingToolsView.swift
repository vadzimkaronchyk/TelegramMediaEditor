//
//  EditingToolsView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/10/22.
//

import UIKit

final class EditingToolsView: UIView {
    
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
        addSubview(toolsSegmentedControl)
        addSubview(cancelButton)
        addSubview(saveButton)
        
        toolsSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toolsSegmentedControl.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 16),
            toolsSegmentedControl.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -16),
            toolsSegmentedControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            cancelButton.widthAnchor.constraint(equalToConstant: 33),
            cancelButton.heightAnchor.constraint(equalTo: cancelButton.widthAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            cancelButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            saveButton.widthAnchor.constraint(equalToConstant: 33),
            saveButton.heightAnchor.constraint(equalTo: saveButton.widthAnchor),
            saveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            saveButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    func setupViews() {
        setupView()
        setupCancelButton()
        setupSaveButton()
        setupToolsSegmentedControl()
    }
    
    func setupView() {
        backgroundColor = .black
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
