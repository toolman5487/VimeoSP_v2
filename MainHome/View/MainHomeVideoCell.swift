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
    
    private var placeholderImage: UIImage? {
        UIImage(systemName: "photo.fill")?.withTintColor(
            .vimeoWhite.withAlphaComponent(0.4),
            renderingMode: .alwaysOriginal
        )
    }
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
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
        
        thumbnailImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        durationLabel.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(8)
            make.width.equalTo(60)
            make.height.equalTo(20)
        }
    }
    
    func configure(with video: MainHomeVideo) {
        durationLabel.text = video.formattedDuration
        durationLabel.isHidden = video.formattedDuration == nil
        
        if let urlString = video.thumbnailURL, let url = URL(string: urlString) {
            thumbnailImageView.sd_setImage(
                with: url,
                placeholderImage: placeholderImage,
                options: [.retryFailed, .scaleDownLargeImages]
            )
        } else {
            thumbnailImageView.image = placeholderImage
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.sd_cancelCurrentImageLoad()
        thumbnailImageView.image = placeholderImage
        durationLabel.text = nil
        durationLabel.isHidden = true
    }
}

