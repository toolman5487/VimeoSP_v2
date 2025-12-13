//
//  VideoInfoHeaderCell.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/11.
//

import Foundation
import UIKit
import SnapKit
import SDWebImage

final class VideoInfoHeaderCell: UITableViewCell {
    
    private enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 12
        static let avatarSize: CGFloat = 40
        static let buttonSize: CGFloat = 44
        static let buttonSpacing: CGFloat = 16
        static let titleLabelSpacing: CGFloat = 8
        static let channelInfoSpacing: CGFloat = 12
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .vimeoWhite
        label.font = .preferredFont(forTextStyle: .title2)
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let channelContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let channelAvatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.avatarSize / 2
        imageView.backgroundColor = .vimeoWhite.withAlphaComponent(0.1)
        return imageView
    }()
    
    private let channelNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .vimeoWhite
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let actionButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        return stackView
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        button.tintColor = .vimeoWhite
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.tintColor = .vimeoWhite
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.tintColor = .vimeoWhite
        return button
    }()
    
    var onLikeTapped: (() -> Void)?
    var onShareTapped: (() -> Void)?
    var onSaveTapped: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .vimeoBlack
        selectionStyle = .none
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(channelContainerView)
        contentView.addSubview(actionButtonsStackView)
        
        channelContainerView.addSubview(channelAvatarImageView)
        channelContainerView.addSubview(channelNameLabel)
        
        actionButtonsStackView.addArrangedSubview(likeButton)
        actionButtonsStackView.addArrangedSubview(shareButton)
        actionButtonsStackView.addArrangedSubview(saveButton)
        
        setupConstraints()
        setupActions()
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.verticalPadding)
            make.leading.trailing.equalToSuperview().inset(Constants.horizontalPadding)
        }
        
        channelContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Constants.titleLabelSpacing)
            make.leading.equalToSuperview().offset(Constants.horizontalPadding)
            make.trailing.lessThanOrEqualTo(actionButtonsStackView.snp.leading).offset(-Constants.buttonSpacing)
            make.bottom.equalToSuperview().offset(-Constants.verticalPadding)
        }
        
        channelAvatarImageView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.size.equalTo(Constants.avatarSize)
        }
        
        channelNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(channelAvatarImageView.snp.trailing).offset(Constants.channelInfoSpacing)
            make.trailing.centerY.equalToSuperview()
        }
        
        actionButtonsStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Constants.horizontalPadding)
            make.centerY.equalTo(channelContainerView)
        }
        
        [likeButton, shareButton, saveButton].forEach { button in
            button.snp.makeConstraints { make in
                make.size.equalTo(Constants.buttonSize)
            }
        }
    }
    
    private func setupActions() {
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    @objc private func likeButtonTapped() {
        onLikeTapped?()
    }
    
    @objc private func shareButtonTapped() {
        onShareTapped?()
    }
    
    @objc private func saveButtonTapped() {
        onSaveTapped?()
    }
    
    func configure(with video: VideoPlayerModel) {
        titleLabel.text = video.name
        channelNameLabel.text = video.user?.name
        
        if let user = video.user {
            if let pictures = user.pictures,
               let avatarURL = pictures.mediumPictureURL ?? pictures.largestPictureURL,
               let url = URL(string: avatarURL) {
                channelAvatarImageView.sd_setImage(with: url, placeholderImage: nil)
            } else {
                channelAvatarImageView.image = nil
            }
        } else {
            channelAvatarImageView.image = nil
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        channelNameLabel.text = nil
        channelAvatarImageView.sd_cancelCurrentImageLoad()
        channelAvatarImageView.image = nil
    }
}

