//
//  ColorsDataSource.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 17.10.22.
//

import UIKit

struct ColorModel: Hashable {
    
    let id: UUID
    let color: HSBColor
    
    init(id: UUID = .init(), color: HSBColor) {
        self.id = id
        self.color = color
    }
}

enum ColorsSection: CaseIterable {
    case colors
}

enum ColorsItem: Hashable {
    case view(ColorModel)
    case add
}

final class ColorsDataSource {
    
    var selectedColor: HSBColor = .black {
        didSet { reloadData() }
    }
    
    var items: [ColorsItem] {
        dataSource.snapshot().itemIdentifiers(inSection: .colors)
    }
    
    private lazy var dataSource = UICollectionViewDiffableDataSource<ColorsSection, ColorsItem>(
        collectionView: collectionView
    ) { [weak self] collectionView, indexPath, item in
        switch item {
        case .view(let model):
            let cell: ColorCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configuration = .init(
                color: model.color.uiColor,
                isSelected: model.color == self?.selectedColor
            )
            return cell
        case .add:
            let cell: AddColorCell = collectionView.dequeueReusableCell(for: indexPath)
            return cell
        }
    }
    
    private let collectionView: UICollectionView
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    func insertItems(_ items: [ColorsItem], beforeItem item: ColorsItem) {
        var snapshot = dataSource.snapshot()
        snapshot.insertItems(items, beforeItem: item)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func deleteItem(_ item: ColorsItem) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([item])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func reload(_ items: [ColorsItem]) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([.colors])
        snapshot.appendItems(items, toSection: .colors)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func item(for indexPath: IndexPath) -> ColorsItem? {
        dataSource.itemIdentifier(for: indexPath)
    }
}

private extension ColorsDataSource {
    
    func reloadData() {
        var snapshot = dataSource.snapshot()
        snapshot.reloadSections([.colors])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
