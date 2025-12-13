//
//  VideoDescriptionCell.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/11.
//

import Foundation
import UIKit
import SnapKit

final class VideoDescriptionCell: UITableViewCell {
    
    private enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 12
        static let maxCollapsedLines: Int = 3
        static let buttonHeight: CGFloat = 32
    }
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .vimeoWhite.withAlphaComponent(0.9)
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = Constants.maxCollapsedLines
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let expandButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show more", for: .normal)
        button.setTitle("Show less", for: .selected)
        button.setTitleColor(.vimeoBlue, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    private var isExpanded = false
    var onExpandToggle: ((Bool) -> Void)?
    
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
        
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(expandButton)
        
        setupConstraints()
        setupActions()
    }
    
    private func setupConstraints() {
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.verticalPadding)
            make.leading.trailing.equalToSuperview().inset(Constants.horizontalPadding)
        }
        
        expandButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(Constants.horizontalPadding)
            make.bottom.equalToSuperview().offset(-Constants.verticalPadding)
            make.height.equalTo(Constants.buttonHeight)
        }
    }
    
    private func setupActions() {
        expandButton.addTarget(self, action: #selector(expandButtonTapped), for: .touchUpInside)
    }
    
    @objc private func expandButtonTapped() {
        isExpanded.toggle()
        expandButton.isSelected = isExpanded
        descriptionLabel.numberOfLines = isExpanded ? 0 : Constants.maxCollapsedLines
        
        onExpandToggle?(isExpanded)
        
        UIView.animate(withDuration: 0.2) {
            self.superview?.layoutIfNeeded()
        }
    }
    
    func configure(with video: VideoPlayerModel) {
        descriptionLabel.text = video.description?.isEmpty == false ? video.description : nil
        
        let hasDescription = video.description?.isEmpty == false
        let needsExpansion = needsExpandButton(for: video.description ?? "")
        
        expandButton.isHidden = !hasDescription || !needsExpansion
        descriptionLabel.numberOfLines = isExpanded ? 0 : Constants.maxCollapsedLines
    }
    
    private func needsExpandButton(for text: String) -> Bool {
        let label = UILabel()
        label.text = text
        label.font = descriptionLabel.font
        label.numberOfLines = Constants.maxCollapsedLines
        label.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - Constants.horizontalPadding * 2, height: .greatestFiniteMagnitude)
        label.sizeToFit()
        
        let expandedLabel = UILabel()
        expandedLabel.text = text
        expandedLabel.font = descriptionLabel.font
        expandedLabel.numberOfLines = 0
        expandedLabel.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - Constants.horizontalPadding * 2, height: .greatestFiniteMagnitude)
        expandedLabel.sizeToFit()
        
        return expandedLabel.frame.height > label.frame.height
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        descriptionLabel.text = nil
        isExpanded = false
        expandButton.isSelected = false
        expandButton.isHidden = true
    }
}

