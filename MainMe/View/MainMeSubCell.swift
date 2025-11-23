//
//  MainMeSubCell.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/22.
//

import Foundation
import UIKit
import SnapKit

// MARK: - MetadataItemCell
class MetadataItemCell: UICollectionViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .quaternaryLabel
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .vimeoBlue
        return imageView
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .vimeoWhite
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconImageView, valueLabel, titleLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .center
        stack.distribution = .fill
        return stack
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
        iconImageView.image = nil
        valueLabel.text = nil
        titleLabel.text = nil
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(stackView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(8)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
    }
    
    func configure(title: String, value: Int, icon: String) {
        iconImageView.image = UIImage(systemName: icon)
        valueLabel.text = value.formattedCount()
        titleLabel.text = title
    }
}


