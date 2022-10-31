//
//  TextToolsView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/31/22.
//

import UIKit

final class TextToolsView: UIView {
    
    private let alignmentButton = UIButton(type: .system)
    private let contentStackView = UIStackView()
    
    private var alignment = NSTextAlignment.left
    
    var onTextAlignmentChanged: Closure<NSTextAlignment>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupViews()
        updateTextAlignment(alignment)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTextAlignment(_ alignment: NSTextAlignment) {
        self.alignment = alignment
        switch alignment {
        case .left:
            setAlignmentButtonImage(.init(named: "textLeft"))
        case .right:
            setAlignmentButtonImage(.init(named: "textRight"))
        default:
            setAlignmentButtonImage(.init(named: "textCenter"))
        }
    }
}

private extension TextToolsView {
    
    func setupLayout() {
        addSubview(contentStackView)
        
        alignmentButton.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            alignmentButton.widthAnchor.constraint(equalTo: alignmentButton.heightAnchor),
            contentStackView.heightAnchor.constraint(equalToConstant: 30),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.topAnchor.constraint(equalTo: topAnchor),
            contentStackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setupViews() {
        setupAlignmentButton()
        setupContentStackView()
    }
    
    func setupAlignmentButton() {
        alignmentButton.tintColor = .white
        alignmentButton.addTarget(self, action: #selector(alignmentButtonTapped), for: .touchUpInside)
    }
    
    func setupContentStackView() {
        contentStackView.axis = .horizontal
        contentStackView.spacing = 14
        contentStackView.addArrangedSubviews([
            alignmentButton
        ])
    }
    
    func setAlignmentButtonImage(_ image: UIImage?) {
        alignmentButton.setImage(image, for: .normal)
    }
}

private extension TextToolsView {
    
    @objc func alignmentButtonTapped(_ button: UIButton) {
        let newAlignment = alignment.next
        updateTextAlignment(newAlignment)
        onTextAlignmentChanged?(newAlignment)
    }
}

extension NSTextAlignment {
    
    var next: NSTextAlignment {
        switch self {
        case .left: return .center
        case .right: return .left
        default: return .right
        }
    }
}
