//
//  MenuPopoverViewController.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/12/22.
//

import UIKit

struct MenuPopoverItem {
    let title: String
    let imageName: String
}

final class MenuPopoverViewController: UIViewController {
    
    private let itemsStackView = UIStackView()
    
    var menuItems = [MenuPopoverItem]() {
        didSet { reloadItems(menuItems) }
    }
    
    var onSelected: Closure<MenuPopoverItem>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupViews()
    }
}

private extension MenuPopoverViewController {
    
    func reloadItems(_ items: [MenuPopoverItem]) {
        itemsStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        items.enumerated().forEach { (index, item) in
            let view = MenuPopoverItemView()
            view.onSelected = { [weak self] in
                self?.onSelected?(item)
            }
            let isLastItem = index == items.count - 1
            view.setup(item: item, displaySeparator: !isLastItem)
            itemsStackView.addArrangedSubview(view)
        }
    }
    
    func setupLayout() {
        view.addSubview(itemsStackView)
        itemsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.pinViewToSuperviewConstraints(
            view: itemsStackView,
            superview: view
        ))
    }
    
    func setupViews() {
        view.backgroundColor = .init(red: 0.114, green: 0.114, blue: 0.114, alpha: 0.94)
        itemsStackView.axis = .vertical
        itemsStackView.distribution = .fillEqually
        itemsStackView.spacing = 0
    }
}
