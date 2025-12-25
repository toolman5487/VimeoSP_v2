//
//  MainHomeViewController.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/16.
//

import Foundation
import UIKit
import SnapKit
import Combine
import SDWebImage

final class MainHomeViewController: BaseMainViewController {
    
    private let viewModel = MainHomeViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private let sections: [VideoSortType] = [.trending]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupCollectionView()
        setupBindings()
        viewModel.fetchAllVideoLists()
    }
    
    override func setupCollectionView() {
        super.setupCollectionView()
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.isPrefetchingEnabled = true
        collectionView.register(
            MainHomeCarouselCell.self,
            forCellWithReuseIdentifier: String(describing: MainHomeCarouselCell.self)
        )
        collectionView.register(
            MainHomeSectionCell.self,
            forCellWithReuseIdentifier: String(describing: MainHomeSectionCell.self)
        )
    }
    
    
    private func setupNavBar() {
        setupLogoTitle()
        setupSearchButton()
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setupLogoTitle() {
        let logoImageView = UIImageView(image: UIImage(named: "Vimeo Wordmark_White"))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.clipsToBounds = true
        
        let containerView = UIView()
        containerView.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.lessThanOrEqualTo(100)
            make.height.equalTo(24)
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: containerView)
    }
    
    private func setupSearchButton() {
        let config = UIImage.SymbolConfiguration(weight: .black)
        let searchImage = UIImage(systemName: "magnifyingglass", withConfiguration: config)
        
        let searchButton = UIBarButtonItem(
            image: searchImage,
            style: .plain,
            target: self,
            action: #selector(searchButtonTapped)
        )
        searchButton.tintColor = .vimeoWhite
        navigationItem.rightBarButtonItem = searchButton
    }
    
    private func setupBindings() {
        viewModel.$videoLists
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                UIView.performWithoutAnimation {
                    self.collectionView.reloadData()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] isLoading in
                isLoading ? self?.showLoading() : self?.hideLoading()
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showError(error, title: "Error")
            }
            .store(in: &cancellables)
    }
    
    private func handleVideoTap(_ video: MainHomeVideo) {
        guard let videoURL = viewModel.getVideoURL(for: video) else { return }
        let videoPlayerViewController = VideoPlayerViewController(videoURL: videoURL)
        navigationController?.pushViewController(videoPlayerViewController, animated: true)
    }
    
    @objc private func searchButtonTapped() {
        let resultsVC = HomeSearchResultsViewController()
        navigationController?.pushViewController(resultsVC, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        
        if indexPath.item == 0 {
            return CGSize(width: width, height: width * 9/16)
        }
        
        return CGSize(width: width, height: 240)
    }
}

extension MainHomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sections.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: MainHomeCarouselCell.self),
                for: indexPath
            ) as? MainHomeCarouselCell else {
                fatalError("Failed to dequeue MainHomeCarouselCell")
            }
            
            let videos = viewModel.getVideos(for: .popular)
            cell.configure(videos: videos) { [weak self] video in
                guard let self = self else { return }
                self.handleVideoTap(video)
            }
            
            return cell
        }
      
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: MainHomeSectionCell.self),
            for: indexPath
        ) as? MainHomeSectionCell else {
            fatalError("Failed to dequeue MainHomeSectionCell")
        }
        
        let sectionIndex = indexPath.item - 1
        guard sectionIndex < sections.count else {
            return cell
        }
        
        let sortType = sections[sectionIndex]
        let videos = viewModel.getVideos(for: sortType)
        
        cell.configure(
            title: sortType.displayName,
            videos: videos
        ) { [weak self] video in
            guard let self = self else { return }
            self.handleVideoTap(video)
        }
        
        return cell
    }
}

extension MainHomeViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let videos = indexPaths.compactMap { indexPath -> [MainHomeVideo]? in
            if indexPath.item == 0 {
                return viewModel.getVideos(for: .popular)
            } else {
                let sectionIndex = indexPath.item - 1
                guard sectionIndex < sections.count else { return nil }
                return viewModel.getVideos(for: sections[sectionIndex])
            }
        }.flatMap { $0 }
        
        let urls = videos.prefix(5).compactMap { video -> URL? in
            guard let urlString = video.thumbnailURL else { return nil }
            return URL(string: urlString)
        }
        
        if !urls.isEmpty {
            SDWebImagePrefetcher.shared.prefetchURLs(urls, progress: nil) { _, _ in }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        SDWebImagePrefetcher.shared.cancelPrefetching()
    }
}
