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

class MainHomeViewController: BaseMainViewController {
    
    private enum LogoConfig {
        static let maxWidth: CGFloat = 100
        static let height: CGFloat = 24
        static let imageName = "Vimeo Wordmark_White"
    }
    
    private let viewModel = MainHomeViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private let sections: [VideoSortType] = [.popular, .trending]
    
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
        collectionView.register(
            MainHomeSectionCell.self,
            forCellWithReuseIdentifier: String(describing: MainHomeSectionCell.self)
        )
        collectionView.register(
            MainHomeCarouselCell.self,
            forCellWithReuseIdentifier: String(describing: MainHomeCarouselCell.self)
        )
    }
    
    private func setupNavBar() {
        setupLogoTitle()
        setupSearchButton()
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setupLogoTitle() {
        let logoImageView = UIImageView(image: UIImage(named: LogoConfig.imageName))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.clipsToBounds = true
        
        let containerView = UIView()
        containerView.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.lessThanOrEqualTo(LogoConfig.maxWidth)
            make.height.equalTo(LogoConfig.height)
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
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
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
        guard let videoId = video.videoId else { return }
        let videoURL = "https://vimeo.com/\(videoId)"
        let videoPlayerViewController = VideoPlayerViewController(videoURL: videoURL)
        navigationController?.pushViewController(videoPlayerViewController, animated: true)
    }
    
    @objc private func searchButtonTapped() {
        let resultsVC = HomeSearchResultsViewController()
        navigationController?.pushViewController(resultsVC, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 {
            return CGSize(width: collectionView.frame.width, height: 280)
        }
        return CGSize(width: collectionView.frame.width, height: 240)
    }
}

extension MainHomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: MainHomeCarouselCell.self),
                for: indexPath
            ) as! MainHomeCarouselCell
            
            let latestVideos = viewModel.getVideos(for: .date)
            cell.configure(
                videos: latestVideos,
                onVideoTap: { [weak self] video in
                    self?.handleVideoTap(video)
                }
            )
            
            return cell
        }
       
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: MainHomeSectionCell.self),
            for: indexPath
        ) as! MainHomeSectionCell
        
        let sortType = sections[indexPath.item - 1]
        let videos = viewModel.getVideos(for: sortType)
        
        cell.configure(
            title: sortType.displayName,
            videos: videos,
            onVideoTap: { [weak self] video in
                self?.handleVideoTap(video)
            }
        )
        
        return cell
    }
}
