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
import Combine

// MARK: - MainMeAvatarCell
class MainMeAvatarCell: UICollectionViewCell, MainMeSectionProvider {
    
    static let identifier = "MainMeAvatarCell"
    
    static func shouldDisplay(viewModel: MainMeViewModel) -> Bool {
        return viewModel.meModel != nil
    }
    
    static func cellHeight(viewModel: MainMeViewModel, width: CGFloat) -> CGFloat {
        return 120
    }
    
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
    
    private let uriLabel: UILabel = {
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
        uriLabel.text = nil
        bioLabel.text = nil
        locationLabel.attributedText = nil
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(infoStackView)
        
        infoStackView.addArrangedSubview(uriLabel)
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
        
        if let uri = viewModel.meModel?.uri {
            let id = uri.components(separatedBy: "/").last ?? ""
            uriLabel.text = "# \(id)"
        } else {
            uriLabel.text = nil
        }
        
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
class MainMemetadataCell: UICollectionViewCell, MainMeSectionProvider {
    
    static let identifier = "MainMemetadataCell"
    
    static func shouldDisplay(viewModel: MainMeViewModel) -> Bool {
        return viewModel.meModel != nil
    }
    
    static func cellHeight(viewModel: MainMeViewModel, width: CGFloat) -> CGFloat {
        return 100
    }
    
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
            ("Teams", connections.teams?.total ?? 0, "person.3.fill"),
            ("Likes", connections.likes?.total ?? 0, "hand.thumbsup.fill"),
            ("Watch Later", connections.watchlater?.total ?? 0, "clock.fill"),
            ("Albums", connections.albums?.total ?? 0, "photo.on.rectangle"),
            ("Folders", connections.folders?.total ?? 0, "folder.fill")
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
class MainMeEntranceCell: UICollectionViewCell, MainMeTappableSection {
    
    static let identifier = "MainMeEntranceCell"
    
    static func shouldDisplay(viewModel: MainMeViewModel) -> Bool {
        return true
    }
    
    static func cellHeight(viewModel: MainMeViewModel, width: CGFloat) -> CGFloat {
        let items = viewModel.entranceItems
        let config = IconStatItemCollectionView.Configuration(
            items: items,
            layoutStyle: .grid(columns: 4),
            spacing: 12,
            insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        )
        let collectionViewWidth = width - 32
        let collectionViewHeight = IconStatItemCollectionView.calculateHeight(for: config, width: collectionViewWidth)
        return collectionViewHeight + 16
    }
    
    func configure(with viewModel: MainMeViewModel) {
        configure(with: viewModel, onTap: { _ in })
    }
    
    private let collectionView: IconStatItemCollectionView = {
        let view = IconStatItemCollectionView()
        view.backgroundColor = .quaternaryLabel
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var cancellables = Set<AnyCancellable>()
    var tapPublisher: AnyPublisher<String?, Never> {
        collectionView.tapPublisher
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
    }
    
    private func setupUI() {
        contentView.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.left.right.equalToSuperview().inset(16)
        }
    }
    
    func configure(with viewModel: MainMeViewModel, onTap: @escaping TapHandler) {
        let items = viewModel.entranceItems
        let config = IconStatItemCollectionView.Configuration(
            items: items,
            layoutStyle: .grid(columns: 4),
            spacing: 12,
            insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        )
        collectionView.configure(with: config)
        collectionView.tapPublisher
            .compactMap { $0 }
            .sink { path in
                onTap(path)
            }
            .store(in: &cancellables)
    }
}

// MARK: - MainMeAdditionalStatsCell
class MainMeAdditionalStatsCell: UICollectionViewCell, MainMeSectionProvider {
    
    static let identifier = "MainMeAdditionalStatsCell"
    
    static func shouldDisplay(viewModel: MainMeViewModel) -> Bool {
        return !viewModel.additionalStatsItems.isEmpty
    }
    
    static func cellHeight(viewModel: MainMeViewModel, width: CGFloat) -> CGFloat {
        let items = viewModel.additionalStatsItems
        let config = IconStatItemCollectionView.Configuration(
            items: items,
            layoutStyle: .grid(columns: 3),
            spacing: 12,
            insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        )
        let collectionViewWidth = width - 32
        let collectionViewHeight = IconStatItemCollectionView.calculateHeight(for: config, width: collectionViewWidth)
        return collectionViewHeight + 16
    }
    
    private let collectionView: IconStatItemCollectionView = {
        let view = IconStatItemCollectionView()
        view.backgroundColor = .quaternaryLabel
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
    }
    
    private func setupUI() {
        contentView.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.left.right.equalToSuperview().inset(16)
        }
    }
    
    func configure(with viewModel: MainMeViewModel) {
        let items = viewModel.additionalStatsItems
        let config = IconStatItemCollectionView.Configuration(
            items: items,
            layoutStyle: .grid(columns: 3),
            spacing: 12,
            insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        )
        collectionView.configure(with: config)
    }
}

// MARK: - MainMeContentFilterCell
class MainMeContentFilterCell: UICollectionViewCell, MainMeSectionProvider {
    
    static let identifier = "MainMeContentFilterCell"
    
    static func shouldDisplay(viewModel: MainMeViewModel) -> Bool {
        return !viewModel.contentFilterItems.isEmpty
    }
    
    static func cellHeight(viewModel: MainMeViewModel, width: CGFloat) -> CGFloat {
        return 80
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Content Filter"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .vimeoWhite
        return label
    }()
    
    private let tagFlowView = TagFlowView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(tagFlowView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview().inset(16)
        }
        
        tagFlowView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(28)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    func configure(with viewModel: MainMeViewModel) {
        var config = TagFlowView.Configuration.default
        config.tags = viewModel.contentFilterItems
        config.tagFontSize = 16
        config.tagFontWeight = .semibold
        config.contentInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        tagFlowView.configure(with: config)
    }
}
