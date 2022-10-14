//
//  UICollectionViewExtensions.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 17.10.22.
//

import UIKit

extension UICollectionReusableView {
    
    static var reuseIdentifier: String {
        String(describing: Self.self)
    }
}

extension UICollectionView {
    
    func register<T: UICollectionReusableView>(_ cellType: T.Type = T.self) {
        register(cellType, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionReusableView>(_ cellType: T.Type = T.self, for indexPath: IndexPath) -> T {
        dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as! T
    }
}
