//
//  PhotosViewController.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/9/22.
//

import UIKit
import Photos

final class PhotosViewController: UICollectionViewController {
    
    var onAccessRestricted: (() -> Void)?
    var onPhotoSelected: ((PHAsset) -> Void)?
    
    private var fetchResult: PHFetchResult<PHAsset>?
    private let imageManager = PHCachingImageManager()
    private let targetSize: CGSize = {
        let width = UIScreen.main.bounds.width
        let size = width / 3
        return CGSize(width: size, height: size)
    }()
    
    init() {
        let fraction: CGFloat = 1 / 3
        let inset: CGFloat = 1
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(fraction))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        
        let collectionViewLayout = UICollectionViewCompositionalLayout(section: section)
        super.init(collectionViewLayout: collectionViewLayout)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func loadView() {
        super.loadView()
        
        setupViews()
        loadPhotos()
    }
}

extension PhotosViewController {
    
    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        fetchResult?.count ?? 0
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let fetchResult = fetchResult else { return .init() }
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCell.reuseIdentifer,
            for: indexPath
        ) as! PhotoCell
        let asset = fetchResult.object(at: indexPath.item)
        imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: nil
        ) { image, info in
            cell.image = image
        }
        return cell
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let fetchResult = fetchResult else { return }
        let asset = fetchResult.object(at: indexPath.item)
        onPhotoSelected?(asset)
    }
}

extension PhotosViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let fetchResult = fetchResult else { return }
        DispatchQueue.main.async {
            self.imageManager.startCachingImages(
                for: indexPaths.map { fetchResult.object(at: $0.item) },
                targetSize: self.targetSize,
                contentMode: .aspectFill,
                options: nil
            )
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        guard let fetchResult = fetchResult else { return }
        DispatchQueue.main.async {
            self.imageManager.stopCachingImages(
                for: indexPaths.map{ fetchResult.object(at: $0.item) },
                targetSize: self.targetSize,
                contentMode: .aspectFill,
                options: nil
            )
        }
    }
}

private extension PhotosViewController {
    
    func setupViews() {
        view.backgroundColor = .black
        collectionView.backgroundColor = .clear
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseIdentifer)
    }
    
    func loadPhotos() {
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        fetchResult = PHAsset.fetchAssets(with: .image, options: options)
    }
}
