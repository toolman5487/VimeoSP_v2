//
//  VideoStatsCell.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/11.
//

import Foundation
import UIKit
import SnapKit

final class VideoStatsCell: UITableViewCell {
    
    private enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 8
        static let statSpacing: CGFloat = 16
    }
    
    private let statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Constants.statSpacing
        stackView.alignment = .leading
        return stackView
    }()
    
    private let viewsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .vimeoWhite.withAlphaComponent(0.8)
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .vimeoWhite.withAlphaComponent(0.8)
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
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
        
        contentView.addSubview(statsStackView)
        
        statsStackView.addArrangedSubview(viewsLabel)
        statsStackView.addArrangedSubview(dateLabel)
        
        statsStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Constants.horizontalPadding)
            make.trailing.lessThanOrEqualToSuperview().offset(-Constants.horizontalPadding)
            make.top.equalToSuperview().offset(Constants.verticalPadding)
            make.bottom.equalToSuperview().offset(-Constants.verticalPadding)
        }
    }
    
    func configure(with video: VideoPlayerModel) {
        viewsLabel.text = video.formattedStats.map { "\($0) views" }
        
        if let releaseTime = video.releaseTime {
            dateLabel.text = formatDate(releaseTime)
        } else if let createdTime = video.createdTime {
            dateLabel.text = formatDate(createdTime)
        } else {
            dateLabel.text = nil
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .none
        return displayFormatter.string(from: date)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewsLabel.text = nil
        dateLabel.text = nil
    }
}

