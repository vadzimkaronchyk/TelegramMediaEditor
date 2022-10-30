//
//  ColorsView.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 17.10.22.
//

import UIKit

final class ColorsView: UIView {
    
    private let stackView = UIStackView()
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    )
    private let pageControl = UIPageControl()
    
    var selectedColor: HSBColor = .black {
        didSet { dataSource.selectedColor = selectedColor }
    }
    
    var onColorChanged: Closure<HSBColor>?
    
    private var longPressedItem: ColorsItem?
    
    private lazy var collectionViewLayout: UICollectionViewCompositionalLayout = {
        .init(
            sectionProvider: { section, environment in
                let section = NSCollectionLayoutSection.colors(
                    contentSize: environment.container.contentSize,
                    horizontalGroupItemsCount: self.itemsCountPerPage(traitCollection: environment.traitCollection) / 2
                )
                section.visibleItemsInvalidationHandler = { (items, offset, environment) in
                    let page = Int(offset.x / environment.container.contentSize.width)
                    self.handlePageChange(page)
                }
                
                return section
            },
            configuration: {
                let configuration = UICollectionViewCompositionalLayoutConfiguration()
                configuration.scrollDirection = .vertical
                return configuration
            }()
        )
    }()
    
    private lazy var dataSource = ColorsDataSource(collectionView: collectionView)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        [#selector(UIResponderStandardEditActions.delete)].contains(action)
    }
    
    override func delete(_ sender: Any?) {
        guard let longPressedItem = longPressedItem else { return }
        dataSource.deleteItem(longPressedItem)
        reloadPageControlPages()
        self.longPressedItem = nil
    }
}

private extension ColorsView {
    
    func setupLayout() {
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 82)
        ])
    }
    
    func setupViews() {
        setupStackView()
        setupCollectionView()
        setupPageControl()
        setupDataSource()
        addGestureRecognizers()
    }
    
    func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.addArrangedSubviews([collectionView, pageControl])
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = false
        collectionView.register(ColorCell.self)
        collectionView.register(AddColorCell.self)
    }
    
    func setupPageControl() {
        pageControl.hidesForSinglePage = true
        pageControl.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)
    }
    
    func setupDataSource() {
        dataSource.reload([.add])
        pageControl.numberOfPages = 1
    }
    
    func addGestureRecognizers() {
        collectionView.addGestureRecognizer(UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPressGesture)
        ))
    }
    
    func handlePageChange(_ page: Int) {
        guard pageControl.currentPage != page else { return }
        pageControl.currentPage = page
    }
    
    func reloadPageControlPages() {
        let allItemsCount = dataSource.items.count
        let itemsCountPerPage = itemsCountPerPage(traitCollection: traitCollection)
        pageControl.numberOfPages = Int(ceil(Double(allItemsCount)/Double(itemsCountPerPage)))
    }
    
    func itemsCountPerPage(traitCollection: UITraitCollection) -> Int {
        (traitCollection.horizontalSizeClass == .regular ? 8 : 5) * 2
    }
}

private extension ColorsView {
    
    @objc func pageControlChanged(_ pageControl: UIPageControl) {
        let page = pageControl.currentPage
        let itemsCountPerPage = itemsCountPerPage(traitCollection: traitCollection)
        collectionView.scrollToItem(
            at: IndexPath(row: page * itemsCountPerPage, section: 0),
            at: .top,
            animated: true
        )
    }
    
    @objc func handleLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        
        let location = gestureRecognizer.location(in: gestureRecognizer.view)
        guard let indexPath = collectionView.indexPathForItem(at: location) else {
            return
        }
        
        let item = dataSource.item(for: indexPath)
        
        guard item != .add, let cell = collectionView.cellForItem(at: indexPath) else {
            return
        }
        
        cell.becomeFirstResponder()
        let menuController = UIMenuController.shared
        menuController.showMenu(from: cell, rect: cell.bounds)
        
        longPressedItem = item
    }
}

extension ColorsView: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let item = dataSource.item(for: indexPath) else { return }
        switch item {
        case .view(let model):
            selectedColor = model.color
            onColorChanged?(model.color)
        case .add:
            dataSource.insertItems(
                [.view(.init(color: selectedColor))],
                beforeItem: .add
            )
            reloadPageControlPages()
        }
    }
}

extension NSCollectionLayoutSection {
    
    static func colors(contentSize: CGSize, horizontalGroupItemsCount: Int) -> NSCollectionLayoutSection {
        let itemSize = 30.0
        let interitemSpacing = (contentSize.width - (Double(horizontalGroupItemsCount)*itemSize)) / Double(horizontalGroupItemsCount-1)
        
        let horizontalGroup: NSCollectionLayoutGroup = {
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                ),
                subitem: .init(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )),
                count: horizontalGroupItemsCount
            )
            group.interItemSpacing = .fixed(interitemSpacing)
            return group
        }()
        
        let verticalGroup: NSCollectionLayoutGroup = {
            let count = 2
            let interitemSpacing = (contentSize.height - (Double(count)*itemSize)) / Double(count-1)
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                ),
                subitem: horizontalGroup,
                count: count
            )
            group.interItemSpacing = .fixed(interitemSpacing)
            return group
        }()
        
        let section = NSCollectionLayoutSection(group: verticalGroup)
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = interitemSpacing
        
        return section
    }
}
