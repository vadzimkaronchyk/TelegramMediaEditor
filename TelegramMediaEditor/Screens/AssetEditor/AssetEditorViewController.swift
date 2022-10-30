//
//  AssetEditorViewController.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/10/22.
//

import UIKit
import Photos
import AVFoundation

final class AssetEditorViewController: UIViewController {
    
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
    private let assetImageView = UIImageView()
    private let canvasView = CanvasView()
    private let editingToolsView = EditingToolsView()
    
    private(set) var isDrawingSaved = false
    private var drawingColor: HSBColor = .white
    
    private let asset: PHAsset
    private let imageManager = PHCachingImageManager()
    
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

private extension AssetEditorViewController {
    
    func setupLayout() {
        view.addSubview(assetImageView)
        view.addSubview(canvasView)
        view.addSubview(editingToolsView)
        
        assetImageView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        editingToolsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            assetImageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            assetImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            assetImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            assetImageView.bottomAnchor.constraint(equalTo: editingToolsView.topAnchor),
            canvasView.topAnchor.constraint(equalTo: assetImageView.topAnchor),
            canvasView.leadingAnchor.constraint(equalTo: assetImageView.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: assetImageView.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: assetImageView.bottomAnchor),
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
        setupAssetImageView()
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
    
    func setupAssetImageView() {
        assetImageView.contentMode = .scaleAspectFill
        assetImageView.clipsToBounds = true
    }
    
    func setupCanvasView() {
        canvasView.updateActiveTool(.drawing(.pen))
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
        editingToolsView.onToolSelected = { [weak self] tool in
            self?.canvasView.updateActiveTool(tool)
        }
        editingToolsView.onAddShapeTapped = { [weak self] view in
            self?.presentShapesPopover(sourceView: view)
        }
        editingToolsView.onCancelTapped = { [weak self] in
            self?.dismiss()
        }
        editingToolsView.onSaveTapped = { [weak self] in
            self?.saveDrawing()
        }
        editingToolsView.onStrokeSizeChanged = { [weak self] value in
            self?.canvasView.lineWidth = value
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
            self?.assetImageView.image = image
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
    
    func saveDrawing() {
        switch asset.mediaType {
        case .video:
            let image = makeAlphaDrawingSnapshot()
            let imageManager = PHCachingImageManager()
            imageManager.requestAVAsset(
                forVideo: asset,
                options: nil
            ) { [weak self] avAsset, _, _ in
                if let avAsset = avAsset, let image = image.cgImage {
                    DispatchQueue.main.async {
                        self?.setLoadingActive(true)
                    }
                    VideoEditor.editAndSaveAsset(
                        avAsset,
                        withOverlayImage: image
                    ) { [weak self] saved, error in
                        DispatchQueue.main.async {
                            self?.setLoadingActive(false)
                            if saved {
                                self?.isDrawingSaved = true
                                self?.dismiss()
                            } else {
                                self?.presentSavingAssetErrorAlert(error: error)
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.presentSavingAssetErrorAlert()
                    }
                }
            }
        default:
            let image = makeDrawingSnapshot()
            saveToPhotoLibrary(image: image)
        }
    }
    
    func makeDrawingSnapshot() -> UIImage {
        view.snapshot(in: canvasView.frame)
    }
    
    func makeAlphaDrawingSnapshot() -> UIImage {
        canvasView.snapshot()
    }
    
    func setLoadingActive(_ active: Bool) {
        let canUndo = canvasView.canUndo
        canvasView.isUserInteractionEnabled = !active
        undoBarButtonItem.isEnabled = canUndo && !active
        clearBarButtonItem.isEnabled = canUndo && !active
        editingToolsView.setLoadingActive(active)
    }
    
    func dismiss() {
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: true) { [weak self] in
                self?.dismiss(animated: true)
            }
        } else {
            dismiss(animated: true)
        }
    }
    
    func saveToPhotoLibrary(image: UIImage) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetCreationRequest.creationRequestForAsset(from: image)
        } completionHandler: { saved, error in
            DispatchQueue.main.async {
                if saved {
                    self.isDrawingSaved = true
                    self.dismiss()
                } else {
                    self.presentSavingAssetErrorAlert(error: error)
                }
            }
        }
    }
    
    func presentSavingAssetErrorAlert(error: Error? = nil) {
        let alertController = UIAlertController(
            title: error?.localizedDescription ?? "Something went worng",
            message: nil,
            preferredStyle: .alert
        )
        alertController.addAction(.init(title: "Ok", style: .cancel))
        present(alertController, animated: true)
    }
}

// MARK: - Actions

private extension AssetEditorViewController {
    
    @objc func undoBarButtonItemTapped(_ barButtonItem: UIBarButtonItem) {
        canvasView.undo()
    }
    
    @objc func clearBarButtonItemTapped(_ barButtonItem: UIBarButtonItem) {
        canvasView.clearAll()
    }
}

extension AssetEditorViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}

extension AssetEditorViewController {
    
    var drawingImageView: UIImageView {
        if isDrawingSaved {
            let image = makeDrawingSnapshot()
            let imageView = UIImageView(image: image)
            imageView.frame = assetImageView.frame
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            return imageView
        } else {
            return assetImageView
        }
    }
}
