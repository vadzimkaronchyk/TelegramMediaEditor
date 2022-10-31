//
//  BottomControlsView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/27/22.
//

import UIKit

final class BottomControlsView: UIView {
    
    private let toolsSegmentedControl = UISegmentedControl()
    private let cancelButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    private let activityIndicatorView = UIActivityIndicatorView(style: .medium)
    private let contentStackView = UIStackView()
    
    var onDrawingToolSelected: VoidClosure?
    var onTextToolSelected: VoidClosure?
    var onCancelTapped: VoidClosure?
    var onSaveTapped: VoidClosure?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSaveButtonEnabled(_ enabled: Bool) {
        saveButton.isEnabled = enabled
    }
    
    func setLoadingActive(_ active: Bool) {
        saveButton.isHidden = active
        activityIndicatorView.isHidden = !active
        if active {
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
    }
}

private extension BottomControlsView {
    
    func setupLayout() {
        addSubview(contentStackView)
        
        toolsSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [cancelButton.heightAnchor.constraint(equalTo: cancelButton.widthAnchor),
             saveButton.heightAnchor.constraint(equalTo: saveButton.widthAnchor),
             activityIndicatorView.heightAnchor.constraint(equalToConstant: 33),
             activityIndicatorView.widthAnchor.constraint(equalTo: activityIndicatorView.heightAnchor),
             contentStackView.heightAnchor.constraint(equalToConstant: 33)] +
            NSLayoutConstraint.pinViewToSuperviewConstraints(
                view: contentStackView,
                superview: self
            )
        )
    }
    
    func setupViews() {
        setupToolsSegmentedControl()
        setupCancelButton()
        setupSaveButton()
        setupContentStackView()
        
        activityIndicatorView.isHidden = true
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
        toolsSegmentedControl.backgroundColor = .secondarySystemBackground
        toolsSegmentedControl.insertSegment(withTitle: "Draw", at: 0, animated: false)
        toolsSegmentedControl.insertSegment(withTitle: "Text", at: 1, animated: false)
        toolsSegmentedControl.selectedSegmentIndex = 0
        toolsSegmentedControl.addTarget(self, action: #selector(toolsSegmentedControlValueChanged), for: .valueChanged)
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
    
    func setupContentStackView() {
        contentStackView.alignment = .center
        contentStackView.axis = .horizontal
        contentStackView.distribution = .fill
        contentStackView.spacing = 16
        contentStackView.addArrangedSubviews([
            cancelButton,
            toolsSegmentedControl,
            saveButton,
            activityIndicatorView
        ])
    }
}

private extension BottomControlsView {
    
    @objc func toolsSegmentedControlValueChanged(_ segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            onDrawingToolSelected?()
        case 1:
            onTextToolSelected?()
        default:
            break
        }
    }
    
    @objc func cancelButtonTapped(_ button: UIButton) {
        onCancelTapped?()
    }
    
    @objc func saveButtonTapped(_ button: UIButton) {
        onSaveTapped?()
    }
}
