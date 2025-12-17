//
//  CarouselVideoCell.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/17.
//

import Foundation
import UIKit
import SnapKit
import SDWebImage

final class CarouselVideoCell: UICollectionViewCell {
    
    private var placeholderImage: UIImage? {
        UIImage(systemName: "photo.fill")?.withTintColor(
            .vimeoWhite.withAlphaComponent(0.4),
            renderingMode: .alwaysOriginal
        )
    }
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.vimeoWhite.withAlphaComponent(0.1)
        return imageView
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.6).cgColor
        ]
        gradient.locations = [0.5, 1.0]
        return gradient
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .vimeoWhite
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 3
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
        thumbnailImageView.layer.addSublayer(gradientLayer)
        contentView.addSubview(titleLabel)
        
        thumbnailImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(40)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = thumbnailImageView.bounds
    }
    
    func configure(with video: MainHomeVideo) {
        titleLabel.text = video.name
        
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
        titleLabel.text = nil
    }
}

