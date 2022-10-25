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
    private let canvasView = CanvasView()
    private let editingToolsView = EditingToolsView()
    
    private let asset: PHAsset
    private let imageManager = PHCachingImageManager()
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        photoImageView.isHidden = false
    }
}

private extension PhotoEditorViewController {
    
    func setupLayout() {
        view.addSubview(photoImageView)
        view.addSubview(canvasView)
        view.addSubview(editingToolsView)
        
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        editingToolsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            photoImageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            photoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            photoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: editingToolsView.topAnchor),
            canvasView.topAnchor.constraint(equalTo: photoImageView.topAnchor),
            canvasView.leadingAnchor.constraint(equalTo: photoImageView.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: photoImageView.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: photoImageView.bottomAnchor),
            editingToolsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            editingToolsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            editingToolsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    func setupViews() {
        setupView()
        setupNavigationItem()
        setupUndoBarButtonItem()
        setupClearBarButtonItem()
        setupPhotoImageView()
        setupCanvasView()
        setupEditingToolsView()
        updateDrawingColor(.white)
    }
    
    func setupView() {
        view.backgroundColor = .black
    }
    
    func setupNavigationItem() {
        undoBarButtonItem.isEnabled = false
        clearBarButtonItem.isEnabled = false
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
        photoImageView.isHidden = true
    }
    
    func setupCanvasView() {
        canvasView.onUndoChanged = { [weak self] in
            guard let self = self else { return }
            let canUndo = self.canvasView.canUndo
            self.undoBarButtonItem.isEnabled = canUndo
            self.clearBarButtonItem.isEnabled = canUndo
            self.editingToolsView.setSaveButtonEnabled(canUndo)
        }
    }
    
    func setupEditingToolsView() {
        editingToolsView.setSaveButtonEnabled(false)
        editingToolsView.onColorsCircleTapped = { [weak self] in
            self?.presentColorPicker()
        }
        editingToolsView.onAddShapeTapped = { [weak self] view in
            self?.presentShapesPopover(sourceView: view)
        }
        editingToolsView.onCancelTapped = { [weak self] in
            self?.dismiss(animated: true)
        }
        editingToolsView.onSaveTapped = { [weak self] in
            self?.dismiss(animated: true)
        }
        editingToolsView.onStrokeShapeTapped = { [weak self] view in
            self?.presentStrokeShapePopover(sourceView: view)
        }
        editingToolsView.onColorSelected = { [weak self] color in
            self?.handleEditingToolsViewSelectedColor(color)
        }
    }
    
    func presentColorPicker() {
        let viewController = ColorPickerViewController()
        viewController.setColor(drawingColor)
        viewController.onColorSelected = { [weak self] color in
            self?.updateDrawingColor(color)
        }
        present(viewController, animated: true)
    }
    
    func presentShapesPopover(sourceView: UIView) {
        let viewController = MenuPopoverViewController<Shape>()
        viewController.menuItems = Shape.allCases
        viewController.onSelected = { [weak viewController] item in
            viewController?.dismiss(animated: true)
        }
        
        presentPopover(
            viewController: viewController,
            sourceView: sourceView,
            contentSize: .init(width: 180, height: 220)
        )
    }
    
    func presentStrokeShapePopover(sourceView: UIView) {
        let viewController = MenuPopoverViewController<StrokeShape>()
        viewController.menuItems = StrokeShape.allCases
        viewController.onSelected = { [weak self, weak viewController] item in
            self?.editingToolsView.updateStrokeShape(item)
            viewController?.dismiss(animated: true)
        }
        
        presentPopover(
            viewController: viewController,
            sourceView: sourceView,
            contentSize: .init(width: 150, height: 88)
        )
    }
    
    func presentPopover(
        viewController: UIViewController,
        sourceView: UIView,
        contentSize: CGSize
    ) {
        viewController.modalPresentationStyle = .popover
        viewController.preferredContentSize = contentSize
        
        guard let presentationController = viewController.popoverPresentationController else { return }
        
        presentationController.delegate = self
        presentationController.permittedArrowDirections = []
        presentationController.popoverLayoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        
        presentationController.sourceView = sourceView
        presentationController.sourceRect = .init(
            origin: .init(
                x: sourceView.bounds.midX - contentSize.width/2,
                y: -sourceView.bounds.midY - contentSize.height/2
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
        canvasView.drawingColor = color.uiColor
        editingToolsView.updateDrawingColor(color)
    }
    
    func handleEditingToolsViewSelectedColor(_ color: HSBColor) {
        drawingColor = color
        canvasView.drawingColor = color.uiColor
    }
}

// MARK: - Actions

private extension PhotoEditorViewController {
    
    @objc func undoBarButtonItemTapped(_ barButtonItem: UIBarButtonItem) {
        canvasView.undo()
    }
    
    @objc func clearBarButtonItemTapped(_ barButtonItem: UIBarButtonItem) {
        canvasView.clearAll()
    }
}

extension PhotoEditorViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}

extension PhotoEditorViewController {
    
    func transitionImageView() -> UIImageView? {
        photoImageView
    }
}
