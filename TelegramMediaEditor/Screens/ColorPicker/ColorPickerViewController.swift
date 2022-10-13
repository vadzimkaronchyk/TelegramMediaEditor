//
//  ColorPickerViewController.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/13/22.
//

import UIKit

final class ColorPickerViewController: UIViewController {
    
    private lazy var eyeDropperBarButtonItem = UIBarButtonItem(
        image: .init(named: "eyedropper"),
        style: .plain,
        target: self,
        action: #selector(eyeDropperBarButtonItemTapped)
    )
    private lazy var closeBarButtonItem = UIBarButtonItem(
        image: .init(named: "close"),
        style: .plain,
        target: self,
        action: #selector(closeBarButtonItemTapped)
    )
    private let contentStackView = UIStackView()
    private let pickerTypeSegmentedControl = UISegmentedControl()
    private let gridView = ColorPickerGridView()
    private let spectrumView = ColorPickerSpectrumView()
    private let slidersView = ColorPickerSlidersView()
    private let opacityView = ColorPickerOpacityView()
    private let separatorView = ColorPickerSeparatoView()
    private let colorsView = ColorPickerColorsView()
    
    private var pickerTypeViews: [UIView] {
        [gridView, spectrumView, slidersView]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupViews()
        selectPickerTypeView(atIndex: 0)
    }
}

private extension ColorPickerViewController {
    
    func setupLayout() {
        view.addSubview(contentStackView)
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        gridView.translatesAutoresizingMaskIntoConstraints = false
        spectrumView.translatesAutoresizingMaskIntoConstraints = false
        slidersView.translatesAutoresizingMaskIntoConstraints = false
        opacityView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        colorsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            gridView.widthAnchor.constraint(equalTo: gridView.heightAnchor, multiplier: 358/328),
            spectrumView.widthAnchor.constraint(equalTo: spectrumView.heightAnchor, multiplier: 358/328),
            slidersView.widthAnchor.constraint(equalTo: slidersView.heightAnchor, multiplier: 358/328),
            opacityView.heightAnchor.constraint(equalToConstant: 58),
            separatorView.heightAnchor.constraint(equalToConstant: 39),
            colorsView.heightAnchor.constraint(equalToConstant: 82)
        ])
    }
    
    func setupViews() {
        setupNavigationItem()
        setupEyeDropperBarButtonItem()
        setupCloseBarButtonItem()
        setupView()
        setupContentStackView()
        setupPickerTypeSegmentedControl()
    }
    
    func setupNavigationItem() {
        navigationItem.setLeftBarButton(eyeDropperBarButtonItem, animated: false)
        navigationItem.setRightBarButton(closeBarButtonItem, animated: false)
        navigationItem.title = "Colors"
        
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
    }
    
    func setupEyeDropperBarButtonItem() {
        eyeDropperBarButtonItem.tintColor = .white
    }
    
    func setupCloseBarButtonItem() {
        closeBarButtonItem.tintColor = .white
    }
    
    func setupView() {
        view.backgroundColor = .init(white: 0.1, alpha: 0.99)
    }
    
    func setupContentStackView() {
        contentStackView.axis = .vertical
        contentStackView.spacing = 4
        contentStackView.addArrangedSubviews([
            pickerTypeSegmentedControl,
            gridView,
            spectrumView,
            slidersView,
            opacityView,
            separatorView,
            colorsView
        ])
    }
    
    func setupPickerTypeSegmentedControl() {
        let normalTextAttributes: [NSAttributedString.Key: AnyObject] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 13, weight: .medium),
        ]
        let selectedTextAttributes: [NSAttributedString.Key: AnyObject] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
        ]
        pickerTypeSegmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        pickerTypeSegmentedControl.setTitleTextAttributes(normalTextAttributes, for: .highlighted)
        pickerTypeSegmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        pickerTypeSegmentedControl.insertSegment(withTitle: "Grid", at: 0, animated: false)
        pickerTypeSegmentedControl.insertSegment(withTitle: "Spectrum", at: 1, animated: false)
        pickerTypeSegmentedControl.insertSegment(withTitle: "Sliders", at: 2, animated: false)
        pickerTypeSegmentedControl.backgroundColor = .secondaryLabel
        pickerTypeSegmentedControl.selectedSegmentTintColor = .darkGray
        pickerTypeSegmentedControl.selectedSegmentIndex = 0
        pickerTypeSegmentedControl.addTarget(self, action: #selector(pickerTypeSegmentedControlChanged), for: .valueChanged)
    }
    
    func selectPickerTypeView(atIndex index: Int) {
        pickerTypeViews.enumerated().forEach {
            $1.isHidden = $0 != index
        }
    }
}

// MARK: - Actions

private extension ColorPickerViewController {
    
    @objc func eyeDropperBarButtonItemTapped(_ sender: UIBarButtonItem) {
    }
    
    @objc func closeBarButtonItemTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @objc func pickerTypeSegmentedControlChanged(_ sender: UISegmentedControl) {
        selectPickerTypeView(atIndex: sender.selectedSegmentIndex)
    }
}
