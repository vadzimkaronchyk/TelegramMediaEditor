//
//  AssetsViewController.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/9/22.
//

import UIKit
import Photos

final class AssetsViewController: UICollectionViewController {
    
    var onAccessRestricted: VoidClosure?
    var onAssetSelected: Closure<(AssetZoomTransition, PHAsset)>?
    
    private var selectedIndexPath: IndexPath?
    
    private lazy var dataSource = AssetsDataSource()
    private let zoomTransition = AssetZoomTransition()
    
    init() {
        super.init(collectionViewLayout: .assets())
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func loadView() {
        super.loadView()
        
        setupViews()
        dataSource.collectionView = collectionView
        
        DispatchQueue.global().async {
            self.dataSource.loadAssets()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        dataSource.clearCache()
    }
}

private extension AssetsViewController {
    
    func setupViews() {
        view.backgroundColor = .black
        collectionView.prefetchDataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(AssetCell.self, forCellWithReuseIdentifier: AssetCell.reuseIdentifer)
    }
}

extension AssetsViewController {
    
    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        dataSource.assetCount
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let asset = dataSource.asset(at: indexPath) else {
            return .init()
        }
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AssetCell.reuseIdentifer,
            for: indexPath
        ) as! AssetCell
        cell.imageView.image = nil
        cell.assetIdentifier = asset.localIdentifier
        dataSource.requestImage(at: asset) { image in
            guard cell.assetIdentifier == asset.localIdentifier else {
                return
            }
            cell.imageView.image = image
        }
        return cell
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let asset = dataSource.asset(at: indexPath) else {
            return
        }
        selectedIndexPath = indexPath
        onAssetSelected?((zoomTransition, asset))
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        
    }
}

extension AssetsViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(
        _ collectionView: UICollectionView,
        prefetchItemsAt indexPaths: [IndexPath]
    ) {
        DispatchQueue.main.async {
            self.dataSource.prefetchAssets(at: indexPaths)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cancelPrefetchingForItemsAt indexPaths: [IndexPath]
    ) {
        DispatchQueue.main.async {
            self.dataSource.cancelPrefetchingForAssets(at: indexPaths)
        }
    }
}

extension AssetsViewController {
    
    var selectedAssetImageView: UIImageView? {
        guard let selectedIndexPath = selectedIndexPath else { return nil }
        let cell = collectionView.cellForItem(at: selectedIndexPath) as? AssetCell
        return cell?.imageView
    }
    
    var firstAssetImageView: UIImageView? {
        let cell = collectionView.cellForItem(at: .init(item: 0, section: 0)) as? AssetCell
        return cell?.imageView
    }
}

private extension UICollectionViewLayout {
    
    static func assets() -> UICollectionViewCompositionalLayout {
        let fraction: CGFloat = 1 / 3
        let inset: CGFloat = 1
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(fraction))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        
        return .init(section: section)
    }
}
