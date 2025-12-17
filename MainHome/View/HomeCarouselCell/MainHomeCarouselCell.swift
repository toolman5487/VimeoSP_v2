//
//  MainHomeCarouselCell.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/11.
//

import Foundation
import UIKit
import SnapKit
import SDWebImage

final class MainHomeCarouselCell: UICollectionViewCell {
    
    private enum Config {
        static let autoScrollInterval: TimeInterval = 3.0
        static let pageControlHeight: CGFloat = 30
    }
    
    private var placeholderImage: UIImage? {
        UIImage(systemName: "photo.fill")?.withTintColor(
            .vimeoWhite.withAlphaComponent(0.4),
            renderingMode: .alwaysOriginal
        )
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CarouselVideoCell.self, forCellWithReuseIdentifier: String(describing: CarouselVideoCell.self))
        return collectionView
    }()
    
    private let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.currentPageIndicatorTintColor = .vimeoWhite
        control.pageIndicatorTintColor = UIColor.vimeoWhite.withAlphaComponent(0.3)
        control.hidesForSinglePage = true
        return control
    }()
    
    private var videos: [MainHomeVideo] = []
    private var onVideoTap: ((MainHomeVideo) -> Void)?
    private var autoScrollTimer: Timer?
    private var currentPage: Int = 0 {
        didSet {
            pageControl.currentPage = currentPage
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .clear
        
        contentView.addSubview(collectionView)
        contentView.addSubview(pageControl)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        pageControl.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(Config.pageControlHeight)
        }
    }
    
    func configure(videos: [MainHomeVideo], onVideoTap: @escaping (MainHomeVideo) -> Void) {
        self.videos = videos
        self.onVideoTap = onVideoTap
        pageControl.numberOfPages = videos.count
        
        collectionView.reloadData()
        
        if videos.count > 1 {
            DispatchQueue.main.async { [weak self] in
                self?.scrollToFirstPage()
            }
            startAutoScroll()
        }
    }
    
    private func scrollToFirstPage() {
        guard videos.count > 0 else { return }
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        currentPage = 0
    }
    
    private func startAutoScroll() {
        stopAutoScroll()
        guard videos.count > 1 else { return }
        
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: Config.autoScrollInterval, repeats: true) { [weak self] _ in
            self?.scrollToNextPage()
        }
    }
    
    private func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    private func scrollToNextPage() {
        guard videos.count > 1 else { return }
        
        let nextPage = (currentPage + 1) % videos.count
        let indexPath = IndexPath(item: nextPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        currentPage = nextPage
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopAutoScroll()
        videos = []
        currentPage = 0
        pageControl.numberOfPages = 0
    }
    
    deinit {
        stopAutoScroll()
    }
}

// MARK: - UICollectionViewDataSource
extension MainHomeCarouselCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: CarouselVideoCell.self),
            for: indexPath
        ) as! CarouselVideoCell
        
        let video = videos[indexPath.item]
        cell.configure(with: video)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainHomeCarouselCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let video = videos[indexPath.item]
        onVideoTap?(video)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentPage()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCurrentPage()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAutoScroll()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateCurrentPage()
        }
        startAutoScroll()
    }
    
    private func updateCurrentPage() {
        let pageWidth = collectionView.frame.width
        guard pageWidth > 0 else { return }
        let page = Int(collectionView.contentOffset.x / pageWidth)
        currentPage = min(max(0, page), videos.count - 1)
    }
}
