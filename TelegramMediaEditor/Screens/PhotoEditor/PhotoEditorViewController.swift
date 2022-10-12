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
            photoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: editingToolsView.topAnchor),
            editingToolsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            editingToolsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            editingToolsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    func setupViews() {
        setupView()
        setupUndoBarButtonItem()
        setupClearBarButtonItem()
        setupNavigationItem()
        setupPhotoImageView()
        setupEditingToolsView()
    }
    
    func setupView() {
        view.backgroundColor = .black
    }
    
    func setupUndoBarButtonItem() {
        undoBarButtonItem.tintColor = .white
    }
    
    func setupClearBarButtonItem() {
        clearBarButtonItem.tintColor = .white
    }
    
    func setupNavigationItem() {
        navigationItem.setLeftBarButton(undoBarButtonItem, animated: false)
        navigationItem.setRightBarButton(clearBarButtonItem, animated: false)
    }
    
    @objc func undoBarButtonItemTapped(_ sender: UIBarButtonItem) {
    }
    
    @objc func clearBarButtonItemTapped(_ sender: UIBarButtonItem) {
    }
    
    func setupPhotoImageView() {
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
    }
    
    func setupEditingToolsView() {
        editingToolsView.onCancel = { [weak self] in
            self?.onClose?()
        }
        editingToolsView.onSave = { [weak self] in
            self?.onClose?()
        }
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
}
