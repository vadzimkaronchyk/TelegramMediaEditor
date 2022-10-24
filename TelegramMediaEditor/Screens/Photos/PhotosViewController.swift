//
//  PhotosViewController.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/9/22.
//

import UIKit
import Photos

final class PhotosViewController: UICollectionViewController {
    
    var onAccessRestricted: VoidClosure?
    var onPhotoSelected: Closure<(PhotoZoomTransition, PHAsset)>?
    
    private var selectedIndexPath: IndexPath?
    private var fetchResult: PHFetchResult<PHAsset>?
    private let imageManager = PHCachingImageManager()
    private let targetSize: CGSize = {
        let width = UIScreen.main.bounds.width
        let size = width / 3
        return CGSize(width: size, height: size)
    }()
    
    private let photoZoomTransition = PhotoZoomTransition()
    
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
        selectedIndexPath = indexPath
        let asset = fetchResult.object(at: indexPath.item)
        onPhotoSelected?((photoZoomTransition, asset))
    }
}

extension PhotosViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(
        _ collectionView: UICollectionView,
        prefetchItemsAt indexPaths: [IndexPath]
    ) {
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        cancelPrefetchingForItemsAt indexPaths: [IndexPath]
    ) {
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

extension PhotosViewController {
    
    func transitionDidEnd() {
        guard
            let selectedIndexPath = selectedIndexPath,
            let cell = collectionView.cellForItem(at: selectedIndexPath) as? PhotoCell
        else { return }
        
        let cellFrame = collectionView.convert(cell.frame, to: view)
        
        if cellFrame.minY < collectionView.contentInset.top {
            collectionView.scrollToItem(at: selectedIndexPath, at: .top, animated: false)
        } else if cellFrame.maxY > view.frame.height - collectionView.contentInset.bottom {
            collectionView.scrollToItem(at: selectedIndexPath, at: .bottom, animated: false)
        }
    }
    
    func transitionImageView() -> UIImageView? {
        guard let selectedIndexPath = selectedIndexPath else { return nil }
        return getImageViewFromCollectionViewCell(
            collectionView: collectionView,
            selectedIndexPath: selectedIndexPath
        )
    }
    
    func referenceImageViewFrame() -> CGRect? {
        guard let selectedIndexPath = selectedIndexPath else { return nil }
        
        view.layoutIfNeeded()
        collectionView.layoutIfNeeded()
        
        guard let unconvertedFrame = getFrameFromCollectionViewCell(
            collectionView: collectionView,
            selectedIndexPath: selectedIndexPath
        ) else { return nil }
        
        let cellFrame = collectionView.convert(unconvertedFrame, to: view)
        
        if cellFrame.minY < collectionView.contentInset.top {
            return .init(
                x: cellFrame.minX,
                y: collectionView.contentInset.top,
                width: cellFrame.width,
                height: cellFrame.height - (collectionView.contentInset.top - cellFrame.minY)
            )
        }
        
        return cellFrame
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
    
    func getImageViewFromCollectionViewCell(
        collectionView: UICollectionView,
        selectedIndexPath: IndexPath
    ) -> UIImageView? {
        let visibleCells = collectionView.indexPathsForVisibleItems
        
        //If the current indexPath is not visible in the collectionView,
        //scroll the collectionView to the cell to prevent it from returning a nil value
        if !visibleCells.contains(selectedIndexPath) {
            //Scroll the collectionView to the current selectedIndexPath which is offscreen
            collectionView.scrollToItem(
                at: selectedIndexPath,
                at: .centeredVertically,
                animated: false
            )
            
            //Reload the items at the newly visible indexPaths
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
            collectionView.layoutIfNeeded()
            
            let cell = collectionView.cellForItem(at: selectedIndexPath) as? PhotoCell
            return cell?.imageView
        } else {
            let cell = collectionView.cellForItem(at: selectedIndexPath) as? PhotoCell
            return cell?.imageView
        }
        
    }
    
    func getFrameFromCollectionViewCell(
        collectionView: UICollectionView,
        selectedIndexPath: IndexPath
    ) -> CGRect? {
        //Get the currently visible cells from the collectionView
        let visibleCells = collectionView.indexPathsForVisibleItems
        
        //If the current indexPath is not visible in the collectionView,
        //scroll the collectionView to the cell to prevent it from returning a nil value
        if !visibleCells.contains(selectedIndexPath) {
            //Scroll the collectionView to the cell that is currently offscreen
            collectionView.scrollToItem(
                at: selectedIndexPath,
                at: .centeredVertically,
                animated: false
            )
            
            //Reload the items at the newly visible indexPaths
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
            collectionView.layoutIfNeeded()
            
            let cell = collectionView.cellForItem(at: selectedIndexPath) as? PhotoCell
            return cell?.frame
        } else {
            let cell = collectionView.cellForItem(at: selectedIndexPath) as? PhotoCell
            return cell?.frame
        }
    }
}
