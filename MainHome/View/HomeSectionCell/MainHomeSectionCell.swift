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
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .vimeoWhite
        label.font = .systemFont(ofSize: 24, weight: .bold)
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
    private var cachedTitles: [String: NSAttributedString] = [:]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(collectionView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(200)
        }
    }
    
    func configure(title: String, videos: [MainHomeVideo], onVideoTap: @escaping (MainHomeVideo) -> Void) {
        if let cachedTitle = cachedTitles[title] {
            titleLabel.attributedText = cachedTitle
        } else {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                let attributedTitle = self.createAttributedTitle(title)
                self.cachedTitles[title] = attributedTitle
                DispatchQueue.main.async {
                    self.titleLabel.attributedText = attributedTitle
                }
            }
        }
        
        let videosChanged = self.videos.count != videos.count || 
            (videos.count > 0 && self.videos.count > 0 && self.videos[0].videoId != videos[0].videoId)
        self.videos = videos
        self.onVideoTap = onVideoTap
        
        if videosChanged {
            collectionView.reloadData()
        }
    }
    
    private func createAttributedTitle(_ text: String) -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: 24, weight: .bold)
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.vimeoWhite,
            .font: font
        ]
        
        let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
        
        let chevronImage = UIImage(systemName: "chevron.right")?
            .withTintColor(.vimeoWhite, renderingMode: .alwaysOriginal)
        
        if let image = chevronImage {
            let imageSize = CGSize(width: 20, height: 20)
            let imageAttachment = NSTextAttachment()
            
            UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
            image.draw(in: CGRect(origin: .zero, size: imageSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            imageAttachment.image = resizedImage
            imageAttachment.bounds = CGRect(
                x: 0,
                y: (font.capHeight - imageSize.height) / 2,
                width: imageSize.width,
                height: imageSize.height
            )
            
            let imageString = NSAttributedString(attachment: imageAttachment)
            let spacing = NSAttributedString(string: " ", attributes: attributes)
            
            attributedString.append(spacing)
            attributedString.append(imageString)
        }
        
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
        )
        
        guard let videoCell = cell as? MainHomeVideoCell else {
            return cell
        }
        
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        let isVisible = visibleIndexPaths.contains(indexPath)
        videoCell.configure(with: videos[indexPath.item], isVisible: isVisible)
        return videoCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        let width = height * 16 / 9
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let video = videos[indexPath.item]
        onVideoTap?(video)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateVisibleCellsPriority()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateVisibleCellsPriority()
        }
    }
    
    private func updateVisibleCellsPriority() {
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        
        for indexPath in visibleIndexPaths {
            guard let cell = collectionView.cellForItem(at: indexPath) as? MainHomeVideoCell,
                  indexPath.item < videos.count else { continue }
            cell.configure(with: videos[indexPath.item], isVisible: true)
        }
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
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    }
}

