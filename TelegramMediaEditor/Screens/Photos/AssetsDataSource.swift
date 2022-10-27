//
//  AssetsDataSource.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/27/22.
//

import Photos
import UIKit

final class AssetsDataSource: NSObject {
    
    weak var collectionView: UICollectionView?
    
    var assetCount: Int {
        fetchAssets?.count ?? 0
    }
    
    private(set) var selectedIndexPath: IndexPath?
    
    private var fetchAssets: PHFetchResult<PHAsset>?
    private let imageManager = PHCachingImageManager()
    private let targetSize: CGSize = {
        let width = UIScreen.main.bounds.width * UIScreen.main.scale
        let size = width / 3
        return .init(width: size, height: size)
    }()
    
    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }
    
    func loadAssets() {
        let imagePredicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        let videoPredicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [imagePredicate, videoPredicate])
        let options = PHFetchOptions()
        options.predicate = predicate
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        fetchAssets = PHAsset.fetchAssets(with: options)
    }
    
    func clearCache() {
        imageManager.stopCachingImagesForAllAssets()
    }
    
    func asset(at indexPath: IndexPath) -> PHAsset? {
        guard indexPath.item < assetCount else { return nil }
        return fetchAssets?.object(at: indexPath.item)
    }
    
    func assets(at indexPaths: [IndexPath]) -> [PHAsset]? {
        guard let fetchAssets = fetchAssets else { return nil }
        return indexPaths.map { fetchAssets.object(at: $0.item) }
    }
    
    func requestImage(at indexPath: IndexPath, completion: @escaping (UIImage?) -> Void) {
        guard let fetchAssets = fetchAssets else { return }
        
        let asset = fetchAssets.object(at: indexPath.item)
        imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: nil
        ) { image, info in
            completion(image)
        }
    }
    
    func prefetchAssets(at indexPaths: [IndexPath]) {
        guard let assets = assets(at: indexPaths) else { return }
        imageManager.startCachingImages(
            for: assets,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: nil
        )
    }
    
    func cancelPrefetchingForAssets(at indexPaths: [IndexPath]) {
        guard let assets = assets(at: indexPaths) else { return }
        imageManager.stopCachingImages(
            for: assets,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: nil
        )
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}

private extension AssetsDataSource {
    
    func performBatchUpdates(changes: PHFetchResultChangeDetails<PHAsset>) {
        guard let collectionView = collectionView else { return }
        collectionView.performBatchUpdates {
            if let removed = changes.removedIndexes, !removed.isEmpty {
                collectionView.deleteItems(at: removed.map {
                    .init(item: $0, section: 0)
                })
            }
            if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                collectionView.insertItems(at: inserted.map {
                    .init(item: $0, section: 0)
                })
            }
            if let changed = changes.changedIndexes, !changed.isEmpty {
                collectionView.reloadItems(at: changed.map {
                    .init(item: $0, section: 0)
                })
            }
            changes.enumerateMoves { fromIndex, toIndex in
                collectionView.moveItem(
                    at: .init(item: fromIndex, section: 0),
                    to: .init(item: toIndex, section: 0)
                )
            }
        }
    }
    
    func reloadCollectionView() {
        collectionView?.reloadData()
    }
}

extension AssetsDataSource: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard
            let fetchResult = fetchAssets,
            let changes = changeInstance.changeDetails(for: fetchResult)
        else { return }
        
        DispatchQueue.main.async { [self] in
            self.fetchAssets = changes.fetchResultAfterChanges
            
            if changes.hasIncrementalChanges {
                performBatchUpdates(changes: changes)
            } else {
                reloadCollectionView()
            }
        }
    }
}
