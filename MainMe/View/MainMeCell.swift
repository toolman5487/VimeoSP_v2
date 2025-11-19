//
//  MainMeCell.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/19.
//

import Foundation
import UIKit
import SnapKit
import SDWebImage

class MainMeAvartaCell: UICollectionViewCell {
    
    private let preferredSize: PictureSizeType = .size100
    
    private let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        return imageView
    }()
    
    private let placeholder: UIImage? = {
        UIImage(systemName: "person.circle.fill")?.withTintColor(UIColor.vimeoWhite, renderingMode: .alwaysOriginal)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.sd_cancelCurrentImageLoad()
        imageView.image = placeholder
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        
        imageView.image = placeholder
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(100)
        }
    }
    
    func configure(with viewModel: MainMeViewModel) {
        let imageURL = viewModel.getAvatarImageURL(size: preferredSize)
        
        guard let imageURL = imageURL,
              let url = URL(string: imageURL) else {
            imageView.image = placeholder
            return
        }
        
        imageView.sd_setImage(with: url, placeholderImage: placeholder)
    }
}
