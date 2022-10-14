//
//  ColorPickerViewController.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/13/22.
//

import UIKit

protocol ColorPicker: UIView {
    var onColorSelected: Closure<HSBColor>? { get set }
    func updateColor(_ color: HSBColor)
}

final class ColorPickerViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let pickerTypeSegmentedControl = UISegmentedControl()
    private let headerView = ColorPickerHeaderView()
    private let gridView = ColorPickerGridView()
    private let spectrumView = ColorPickerSpectrumView()
    private let rgbView = ColorPickerRGBView()
    private let opacityView = ColorPickerOpacityView()
    private let separatorView = ColorPickerSeparatorView()
    private let colorsView = ColorPickerColorsView()
    
    private var pickerTypeViews: [UIView] {
        [gridView, spectrumView, rgbView]
    }
    
    private var colorPickers: [ColorPicker] {
        [gridView, spectrumView, rgbView, opacityView, colorsView]
    }
    
    private var eyeDropperColorPickerWindow: EyeDropperColorPickerWindow?
    
    var onColorSelected: Closure<HSBColor>?
    
    private(set) var selectedColor: HSBColor = .black
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupViews()
        setupColorPickers()
        setSelectedPickerTypeView(atIndex: 0)
        setSelectedColor(selectedColor)
    }
    
    func setColor(_ color: HSBColor) {
        selectedColor = color
        setSelectedColor(color)
    }
}

private extension ColorPickerViewController {
    
    func setupLayout() {
        view.addSubview(scrollView)
        
        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        gridView.translatesAutoresizingMaskIntoConstraints = false
        spectrumView.translatesAutoresizingMaskIntoConstraints = false
        rgbView.translatesAutoresizingMaskIntoConstraints = false
        opacityView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        colorsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor, constant: -16),
            headerView.heightAnchor.constraint(equalToConstant: 54),
            separatorView.heightAnchor.constraint(equalToConstant: 39)
        ])
    }
    
    func setupViews() {
        setupView()
        setupContentStackView()
        setupPickerTypeSegmentedControl()
        setupHeaderView()
    }
    
    func setupView() {
        view.backgroundColor = .init(white: 0.1, alpha: 0.99)
    }
    
    func setupContentStackView() {
        contentStackView.axis = .vertical
        contentStackView.spacing = 4
        contentStackView.addArrangedSubviews([
            headerView,
            pickerTypeSegmentedControl,
            gridView,
            spectrumView,
            rgbView,
            opacityView,
            separatorView,
            colorsView
        ])
    }
    
    func setupColorPickers() {
        for picker in colorPickers {
            picker.onColorSelected = { [weak self, weak picker] color in
                self?.setSelectedColor(color, sender: picker)
                self?.onColorSelected?(color)
            }
        }
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
        pickerTypeSegmentedControl.selectedSegmentIndex = 0
        pickerTypeSegmentedControl.addTarget(self, action: #selector(pickerTypeSegmentedControlChanged), for: .valueChanged)
    }
    
    func setupHeaderView() {
        headerView.onEyeDropperTapped = { [weak self] in
            self?.showEyeDropperColorPicker()
        }
        headerView.onEyeDropperLongPressed = { [weak self] gestureRecognizer in
            guard let self = self else { return }
            self.showEyeDropperColorPicker(gestureRecognizer: gestureRecognizer)
        }
        headerView.onCloseTapped = { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
    func setSelectedPickerTypeView(atIndex index: Int) {
        pickerTypeViews.enumerated().forEach {
            $1.isHidden = $0 != index
        }
    }
    
    func setSelectedColor(_ color: HSBColor, sender: ColorPicker? = nil) {
        headerView.updateColor(color)
        for picker in colorPickers where picker !== sender {
            picker.updateColor(color)
        }
    }
}

// MARK: - Actions

private extension ColorPickerViewController {
    
    @objc func pickerTypeSegmentedControlChanged(_ segmentedControl: UISegmentedControl) {
        rgbView.endEditing(true)
        setSelectedPickerTypeView(atIndex: segmentedControl.selectedSegmentIndex)
    }
    
    func showEyeDropperColorPicker(gestureRecognizer: UIGestureRecognizer? = nil) {
        guard
            let windowScene = UIWindowScene.focused,
            let currentWindow = UIWindow.keyWindow as? AppWindow
        else { return }
        
        let location = gestureRecognizer?.location(in: currentWindow)
        let presentingViewController = presentingViewController
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            let colorPickerWindow = EyeDropperColorPickerWindow(
                windowScene: windowScene,
                bottomWindow: currentWindow,
                initialLocation: location
            )
            self.eyeDropperColorPickerWindow = colorPickerWindow
            currentWindow.receivingTouchesWindow = colorPickerWindow
            colorPickerWindow.onColorSelected = { [weak presentingViewController] color in
                presentingViewController?.present(self, animated: true)
                currentWindow.makeKeyAndVisible()
                self.eyeDropperColorPickerWindow = nil
                self.setColor(color)
                self.onColorSelected?(color)
            }
            colorPickerWindow.makeKeyAndVisible()
        }
    }
}
