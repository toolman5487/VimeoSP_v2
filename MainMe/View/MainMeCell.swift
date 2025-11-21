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

class MainMeAvatarCell: UICollectionViewCell {
    
    static let cellHeight: CGFloat = 120
    
    private let preferredSize: PictureSizeType = .size100
    
    private let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let placeholder: UIImage? = {
        UIImage(systemName: "person.circle.fill")?.withTintColor(UIColor.vimeoWhite, renderingMode: .alwaysOriginal)
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40
        imageView.image = UIImage(systemName: "person.circle.fill")?.withTintColor(UIColor.vimeoWhite, renderingMode: .alwaysOriginal)
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .vimeoWhite
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 3
        return label
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.distribution = .fill
        return stackView
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
        nameLabel.text = nil
        bioLabel.text = nil
        locationLabel.attributedText = nil
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(infoStackView)
        
        infoStackView.addArrangedSubview(nameLabel)
        infoStackView.addArrangedSubview(locationLabel)
        infoStackView.addArrangedSubview(bioLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(8)
            make.size.equalTo(80)
        }
        
        infoStackView.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(16)
            make.centerY.equalTo(imageView)
            make.right.equalToSuperview().inset(16)
        }
    }
    
    func configure(with viewModel: MainMeViewModel) {
        imageView.image = placeholder
        nameLabel.text = viewModel.meModel?.name
        bioLabel.text = viewModel.meModel?.bio
        
        if let location = viewModel.meModel?.location {
            locationLabel.attributedText = createLocationAttributedString(location: location)
        } else {
            locationLabel.attributedText = nil
        }
        
        let imageURL = viewModel.getAvatarImageURL(size: preferredSize)
        
        guard let imageURL = imageURL,
              let url = URL(string: imageURL) else {
            return
        }
        
        imageView.sd_setImage(with: url, placeholderImage: placeholder)
    }
    
    private func createLocationAttributedString(location: String) -> NSAttributedString {
        let imageAttachment = NSTextAttachment()
        if let image = UIImage(systemName: "mappin.and.ellipse")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal) {
            imageAttachment.image = image
            imageAttachment.bounds = CGRect(x: 0, y: -2, width: 12, height: 12)
        }
        let imageString = NSAttributedString(attachment: imageAttachment)
        let locationString = NSAttributedString(
            string: " \(location)",
            attributes: [
                .foregroundColor: UIColor.vimeoWhite,
                .font: UIFont.systemFont(ofSize: 12, weight: .semibold)
            ]
        )
        
        let attributedString = NSMutableAttributedString()
        attributedString.append(imageString)
        attributedString.append(locationString)
        
        return attributedString
    }
}
