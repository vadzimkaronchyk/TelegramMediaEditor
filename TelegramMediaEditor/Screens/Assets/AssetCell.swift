//
//  AssetCell.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/10/22.
//

import UIKit

final class AssetCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    private let durationLabel = UILabel()
    
    var assetIdentifier: String?
    
    static let reuseIdentifer = "AssetCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupLayout()
        setupViews()
    }
    
    private func setupLayout() {
        contentView.addSubview(imageView)
        contentView.addSubview(durationLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            durationLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            durationLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupViews() {
        setupImageView()
        setupDurationLabel()
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
    
    private func setupDurationLabel() {
        durationLabel.textColor = .white
        durationLabel.font = .systemFont(ofSize: 13, weight: .medium)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        durationLabel.text = ""
        durationLabel.isHidden = true
    }
    
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    func setDuration(_ duration: TimeInterval) {
        if duration > 0 {
            let formatter: DateComponentsFormatter = duration >= 3600 ? .assetHHmmSS : .assetmmSS
            durationLabel.text = formatter.string(from: duration)
            durationLabel.isHidden = false
        } else {
            durationLabel.isHidden = true
        }
    }
}

private extension DateComponentsFormatter {

    static let assetHHmmSS: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    static let assetmmSS: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .dropTrailing
        return formatter
    }()
}
