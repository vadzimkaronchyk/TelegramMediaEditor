//
//  PhotoEditorViewController.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/10/22.
//

import UIKit
import Photos

final class PhotoEditorViewController: UIViewController {
    
    private lazy var undoBarButtonItem = UIBarButtonItem(
        image: .init(named: "undo"),
        style: .plain,
        target: self,
        action: #selector(undoBarButtonItemTapped)
    )
    private lazy var clearBarButtonItem = UIBarButtonItem(
        title: "Clear All",
        style: .plain,
        target: self,
        action: #selector(clearBarButtonItemTapped)
    )
    private let photoImageView = UIImageView()
    private let editingToolsView = EditingToolsView()
    
    private let asset: PHAsset
    private let imageManager = PHCachingImageManager()
    
    var onClose: VoidClosure?
    
    private var drawingColor: HSBColor = .white
    
    init(asset: PHAsset) {
        self.asset = asset
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        setupLayout()
        setupViews()
        loadImageFromAsset()
    }
}

private extension PhotoEditorViewController {
    
    func setupLayout() {
        view.addSubview(photoImageView)
        view.addSubview(editingToolsView)
        
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        editingToolsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            photoImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: editingToolsView.topAnchor),
            editingToolsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            editingToolsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            editingToolsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    func setupViews() {
        setupView()
        setupNavigationItem()
        setupUndoBarButtonItem()
        setupClearBarButtonItem()
        setupPhotoImageView()
        setupEditingToolsView()
        updateDrawingColor(.white)
    }
    
    func setupView() {
        view.backgroundColor = .black
    }
    
    func setupNavigationItem() {
        navigationItem.setLeftBarButton(undoBarButtonItem, animated: false)
        navigationItem.setRightBarButton(clearBarButtonItem, animated: false)
    }
    
    func setupUndoBarButtonItem() {
        undoBarButtonItem.tintColor = .white
    }
    
    func setupClearBarButtonItem() {
        clearBarButtonItem.tintColor = .white
    }
    
    func setupPhotoImageView() {
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
    }
    
    func setupEditingToolsView() {
        editingToolsView.onColorsCircleTapped = { [weak self] in
            self?.presentColorPicker()
        }
        editingToolsView.onAddShapeTapped = { [weak self] view in
            self?.presentShapesPopover(sourceView: view)
        }
        editingToolsView.onCancelTapped = { [weak self] in
            self?.onClose?()
        }
        editingToolsView.onSaveTapped = { [weak self] in
            self?.onClose?()
        }
        editingToolsView.onColorSelected = { [weak self] color in
            self?.handleEditingToolsViewSelectedColor(color)
        }
    }
    
    func presentColorPicker() {
//        if #available(iOS 14.0, *) {
//            let viewController = UIColorPickerViewController()
//            present(viewController, animated: true)
//        } else {
        let viewController = ColorPickerViewController()
        viewController.setColor(drawingColor)
        viewController.onColorSelected = { [weak self] color in
            self?.updateDrawingColor(color)
        }
        present(viewController, animated: true)
//        }
    }
    
    func presentShapesPopover(sourceView: UIView) {
        let width = 180.0
        let height = 220.0
        
        let viewController = MenuPopoverViewController()
        viewController.menuItems = [
            .init(title: "Rectangle", imageName: "shapeRectangle"),
            .init(title: "Ellipse", imageName: "shapeEllipse"),
            .init(title: "Bubble", imageName: "shapeBubble"),
            .init(title: "Star", imageName: "shapeStar"),
            .init(title: "Arrow", imageName: "shapeArrow")
        ]
        viewController.onSelected = { [weak viewController] item in
            viewController?.dismiss(animated: true)
        }
        viewController.modalPresentationStyle = .popover
        viewController.preferredContentSize = .init(width: width, height: height)
        
        guard let presentationController = viewController.popoverPresentationController else { return }
        
        presentationController.delegate = self
        presentationController.permittedArrowDirections = []
        presentationController.popoverLayoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        
        presentationController.sourceView = sourceView
        presentationController.sourceRect = .init(
            origin: .init(
                x: sourceView.bounds.midX - width/2,
                y: -sourceView.bounds.midY - height/2
            ),
            size: sourceView.bounds.size
        )
        
        viewController.modalTransitionStyle = .crossDissolve
        present(viewController, animated: true)
    }
    
    func loadImageFromAsset() {
        imageManager.requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFill,
            options: nil
        ) { [weak self] image, info in
            self?.photoImageView.image = image
        }
    }
    
    func updateDrawingColor(_ color: HSBColor) {
        drawingColor = color
        editingToolsView.updateDrawingColor(color)
    }
    
    func handleEditingToolsViewSelectedColor(_ color: HSBColor) {
        drawingColor = color
    }
}

// MARK: - Actions

private extension PhotoEditorViewController {
    
    @objc func undoBarButtonItemTapped(_ barButtonItem: UIBarButtonItem) {
    }
    
    @objc func clearBarButtonItemTapped(_ barButtonItem: UIBarButtonItem) {
    }
}

extension PhotoEditorViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}
