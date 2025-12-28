//
//  MainHomeSectionCell.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/11.
//

import Foundation
import UIKit
import SnapKit
import SDWebImage

final class MainHomeSectionCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .vimeoWhite
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPrefetchingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.register(MainHomeVideoCell.self, forCellWithReuseIdentifier: String(describing: MainHomeVideoCell.self))
        return collectionView
    }()
    
    private var videos: [MainHomeVideo] = []
    private var onVideoTap: ((MainHomeVideo) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .clear
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(collectionView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(200)
        }
    }
    
    func configure(title: String, videos: [MainHomeVideo], onVideoTap: @escaping (MainHomeVideo) -> Void) {
        titleLabel.attributedText = Self.createAttributedTitle(title)
        
        let videosChanged = self.videos.count != videos.count || 
            (videos.count > 0 && self.videos.count > 0 && self.videos[0].videoId != videos[0].videoId)
        self.videos = videos
        self.onVideoTap = onVideoTap
        
        if videosChanged {
            collectionView.reloadData()
        }
    }
    
    private static func createAttributedTitle(_ text: String) -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: 20, weight: .bold)
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.vimeoWhite,
            .font: font
        ]
        
        let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
        
        guard let chevronImage = UIImage(systemName: "chevron.right")?
            .withTintColor(.vimeoWhite, renderingMode: .alwaysOriginal) else {
            return attributedString
        }
        
        let imageSize = CGSize(width: 16, height: 16)
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = chevronImage
        imageAttachment.bounds = CGRect(
            x: 0,
            y: (font.capHeight - imageSize.height) / 2,
            width: imageSize.width,
            height: imageSize.height
        )
        
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        return attributedString
    }
}

extension MainHomeSectionCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: MainHomeVideoCell.self),
            for: indexPath
        ) as! MainHomeVideoCell
        
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        let isVisible = visibleIndexPaths.contains(indexPath)
        cell.configure(with: videos[indexPath.item], isVisible: isVisible)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height > 0 ? collectionView.frame.height : 200
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let leftInset = layout.sectionInset.left
        let rightInset = layout.sectionInset.right
        let spacing = layout.minimumInteritemSpacing
        let availableWidth = collectionView.frame.width - leftInset - rightInset
        let width = (availableWidth - spacing) / 1.5
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let video = videos[indexPath.item]
        onVideoTap?(video)
    }
    
}

extension MainHomeSectionCell: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let videosToPrefetch = indexPaths.compactMap { indexPath -> MainHomeVideo? in
            guard indexPath.item < videos.count else { return nil }
            return videos[indexPath.item]
        }
        
        let urls = videosToPrefetch.compactMap { video -> URL? in
            guard let urlString = video.thumbnailURL else { return nil }
            return URL(string: urlString)
        }
        
        if !urls.isEmpty {
            SDWebImagePrefetcher.shared.prefetchURLs(urls, progress: nil) { _, _ in }
        }
    }
}

