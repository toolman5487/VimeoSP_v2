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

class SearchResultCell: UITableViewCell {
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = UIColor.vimeoWhite.withAlphaComponent(0.1)
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .vimeoWhite
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    
    private let userLabel: UILabel = {
        let label = UILabel()
        label.textColor = .vimeoWhite.withAlphaComponent(0.7)
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let statsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .vimeoWhite.withAlphaComponent(0.6)
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .vimeoWhite
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        return label
    }()
    
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
        
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(userLabel)
        contentView.addSubview(statsLabel)
        contentView.addSubview(durationLabel)
        
        thumbnailImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(90)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
        }
        
        userLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        statsLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(userLabel.snp.bottom).offset(4)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(thumbnailImageView).offset(-4)
            make.width.equalTo(60)
            make.height.equalTo(20)
        }
    }
    
    func configure(with video: VimeoVideo) {
        titleLabel.text = video.name
        
        if let user = video.user {
            userLabel.text = user.name
        }
        
        if let plays = video.stats?.plays {
            statsLabel.text = video.stats?.formattedPlays ?? "\(plays) plays"
        }
        
        durationLabel.text = video.formattedDuration
        durationLabel.isHidden = video.formattedDuration == nil
        
        if let thumbnailURL = video.pictures?.mediumPictureURL ?? video.pictures?.largestPictureURL {
            thumbnailImageView.sd_setImage(with: URL(string: thumbnailURL))
        } else {
            thumbnailImageView.image = nil
        }
    }
}
