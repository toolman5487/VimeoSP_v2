//
//  TagFlowView.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/30.
//

import UIKit
import SnapKit

class TagFlowView: UIView {
    
    // MARK: - Configuration
    struct Configuration {
        var tags: [String]
        var tagHeight: CGFloat
        var tagSpacing: CGFloat
        var tagBackgroundColor: UIColor
        var tagTextColor: UIColor
        var tagFont: UIFont
        var tagCornerRadius: CGFloat
        var tagHorizontalPadding: CGFloat
        var contentInsets: UIEdgeInsets
        
        static var `default`: Configuration {
            Configuration(
                tags: [],
                tagHeight: 28,
                tagSpacing: 8,
                tagBackgroundColor: .quaternaryLabel,
                tagTextColor: .vimeoWhite,
                tagFont: UIFont.systemFont(ofSize: 12, weight: .medium),
                tagCornerRadius: 12,
                tagHorizontalPadding: 12,
                contentInsets: .zero
            )
        }
    }
    
    // MARK: - Properties
    private var configuration: Configuration = .default
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = configuration.tagSpacing
        layout.minimumLineSpacing = configuration.tagSpacing
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(TagCell.self, forCellWithReuseIdentifier: TagCell.identifier)
        return cv
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(with config: Configuration) {
        self.configuration = config
        updateLayout()
        collectionView.reloadData()
    }
    
    func configure(with tags: [String]) {
        var config = Configuration.default
        config.tags = tags
        configure(with: config)
    }
    
    static var defaultHeight: CGFloat {
        return Configuration.default.tagHeight
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func updateLayout() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.minimumInteritemSpacing = configuration.tagSpacing
        layout.minimumLineSpacing = configuration.tagSpacing
        layout.sectionInset = UIEdgeInsets(
            top: 0,
            left: configuration.contentInsets.left,
            bottom: 0,
            right: configuration.contentInsets.right
        )
    }
    
    private func calculateTagWidth(for tag: String) -> CGFloat {
        let label = UILabel()
        label.text = tag.capitalized
        label.font = configuration.tagFont
        return label.intrinsicContentSize.width + configuration.tagHorizontalPadding * 2
    }
}

// MARK: - UICollectionViewDataSource
extension TagFlowView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return configuration.tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCell.identifier, for: indexPath) as! TagCell
        cell.configure(
            text: configuration.tags[indexPath.item].capitalized,
            config: configuration
        )
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TagFlowView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tag = configuration.tags[indexPath.item]
        let width = calculateTagWidth(for: tag)
        return CGSize(width: width, height: configuration.tagHeight)
    }
}

// MARK: - TagCell
private class TagCell: UICollectionViewCell {
    
    static let identifier = "TagCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(text: String, config: TagFlowView.Configuration) {
        label.text = text
        label.font = config.tagFont
        label.textColor = config.tagTextColor
        
        contentView.backgroundColor = config.tagBackgroundColor
        contentView.layer.cornerRadius = config.tagCornerRadius
        contentView.clipsToBounds = true
    }
}
