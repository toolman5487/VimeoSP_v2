//
//  MainHomeVideoCell.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/11.
//

import Foundation
import UIKit
import SnapKit
import SDWebImage

final class MainHomeVideoCell: UICollectionViewCell {
    
    private lazy var placeholderImage: UIImage? = {
        UIImage(systemName: "icloud.and.arrow.down.fill")?.withTintColor(
            .vimeoWhite.withAlphaComponent(0.4),
            renderingMode: .alwaysOriginal
        )
    }()
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.backgroundColor = UIColor.vimeoWhite.withAlphaComponent(0.1)
        return imageView
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .vimeoWhite
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        label.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .vimeoWhite
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(durationLabel)
        contentView.addSubview(titleLabel)
        
        thumbnailImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(thumbnailImageView.snp.width).multipliedBy(9.0 / 16.0).priority(.high)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(thumbnailImageView.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(thumbnailImageView).inset(8)
            make.width.equalTo(60)
            make.height.equalTo(20)
        }
    }
    
    func configure(with video: MainHomeVideo, isVisible: Bool = true) {
        durationLabel.text = video.formattedDuration
        durationLabel.isHidden = video.formattedDuration == nil
        
        titleLabel.text = video.name
        
        if let urlString = video.thumbnailURL, let url = URL(string: urlString) {
            var options: SDWebImageOptions = [.retryFailed, .scaleDownLargeImages]
            if isVisible {
                options.insert(.highPriority)
            } else {
                options.insert(.lowPriority)
            }
            
            thumbnailImageView.sd_setImage(
                with: url,
                placeholderImage: placeholderImage,
                options: options,
                context: [.imageScaleFactor: UIScreen.main.scale]
            )
        } else {
            thumbnailImageView.image = placeholderImage
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.sd_cancelCurrentImageLoad()
        durationLabel.text = nil
        durationLabel.isHidden = true
        titleLabel.text = nil
    }
}

