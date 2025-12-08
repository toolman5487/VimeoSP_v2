//
//  SearchResultCell.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/3.
//

import Foundation
import UIKit
import SnapKit
import SDWebImage

final class SearchResultCell: UITableViewCell {
    
    // MARK: - Constants
    
    private enum Constants {
        
        enum Thumbnail {
            static let width: CGFloat = 160
            static let height: CGFloat = 90
            static let cornerRadius: CGFloat = 8
        }
        
        enum Duration {
            static let width: CGFloat = 60
            static let height: CGFloat = 20
            static let cornerRadius: CGFloat = 4
            static let padding: CGFloat = 4
        }
        
        enum Layout {
            static let horizontalPadding: CGFloat = 16
            static let verticalPadding: CGFloat = 16
            static let labelSpacing: CGFloat = 4
            static let thumbnailLabelSpacing: CGFloat = 12
        }
    }
    
    // MARK: - UI Components
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.Thumbnail.cornerRadius
        imageView.backgroundColor = UIColor.vimeoWhite.withAlphaComponent(0.1)
        imageView.isAccessibilityElement = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .vimeoWhite
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        label.isAccessibilityElement = false
        return label
    }()
    
    private let userLabel: UILabel = {
        let label = UILabel()
        label.textColor = .vimeoWhite.withAlphaComponent(0.7)
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.isAccessibilityElement = false
        return label
    }()
    
    private let statsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .vimeoWhite.withAlphaComponent(0.6)
        label.font = .preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.isAccessibilityElement = false
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .vimeoWhite
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.layer.cornerRadius = Constants.Duration.cornerRadius
        label.clipsToBounds = true
        label.isAccessibilityElement = false
        return label
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupCell() {
        backgroundColor = .vimeoBlack
        selectionStyle = .none
        
        setupAccessibility()
        setupSubviews()
        setupConstraints()
    }
    
    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = [.button]
    }
    
    private func setupSubviews() {
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(userLabel)
        contentView.addSubview(statsLabel)
        contentView.addSubview(durationLabel)
    }
    
    private func setupConstraints() {
        thumbnailImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Constants.Layout.horizontalPadding)
            make.centerY.equalToSuperview()
            make.width.equalTo(Constants.Thumbnail.width)
            make.height.equalTo(Constants.Thumbnail.height)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(Constants.Layout.thumbnailLabelSpacing)
            make.trailing.equalToSuperview().offset(-Constants.Layout.horizontalPadding)
            make.top.equalToSuperview().offset(Constants.Layout.verticalPadding)
        }
        
        userLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(Constants.Layout.labelSpacing)
        }
        
        statsLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(userLabel.snp.bottom).offset(Constants.Layout.labelSpacing)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(thumbnailImageView).offset(-Constants.Duration.padding)
            make.width.equalTo(Constants.Duration.width)
            make.height.equalTo(Constants.Duration.height)
        }
    }
    
    // MARK: - Configuration
    
    func configure(with video: VimeoVideo) {
        titleLabel.text = video.name
        userLabel.text = video.user?.name
        statsLabel.text = video.stats?.formattedPlays.map { "\($0) plays" }
        
        durationLabel.text = video.formattedDuration
        durationLabel.isHidden = video.formattedDuration == nil
        
        loadThumbnail(for: video)
        updateAccessibility(for: video)
    }
    
    // MARK: - Private Methods
    
    private func loadThumbnail(for video: VimeoVideo) {
        let thumbnailURL = video.pictures?.mediumPictureURL ?? video.pictures?.largestPictureURL
        
        if let urlString = thumbnailURL, let url = URL(string: urlString) {
            thumbnailImageView.sd_setImage(
                with: url,
                placeholderImage: nil,
                options: [.retryFailed, .scaleDownLargeImages]
            )
        } else {
            thumbnailImageView.image = nil
        }
    }
    
    private func updateAccessibility(for video: VimeoVideo) {
        var accessibilityComponents: [String] = []
        
        if let name = video.name {
            accessibilityComponents.append(name)
        }
        
        if let userName = video.user?.name {
            accessibilityComponents.append("by \(userName)")
        }
        
        if let duration = video.formattedDuration {
            accessibilityComponents.append("duration \(duration)")
        }
        
        if let plays = video.stats?.formattedPlays {
            accessibilityComponents.append("\(plays) plays")
        }
        
        accessibilityLabel = accessibilityComponents.joined(separator: ", ")
        accessibilityHint = "Double tap to play video"
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.sd_cancelCurrentImageLoad()
        thumbnailImageView.image = nil
        titleLabel.text = nil
        userLabel.text = nil
        statsLabel.text = nil
        durationLabel.text = nil
        durationLabel.isHidden = true
        accessibilityLabel = nil
    }
}
