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


// MARK: - MainMeAvatarCell
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
            make.edges.equalToSuperview()
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
            string: "   \(location)",
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

// MARK: - MainMemetadataCell
class MainMemetadataCell: UICollectionViewCell {
    
    static let cellHeight: CGFloat = 100
    private var metadataItems: [(title: String, value: Int, icon: String)] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(MetadataItemCell.self, forCellWithReuseIdentifier: "MetadataItemCell")
        return cv
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
        metadataItems = []
        collectionView.reloadData()
    }
    
    private func setupUI() {
        contentView.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(with viewModel: MainMeViewModel) {
        guard let connections = viewModel.meModel?.metadata?.connections else {
            metadataItems = []
            collectionView.reloadData()
            return
        }
        
        metadataItems = [
            ("Followers", connections.followers?.total ?? 0, "person.2.fill"),
            ("Following", connections.following?.total ?? 0, "person.2"),
            ("Videos", connections.videos?.total ?? 0, "video.fill"),
            ("Teams", connections.teams?.total ?? 0, "person.3.fill")
        ]
        
        collectionView.reloadData()
    }
}

extension MainMemetadataCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return metadataItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MetadataItemCell", for: indexPath) as! MetadataItemCell
        
        let item = metadataItems[indexPath.item]
        cell.configure(title: item.title, value: item.value, icon: item.icon)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 80)
    }
}

// MARK: - MainMeEntranceCell
class MainMeEntranceCell: UICollectionViewCell {
    
    static let cellHeight: CGFloat = 180
    
    private let collectionView = IconStatItemCollectionView()
    var onItemTapped: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onItemTapped = nil
    }
    
    private func setupUI() {
        contentView.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(with viewModel: MainMeViewModel) {
        guard (viewModel.meModel?.metadata?.connections) != nil else {
            return
        }
        
        let items = [
            IconStatItemModel(title: "Videos", icon: "video.fill", path: "/me/videos"),
            IconStatItemModel(title: "Likes", icon: "heart.fill", path: "/me/likes"),
            IconStatItemModel(title: "Following", icon: "person.2", path: "/me/following"),
            IconStatItemModel(title: "Albums", icon: "photo.on.rectangle", path: "/me/albums"),
            IconStatItemModel(title: "Pictures", icon: "photo.fill", path: "/me/pictures"),
            IconStatItemModel(title: "Channels", icon: "tv.fill", path: "/me/channels"),
            IconStatItemModel(title: "Groups", icon: "person.3.fill", path: "/me/groups"),
            IconStatItemModel(title: "Teams", icon: "person.3.sequence.fill", path: "/me/teams")
        ]
        
        let config = IconStatItemCollectionView.Configuration(
            items: items,
            layoutStyle: .grid(columns: 4),
            spacing: 12,
            insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16),
            onItemTapped: { [weak self] path in
                if let path = path {
                    self?.onItemTapped?(path)
                }
            }
        )
        
        collectionView.configure(with: config)
    }
}
